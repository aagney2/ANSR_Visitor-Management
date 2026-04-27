import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import '../data/services/auth_service.dart';

class ClientConfig {
  final String clientId;
  final String clientName;
  final String? logoAsset;
  final String? clientImageUrl;
  final String location;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final String visitorDatabasePipelineId;
  final String visitorManagementPipelineId;
  final String employeeMasterPipelineId;
  final String apiBaseUrl;
  final String termsUrl;
  final String privacyUrl;
  final String touchlessCheckinUrl;

  const ClientConfig({
    required this.clientId,
    required this.clientName,
    this.logoAsset,
    this.clientImageUrl,
    this.location = '',
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.visitorDatabasePipelineId,
    required this.visitorManagementPipelineId,
    required this.employeeMasterPipelineId,
    required this.apiBaseUrl,
    required this.termsUrl,
    required this.privacyUrl,
    required this.touchlessCheckinUrl,
  });

  String get _basePrefix => kIsWeb ? '/proxy' : apiBaseUrl;

  String get visitorDatabaseBaseUrl =>
      '$_basePrefix/$visitorDatabasePipelineId/api/v1';

  String get visitorManagementBaseUrl =>
      '$_basePrefix/$visitorManagementPipelineId/api/v1';

  String get employeeMasterBaseUrl =>
      '$_basePrefix/$employeeMasterPipelineId/api/v1';

  /// Build a ClientConfig from authenticated client credentials.
  factory ClientConfig.fromCredentials(ClientCredentials creds) {
    return ClientConfig(
      clientId: creds.leadId.toString(),
      clientName: creds.clientName,
      clientImageUrl: creds.clientImageUrl,
      location: creds.location,
      primaryColor: const Color(0xFF005465),
      secondaryColor: const Color(0xFF007A8A),
      accentColor: const Color(0xFF00B4CC),
      backgroundColor: const Color(0xFFF5F7FA),
      surfaceColor: const Color(0xFFFFFFFF),
      visitorDatabasePipelineId: creds.visitorDatabasePipelineId,
      visitorManagementPipelineId: creds.visitorManagementPipelineId,
      employeeMasterPipelineId: creds.employeeMasterPipelineId,
      apiBaseUrl: 'https://kelsa.io',
      termsUrl: 'https://vizmo.co/terms',
      privacyUrl: 'https://vizmo.co/privacy',
      touchlessCheckinUrl:
          'https://ansr-visitor-checkin.web.app?client=${creds.leadId}',
    );
  }

  factory ClientConfig.fromJson(Map<String, dynamic> json) {
    return ClientConfig(
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String,
      logoAsset: json['logoAsset'] as String?,
      primaryColor: _parseColor(json['primaryColor'] as String),
      secondaryColor: _parseColor(json['secondaryColor'] as String),
      accentColor: _parseColor(json['accentColor'] as String),
      backgroundColor: _parseColor(json['backgroundColor'] as String),
      surfaceColor: _parseColor(json['surfaceColor'] as String),
      visitorDatabasePipelineId:
          json['visitorDatabasePipelineId'] as String,
      visitorManagementPipelineId:
          json['visitorManagementPipelineId'] as String,
      employeeMasterPipelineId:
          json['employeeMasterPipelineId'] as String,
      apiBaseUrl: json['apiBaseUrl'] as String,
      termsUrl: json['termsUrl'] as String,
      privacyUrl: json['privacyUrl'] as String,
      touchlessCheckinUrl: json['touchlessCheckinUrl'] as String? ?? '',
    );
  }

  static Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceFirst('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16));
  }
}

class ClientConfigRepository {
  static ClientConfig? _cachedConfig;

  static Future<ClientConfig> load({String configAsset = 'assets/config/ansr_config.json'}) async {
    if (_cachedConfig != null) return _cachedConfig!;
    final jsonStr = await rootBundle.loadString(configAsset);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _cachedConfig = ClientConfig.fromJson(json);
    return _cachedConfig!;
  }

  static void clearCache() => _cachedConfig = null;
}
