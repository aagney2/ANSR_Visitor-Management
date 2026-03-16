import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Abstraction for media upload. Currently stores locally and returns a local
/// file URI. Replace the upload method with actual Kelsa/S3 upload when the
/// endpoint is available.
abstract class MediaService {
  Future<MediaUploadResult> uploadPhoto(File file);
  Future<MediaUploadResult> uploadSignature(Uint8List signatureBytes);
}

class MediaUploadResult {
  final String url;
  final int size;

  const MediaUploadResult({required this.url, required this.size});

  Map<String, dynamic> toJson() => {'url': url, 'size': size};
}

/// Local placeholder implementation.
/// TODO: Replace with real upload service (Kelsa media endpoint or S3)
/// when the upload API is available.
class LocalMediaService implements MediaService {
  @override
  Future<MediaUploadResult> uploadPhoto(File file) async {
    final bytes = await file.readAsBytes();
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${const Uuid().v4()}.jpg';
    final saved = await File('${dir.path}/$fileName').writeAsBytes(bytes);
    return MediaUploadResult(url: saved.path, size: bytes.length);
  }

  @override
  Future<MediaUploadResult> uploadSignature(Uint8List signatureBytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${const Uuid().v4()}_signature.png';
    final saved =
        await File('${dir.path}/$fileName').writeAsBytes(signatureBytes);
    return MediaUploadResult(url: saved.path, size: signatureBytes.length);
  }
}
