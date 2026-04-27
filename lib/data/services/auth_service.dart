import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ClientCredentials {
  final int leadId;
  final String email;
  final String clientName;
  final String? clientImageUrl;
  final String location;
  final String visitorDatabasePipelineId;
  final String visitorManagementPipelineId;
  final String employeeMasterPipelineId;

  const ClientCredentials({
    required this.leadId,
    required this.email,
    required this.clientName,
    this.clientImageUrl,
    required this.location,
    required this.visitorDatabasePipelineId,
    required this.visitorManagementPipelineId,
    required this.employeeMasterPipelineId,
  });

  Map<String, dynamic> toJson() => {
        'leadId': leadId,
        'email': email,
        'clientName': clientName,
        'clientImageUrl': clientImageUrl,
        'location': location,
        'visitorDatabasePipelineId': visitorDatabasePipelineId,
        'visitorManagementPipelineId': visitorManagementPipelineId,
        'employeeMasterPipelineId': employeeMasterPipelineId,
      };

  factory ClientCredentials.fromJson(Map<String, dynamic> json) =>
      ClientCredentials(
        leadId: json['leadId'] as int,
        email: json['email'] as String,
        clientName: json['clientName'] as String,
        clientImageUrl: json['clientImageUrl'] as String?,
        location: json['location'] as String? ?? '',
        visitorDatabasePipelineId: json['visitorDatabasePipelineId'] as String,
        visitorManagementPipelineId: json['visitorManagementPipelineId'] as String,
        employeeMasterPipelineId: json['employeeMasterPipelineId'] as String,
      );
}

class AuthService {
  static const _masterPipelineId = '14432';
  static const _prefsKey = 'logged_in_client';

  late final Dio _dio;

  AuthService() {
    final baseUrl = kIsWeb ? '/proxy' : 'https://kelsa.io';
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (!kIsWeb) {
      headers['X-User-Email'] = dotenv.env['KELSA_USER_EMAIL'] ?? '';
      headers['X-User-Token'] = dotenv.env['KELSA_USER_TOKEN'] ?? '';
    }

    _dio = Dio(BaseOptions(
      baseUrl: '$baseUrl/$_masterPipelineId/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: headers,
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[AUTH] $obj'),
      ));
    }
  }

  Future<ClientCredentials> login(String email, String password) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/leads',
      queryParameters: {
        'search_query': 'cf_visitor_management_email:$email',
        'per_page': 1,
      },
    );

    final leads = response.data?['leads'] as List?;
    if (leads == null || leads.isEmpty) {
      throw Exception('No account found with this email');
    }

    final lead = leads.first as Map<String, dynamic>;
    final fields = lead['custom_field_values'] as Map<String, dynamic>;

    final storedPassword = fields['password'] as String?;
    if (storedPassword == null || storedPassword != password) {
      throw Exception('Invalid password');
    }

    final clientImage = fields['client_image'];
    String? imageUrl;
    if (clientImage is Map) {
      imageUrl = clientImage['url'] as String?;
    }

    final vdbId = _toIntString(fields['visitor_data_base_id']);
    final vmId = _toIntString(fields['visitor_management_id']);
    final emId = _toIntString(fields['employee_master_database_id']);

    if (vdbId == null || vmId == null || emId == null) {
      throw Exception('Client pipeline configuration is incomplete');
    }

    final credentials = ClientCredentials(
      leadId: lead['id'] as int,
      email: email,
      clientName: (fields['name_of_client'] as String?) ?? 'Visitor Management',
      clientImageUrl: imageUrl,
      location: (fields['location'] as String?) ?? '',
      visitorDatabasePipelineId: vdbId,
      visitorManagementPipelineId: vmId,
      employeeMasterPipelineId: emId,
    );

    await _saveCredentials(credentials);
    return credentials;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<ClientCredentials?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json == null) return null;
    try {
      return ClientCredentials.fromJson(
          jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Fetch a client's config by lead ID (used by PWA via ?client= URL param).
  /// No password check — the QR code itself serves as authorization.
  Future<ClientCredentials> fetchClientById(int leadId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/leads/$leadId',
    );

    final lead = response.data?['lead'] as Map<String, dynamic>?;
    if (lead == null) {
      throw Exception('Client not found');
    }

    final fields = lead['custom_field_values'] as Map<String, dynamic>;

    final clientImage = fields['client_image'];
    String? imageUrl;
    if (clientImage is Map) {
      imageUrl = clientImage['url'] as String?;
    }

    final vdbId = _toIntString(fields['visitor_data_base_id']);
    final vmId = _toIntString(fields['visitor_management_id']);
    final emId = _toIntString(fields['employee_master_database_id']);

    if (vdbId == null || vmId == null || emId == null) {
      throw Exception('Client pipeline configuration is incomplete');
    }

    return ClientCredentials(
      leadId: lead['id'] as int,
      email: (fields['visitor_management_email'] as String?) ?? '',
      clientName: (fields['name_of_client'] as String?) ?? 'Visitor Management',
      clientImageUrl: imageUrl,
      location: (fields['location'] as String?) ?? '',
      visitorDatabasePipelineId: vdbId,
      visitorManagementPipelineId: vmId,
      employeeMasterPipelineId: emId,
    );
  }

  /// Kelsa returns numeric fields as doubles (e.g. 13274.0) — strip the decimal.
  static String? _toIntString(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toString();
    if (value is double) return value.toInt().toString();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed.toInt().toString();
      return value;
    }
    return value.toString();
  }

  Future<void> _saveCredentials(ClientCredentials credentials) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(credentials.toJson()));
  }
}
