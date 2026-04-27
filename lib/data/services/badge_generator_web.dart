import 'dart:typed_data';

class BadgeData {
  final String visitorName;
  final String dateTime;
  final String whomToMeet;
  final String purpose;
  final String? qrData;
  final Uint8List? photoBytes;
  final String? photoUrl;
  final String? clientImageUrl;
  final String clientName;

  const BadgeData({
    required this.visitorName,
    required this.dateTime,
    required this.whomToMeet,
    required this.purpose,
    this.qrData,
    this.photoBytes,
    this.photoUrl,
    this.clientImageUrl,
    this.clientName = '',
  });
}

class BadgeGenerator {
  static Future<Uint8List> generateBadge(BadgeData data) async {
    throw UnsupportedError('Badge generation is not supported on web');
  }
}
