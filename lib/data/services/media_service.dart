import 'dart:typed_data';

class MediaUploadResult {
  final String url;
  final int size;

  const MediaUploadResult({required this.url, required this.size});

  Map<String, dynamic> toJson() => {'url': url, 'size': size};
}

abstract class MediaService {
  Future<MediaUploadResult> uploadPhotoBytes(Uint8List bytes, String filename);
  Future<MediaUploadResult> uploadSignature(Uint8List signatureBytes);
}

class LocalMediaService implements MediaService {
  @override
  Future<MediaUploadResult> uploadPhotoBytes(Uint8List bytes, String filename) async {
    return MediaUploadResult(url: 'local://$filename', size: bytes.length);
  }

  @override
  Future<MediaUploadResult> uploadSignature(Uint8List signatureBytes) async {
    return MediaUploadResult(url: 'local://signature.png', size: signatureBytes.length);
  }
}
