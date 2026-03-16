import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants/app_constants.dart';

class AttachmentValue {
  final String url;
  final int size;
  final int uploadId;

  const AttachmentValue({
    required this.url,
    required this.size,
    required this.uploadId,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'size': size,
        'upload_id': uploadId,
      };
}

class KelsaUploadService {
  late final Dio _kelsaDio;
  late final Dio _s3Dio;

  KelsaUploadService({required String apiBaseUrl}) {
    _kelsaDio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-User-Email': dotenv.env['KELSA_USER_EMAIL'] ?? '',
        'X-User-Token': dotenv.env['KELSA_USER_TOKEN'] ?? '',
      },
    ));

    _kelsaDio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('[UPLOAD] $obj'),
    ));

    _s3Dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
    ));
  }

  /// Full 3-step attachment upload: presigned POST → S3 upload → register.
  Future<AttachmentValue> uploadAttachment({
    required Uint8List fileBytes,
    required String filename,
    required String contentType,
    required String pipelineId,
  }) async {
    // Step 1: Get presigned POST data from Kelsa
    final presignedResponse = await _kelsaDio.get<Map<String, dynamic>>(
      '/api/v1/uploads/presigned_post',
      queryParameters: {
        'pipeline_id': pipelineId,
        'content_type': contentType,
        'filename': filename,
      },
    );

    final presignedData = presignedResponse.data!;
    final s3Url = presignedData['url'] as String;
    final fields = Map<String, String>.from(presignedData['fields'] as Map);

    // Step 2: Upload to S3 via multipart form POST
    final formData = FormData();
    for (final entry in fields.entries) {
      formData.fields.add(MapEntry(entry.key, entry.value));
    }
    // File must be the last field
    formData.files.add(MapEntry(
      'file',
      MultipartFile.fromBytes(fileBytes,
          filename: filename, contentType: DioMediaType.parse(contentType)),
    ));

    final s3Response = await _s3Dio.post<String>(
      s3Url,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        responseType: ResponseType.plain,
      ),
    );

    // Parse <Location> from the S3 XML response
    final locationMatch = RegExp(r'<Location>(.*?)</Location>')
        .firstMatch(s3Response.data ?? '');
    if (locationMatch == null) {
      throw Exception('Could not parse S3 upload location from response');
    }
    final fileUrl = Uri.decodeFull(locationMatch.group(1)!);

    // Step 3: Register the upload in Kelsa
    final registerResponse = await _kelsaDio.post<Map<String, dynamic>>(
      '/api/v1/uploads',
      data: {
        'upload': {
          'url': fileUrl,
          'upload_type': 'attachment',
          'metadata': {'size': fileBytes.length},
          'pipeline_id': int.parse(pipelineId),
        },
      },
    );

    final uploadId = registerResponse.data!['upload']['id'] as int;

    return AttachmentValue(
      url: fileUrl,
      size: fileBytes.length,
      uploadId: uploadId,
    );
  }

  /// Upload a photo file to a specific pipeline.
  Future<AttachmentValue> uploadPhoto({
    required File file,
    required String pipelineId,
  }) async {
    final bytes = await file.readAsBytes();
    final filename = file.path.split('/').last;

    String contentType = 'image/jpeg';
    if (filename.endsWith('.png')) {
      contentType = 'image/png';
    } else if (filename.endsWith('.gif')) {
      contentType = 'image/gif';
    }

    return uploadAttachment(
      fileBytes: bytes,
      filename: filename,
      contentType: contentType,
      pipelineId: pipelineId,
    );
  }

  /// Upload signature bytes to a specific pipeline.
  Future<AttachmentValue> uploadSignature({
    required Uint8List signatureBytes,
    required String pipelineId,
  }) async {
    return uploadAttachment(
      fileBytes: signatureBytes,
      filename: 'signature_${DateTime.now().millisecondsSinceEpoch}.png',
      contentType: 'image/png',
      pipelineId: pipelineId,
    );
  }
}
