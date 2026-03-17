import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BadgeData {
  final String visitorName;
  final String dateTime;
  final String whomToMeet;
  final String purpose;
  final String? qrData;
  final File? photoFile;
  final String? photoUrl;

  const BadgeData({
    required this.visitorName,
    required this.dateTime,
    required this.whomToMeet,
    required this.purpose,
    this.qrData,
    this.photoFile,
    this.photoUrl,
  });
}

class BadgeGenerator {
  /// Generate a visitor badge as PNG bytes matching the Brother QL-820NWB
  /// 62mm label format. Layout matches the ANSR badge template:
  /// [Photo]  [ANSR Logo]
  ///          [Name]
  ///          [Date/Time]
  ///          [Meeting: ...]
  ///          [Purpose: ...]
  /// [QR Code]
  static Future<Uint8List> generateBadge(BadgeData data) async {
    // QL-820NWB 62mm label: 720px wide at 300dpi, variable height
    const double badgeWidth = 720;
    const double badgeHeight = 450;
    const double padding = 24;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, badgeWidth, badgeHeight));

    // White background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, badgeWidth, badgeHeight),
      Paint()..color = Colors.white,
    );

    // Load ANSR logo
    ui.Image? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/ansr_logo.png');
      logoImage = await _decodeImage(logoBytes.buffer.asUint8List());
    } catch (_) {}

    // Draw visitor photo (circular, top-left)
    const double photoSize = 140;
    const double photoX = padding;
    const double photoY = padding;

    ui.Image? photoImage;
    if (data.photoFile != null) {
      try {
        final bytes = await data.photoFile!.readAsBytes();
        photoImage = await _decodeImage(bytes);
      } catch (_) {}
    }

    if (photoImage != null) {
      canvas.save();
      final photoCenter = Offset(photoX + photoSize / 2, photoY + photoSize / 2);
      final clipPath = Path()
        ..addOval(Rect.fromCenter(
          center: photoCenter,
          width: photoSize,
          height: photoSize,
        ));
      canvas.clipPath(clipPath);

      final srcRect = Rect.fromLTWH(
        0, 0,
        photoImage.width.toDouble(),
        photoImage.height.toDouble(),
      );
      final dstRect = Rect.fromLTWH(photoX, photoY, photoSize, photoSize);
      canvas.drawImageRect(photoImage, srcRect, dstRect, Paint());
      canvas.restore();

      // Photo border
      canvas.drawOval(
        Rect.fromLTWH(photoX, photoY, photoSize, photoSize),
        Paint()
          ..color = const Color(0xFFE0E0E0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      // Placeholder circle
      canvas.drawOval(
        Rect.fromLTWH(photoX, photoY, photoSize, photoSize),
        Paint()..color = const Color(0xFFE0E0E0),
      );
      _drawText(canvas, '?', photoX + photoSize / 2 - 20, photoY + photoSize / 2 - 30,
          fontSize: 48, color: const Color(0xFF9E9E9E));
    }

    // Right side content area
    const double contentX = photoX + photoSize + 24;
    double contentY = padding;

    // ANSR Logo (top-right)
    if (logoImage != null) {
      const double logoHeight = 40;
      final double logoWidth = logoHeight * (logoImage.width / logoImage.height);
      final srcRect = Rect.fromLTWH(
        0, 0,
        logoImage.width.toDouble(),
        logoImage.height.toDouble(),
      );
      final dstRect = Rect.fromLTWH(contentX, contentY, logoWidth, logoHeight);
      canvas.drawImageRect(logoImage, srcRect, dstRect, Paint());
      contentY += logoHeight + 16;
    }

    // Visitor Name (bold, large)
    contentY = _drawText(canvas, data.visitorName, contentX, contentY,
        fontSize: 32, fontWeight: FontWeight.bold);
    contentY += 8;

    // Date/Time
    contentY = _drawText(canvas, data.dateTime, contentX, contentY,
        fontSize: 22, color: const Color(0xFF616161));
    contentY += 6;

    // Meeting
    contentY = _drawText(canvas, 'Meeting: ${data.whomToMeet}', contentX, contentY,
        fontSize: 22, color: const Color(0xFF424242));
    contentY += 6;

    // Purpose
    _drawText(canvas, 'Purpose: ${data.purpose}', contentX, contentY,
        fontSize: 22, color: const Color(0xFF424242));

    // QR Code (bottom-left)
    if (data.qrData != null && data.qrData!.isNotEmpty) {
      const double qrSize = 130;
      final qrY = badgeHeight - qrSize - padding;

      final qrPainter = QrPainter(
        data: data.qrData!,
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: const QrEyeStyle(color: Color(0xFF000000)),
        dataModuleStyle: const QrDataModuleStyle(color: Color(0xFF000000)),
      );

      final qrImage = await qrPainter.toImage(qrSize);
      canvas.drawImage(qrImage, Offset(padding, qrY), Paint());
    }

    // Finalize
    final picture = recorder.endRecording();
    final img = await picture.toImage(badgeWidth.toInt(), badgeHeight.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static double _drawText(
    Canvas canvas,
    String text,
    double x,
    double y, {
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.normal,
    Color color = const Color(0xFF212121),
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: 500);
    textPainter.paint(canvas, Offset(x, y));
    return y + textPainter.height;
  }

  static Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
