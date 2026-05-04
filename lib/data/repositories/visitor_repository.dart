import '../models/custom_field_mapping.dart';
import '../models/kelsa_lead.dart';
import '../models/visitor.dart';
import '../services/kelsa_service.dart';
import '../../core/utils/validators.dart';

class VisitorRepository {
  final KelsaService _dbService;
  final KelsaService _mgmtService;
  CustomFieldMapping? _dbFields;
  CustomFieldMapping? _mgmtFields;

  VisitorRepository({
    required KelsaService databaseService,
    required KelsaService managementService,
  })  : _dbService = databaseService,
        _mgmtService = managementService;

  Future<CustomFieldMapping> getDatabaseFields() async {
    _dbFields ??= CustomFieldMapping(await _dbService.getCustomFields());
    return _dbFields!;
  }

  Future<CustomFieldMapping> getManagementFields() async {
    _mgmtFields ??= CustomFieldMapping(await _mgmtService.getCustomFields());
    return _mgmtFields!;
  }

  Future<Visitor?> searchByPhone(String rawPhone) async {
    final phone = Validators.normalizePhone(rawPhone);
    final fields = await getDatabaseFields();

    final phoneField = fields.resolveFirst(
      ['cf_phone_number', 'phone_number', 'cf_phone', 'phone'],
    );
    if (phoneField == null) return null;

    // Kelsa search_query requires cf_ prefix regardless of the actual identifier
    final searchKey = phoneField.startsWith('cf_')
        ? phoneField
        : 'cf_$phoneField';

    final leads = await _dbService.searchLeads('$searchKey:$phone');
    if (leads.isEmpty) return null;

    // Kelsa search is partial-match; verify exact phone match
    final searchDigits = _normalizeDigits(phone);
    for (final lead in leads) {
      final cfv = lead.customFieldValues;
      String? leadPhone;
      for (final key in ['cf_phone_number', 'phone_number', 'cf_phone', 'phone']) {
        if (cfv[key] != null) {
          leadPhone = cfv[key].toString();
          break;
        }
      }
      if (leadPhone == null) continue;
      final leadDigits = _normalizeDigits(leadPhone);
      if (_phonesMatch(searchDigits, leadDigits)) {
        return _mapLeadToVisitor(lead, fields);
      }
    }
    return null;
  }

  Visitor _mapLeadToVisitor(KelsaLead lead, CustomFieldMapping fields) {
    final cfv = lead.customFieldValues;

    String? extractString(List<String> candidates) {
      for (final c in candidates) {
        if (fields.has(c) && cfv[c] != null) {
          final val = cfv[c];
          return val is String ? val : val?.toString();
        }
      }
      return null;
    }

    Map<String, dynamic>? extractMap(List<String> candidates) {
      for (final c in candidates) {
        if (fields.has(c) && cfv[c] is Map) {
          return cfv[c] as Map<String, dynamic>;
        }
      }
      return null;
    }

    final photo = extractMap(['cf_photo', 'photo']);

    return Visitor(
      databaseLeadId: lead.id,
      name: extractString(['cf_name', 'name']) ?? lead.name,
      email: extractString(['cf_email', 'email']),
      phoneNumber: extractString(['cf_phone_number', 'phone_number', 'cf_phone', 'phone']) ?? '',
      company: extractString(['cf_company', 'company']),
      location: extractString(['cf_location', 'location']),
      serialNumber: extractString(['cf_serial_number', 'serial_number']),
      photoUrl: photo?['url'] as String?,
      photoSize: photo?['size'] as int?,
      // Badge number intentionally not fetched — it changes per visit
      rawCustomFields: cfv,
    );
  }

  Future<int> createOrUpdateVisitorDatabase(Visitor visitor) async {
    final fields = await getDatabaseFields();

    final payload = <String, dynamic>{};

    void setField(List<String> candidates, dynamic value) {
      if (value == null) return;
      final key = fields.resolveFirst(candidates);
      if (key != null) payload[key] = value;
    }

    setField(['cf_name', 'name'], visitor.name);
    setField(['cf_email', 'email'], visitor.email);
    setField(['cf_phone_number', 'phone_number', 'cf_phone', 'phone'], visitor.phoneNumber);
    setField(['cf_company', 'company'], visitor.company);
    setField(['cf_location', 'location'], visitor.location);
    setField(['cf_serial_number', 'serial_number'], visitor.serialNumber);

    // Photo attachment (uploaded via presigned S3 flow)
    if (visitor.photoUrl != null && visitor.photoUploadId != null) {
      setField(['cf_photo', 'photo'], {
        'url': visitor.photoUrl,
        'size': visitor.photoSize,
        'upload_id': visitor.photoUploadId,
      });
    }

    if (visitor.isReturning) {
      final result =
          await _dbService.updateLead(visitor.databaseLeadId!, payload);
      return await _resolveLeadId(result, _dbService);
    } else {
      final result = await _dbService.createLead(payload);
      return await _resolveLeadId(result, _dbService);
    }
  }

  /// Creates a visit entry in the Visitor Management pipeline.
  ///
  /// Sets all direct fields plus explicit id_to_database link to prevent
  /// Kelsa from auto-creating a duplicate visitor database lead.
  Future<int> createVisitEntry({
    required Visitor visitor,
    required int databaseLeadId,
    String? loginLocation,
  }) async {
    final fields = await getManagementFields();
    final payload = <String, dynamic>{};

    void setField(List<String> candidates, dynamic value) {
      if (value == null) return;
      final key = fields.resolveFirst(candidates);
      if (key != null) payload[key] = value;
    }

    // Direct text fields
    setField(['phone_number', 'cf_phone_number'], visitor.phoneNumber);
    setField(['name', 'cf_name'], visitor.name);
    setField(['email', 'cf_email'], visitor.email);
    setField(['company', 'cf_company'], visitor.company);
    setField(['location', 'cf_location'], visitor.location);
    setField(['device_id', 'cf_device_id'], visitor.serialNumber);

    // Visitor type — dropdown field, needs {"id": ..., "name": "..."}
    if (visitor.visitorTypeOptionId != null && visitor.visitorTypeName != null) {
      setField(['visitor_type', 'cf_visitor_type'], {
        'id': visitor.visitorTypeOptionId,
        'name': visitor.visitorTypeName,
      });
    }

    // Whom to meet — master field referencing employee pipeline
    if (visitor.whomToMeetOptionId != null && visitor.whomToMeet != null) {
      setField(['whom_to_meet1', 'cf_whom_to_meet1'], {
        'id': visitor.whomToMeetOptionId,
        'name': visitor.whomToMeet,
      });
    }

    // Explicit link to visitor database lead — prevents Kelsa from
    // auto-creating a duplicate lead via the id_to_database formula
    setField(['id_to_database', 'cf_id_to_database'], {
      'id': databaseLeadId,
      'name': visitor.phoneNumber,
    });

    // Photo: photo1 master field auto-pulls from visitor database via id_to_database

    // Signature attachment (uploaded to management pipeline)
    if (visitor.signatureUrl != null && visitor.signatureUploadId != null) {
      setField(['signature', 'cf_signature'], {
        'url': visitor.signatureUrl,
        'size': visitor.signatureSize,
        'upload_id': visitor.signatureUploadId,
      });
    }

    // Login location from client config (which device/location checked them in)
    setField(['login_location', 'cf_login_location'], loginLocation);

    // Visitor pass number
    setField(['visitor_pass_no', 'cf_visitor_pass_no'], visitor.badgeNumber);

    final result = await _mgmtService.createLead(payload);
    return await _resolveLeadId(result, _mgmtService);
  }

  /// Check out a visitor by updating the Visitor Management lead.
  /// Sets cf_checkout to "Yes" and cf_check_out_date___time to now.
  Future<Map<String, dynamic>> checkoutVisitor(int leadId) async {
    final fields = await getManagementFields();

    final payload = <String, dynamic>{};

    // Set checkout date/time to now (ISO 8601)
    final checkoutTimeKey = fields.resolveFirst(
        ['check_out_date___time', 'cf_check_out_date___time']);
    if (checkoutTimeKey != null) {
      payload[checkoutTimeKey] = DateTime.now().toIso8601String();
    }

    // Set checkout dropdown to "Yes"
    final checkoutKey =
        fields.resolveFirst(['checkout', 'cf_checkout']);
    if (checkoutKey != null) {
      final options = fields.optionsFor(checkoutKey);
      final yesOption = options?.firstWhere(
        (o) => o.name.toLowerCase() == 'yes',
        orElse: () => options!.first,
      );
      if (yesOption != null) {
        payload[checkoutKey] = {'id': yesOption.id, 'name': yesOption.name};
      }
    }

    if (payload.isEmpty) {
      throw Exception('Checkout fields not found in pipeline configuration');
    }

    await _mgmtService.updateLead(leadId, payload);

    // Fetch the updated lead to return visitor details
    final lead = await _mgmtService.getLead(leadId);
    return lead.customFieldValues;
  }

  Future<int> _resolveLeadId(
      KelsaLeadOrDraft result, KelsaService service) async {
    if (!result.isDraft && result.leadId != null) return result.leadId!;
    if (result.isDraft && result.draftId != null) {
      return await service.pollDraftUntilResolved(result.draftId!);
    }
    throw Exception('Could not resolve lead ID from Kelsa response');
  }

  /// Strips a phone string to digits only.
  static String _normalizeDigits(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9]'), '');

  /// Compares two digit-only phone strings, accounting for country code
  /// differences (e.g., "919876543210" vs "9876543210").
  static bool _phonesMatch(String a, String b) {
    if (a == b) return true;
    // Handle case where one has country code and the other doesn't
    if (a.length > b.length && a.endsWith(b) && a.length - b.length <= 3) {
      return true;
    }
    if (b.length > a.length && b.endsWith(a) && b.length - a.length <= 3) {
      return true;
    }
    return false;
  }
}
