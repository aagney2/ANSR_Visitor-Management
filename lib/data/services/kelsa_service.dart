import 'dart:async';
import '../api/api_client.dart';
import '../models/kelsa_field.dart';
import '../models/kelsa_lead.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';

class KelsaService {
  final ApiClient _client;
  ApiClient get client => _client;

  KelsaService(this._client);

  /// Fetch all custom fields for this pipeline.
  Future<List<KelsaCustomField>> getCustomFields() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/custom_fields',
      queryParameters: {'all': 'true'},
    );
    final data = response.data!;
    final fields = (data['custom_fields'] as List?) ?? [];
    return fields
        .map((f) => KelsaCustomField.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  /// Search leads by a custom field query.
  Future<List<KelsaLead>> searchLeads(String searchQuery) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/leads',
      queryParameters: {'search_query': searchQuery},
    );
    final data = response.data!;
    final leads = (data['leads'] as List?) ?? [];
    return leads
        .map((l) => KelsaLead.fromJson(l as Map<String, dynamic>))
        .toList();
  }

  /// Get a single lead by id.
  Future<KelsaLead> getLead(int id) async {
    final response = await _client.get<Map<String, dynamic>>('/leads/$id');
    final data = response.data!;
    return KelsaLead.fromJson(data['lead'] as Map<String, dynamic>);
  }

  /// Create a new lead.
  /// Returns either a KelsaLead (if resolved) or a KelsaDraft.
  Future<KelsaLeadOrDraft> createLead(
      Map<String, dynamic> customFieldValues) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/leads',
      data: {
        'lead': {'custom_field_values': customFieldValues},
      },
    );
    final data = response.data!;
    if (data.containsKey('lead')) {
      return KelsaLeadOrDraft(
        lead: KelsaLead.fromJson(data['lead'] as Map<String, dynamic>),
      );
    }
    if (data.containsKey('draft')) {
      return KelsaLeadOrDraft(
        draft: KelsaDraft.fromJson(data['draft'] as Map<String, dynamic>),
      );
    }
    throw const AppException('Unexpected response from Kelsa create lead');
  }

  /// Update an existing lead.
  Future<KelsaLeadOrDraft> updateLead(
      int id, Map<String, dynamic> customFieldValues) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/leads/$id',
      data: {
        'lead': {'custom_field_values': customFieldValues},
      },
    );
    final data = response.data!;
    if (data.containsKey('lead')) {
      return KelsaLeadOrDraft(
        lead: KelsaLead.fromJson(data['lead'] as Map<String, dynamic>),
      );
    }
    if (data.containsKey('draft')) {
      return KelsaLeadOrDraft(
        draft: KelsaDraft.fromJson(data['draft'] as Map<String, dynamic>),
      );
    }
    throw const AppException('Unexpected response from Kelsa update lead');
  }

  /// Get a draft by id.
  Future<KelsaDraft> getDraft(int draftId) async {
    final response =
        await _client.get<Map<String, dynamic>>('/drafts/$draftId');
    final data = response.data!;
    return KelsaDraft.fromJson(data['draft'] as Map<String, dynamic>);
  }

  /// Poll a draft until lead_id is available, with timeout.
  Future<int> pollDraftUntilResolved(int draftId) async {
    final deadline = DateTime.now().add(
      Duration(seconds: AppConstants.draftPollTimeoutSeconds),
    );

    while (DateTime.now().isBefore(deadline)) {
      final draft = await getDraft(draftId);
      if (draft.isResolved) return draft.leadId!;
      await Future.delayed(
        Duration(seconds: AppConstants.draftPollIntervalSeconds),
      );
    }

    throw const DraftPollingException(
      'Timed out waiting for draft to resolve. Please try again.',
    );
  }
}

class KelsaLeadOrDraft {
  final KelsaLead? lead;
  final KelsaDraft? draft;

  const KelsaLeadOrDraft({this.lead, this.draft});

  bool get isDraft => draft != null && (lead == null);
  int? get leadId => lead?.id;
  int? get draftId => draft?.id;
}
