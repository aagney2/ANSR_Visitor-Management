import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/client_config.dart';
import '../../data/api/api_client.dart';
import '../../data/repositories/visitor_repository.dart';
import '../../data/services/kelsa_service.dart';
import '../../data/services/kelsa_upload_service.dart';
import '../../data/services/media_service.dart';

/// Holds the loaded client config for the current tenant.
final clientConfigProvider = StateProvider<ClientConfig?>((ref) => null);

/// API client for the Visitor Database pipeline.
final visitorDbApiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(clientConfigProvider);
  if (config == null) throw StateError('ClientConfig not loaded');
  return ApiClient(baseUrl: config.visitorDatabaseBaseUrl);
});

/// API client for the Visitor Management pipeline.
final visitorMgmtApiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(clientConfigProvider);
  if (config == null) throw StateError('ClientConfig not loaded');
  return ApiClient(baseUrl: config.visitorManagementBaseUrl);
});

/// API client for the Employee Master pipeline.
final employeeMasterApiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(clientConfigProvider);
  if (config == null) throw StateError('ClientConfig not loaded');
  return ApiClient(baseUrl: config.employeeMasterBaseUrl);
});

/// Kelsa service for the Visitor Database pipeline.
final visitorDbServiceProvider = Provider<KelsaService>((ref) {
  return KelsaService(ref.watch(visitorDbApiClientProvider));
});

/// Kelsa service for the Visitor Management pipeline.
final visitorMgmtServiceProvider = Provider<KelsaService>((ref) {
  return KelsaService(ref.watch(visitorMgmtApiClientProvider));
});

/// Kelsa service for the Employee Master pipeline.
final employeeMasterServiceProvider = Provider<KelsaService>((ref) {
  return KelsaService(ref.watch(employeeMasterApiClientProvider));
});

/// Main visitor repository.
final visitorRepositoryProvider = Provider<VisitorRepository>((ref) {
  return VisitorRepository(
    databaseService: ref.watch(visitorDbServiceProvider),
    managementService: ref.watch(visitorMgmtServiceProvider),
  );
});

/// Media service (local file storage fallback).
final mediaServiceProvider = Provider<MediaService>((ref) {
  return LocalMediaService();
});

/// Kelsa upload service for S3 attachment uploads.
final kelsaUploadServiceProvider = Provider<KelsaUploadService>((ref) {
  final config = ref.watch(clientConfigProvider);
  if (config == null) throw StateError('ClientConfig not loaded');
  return KelsaUploadService(apiBaseUrl: config.apiBaseUrl);
});
