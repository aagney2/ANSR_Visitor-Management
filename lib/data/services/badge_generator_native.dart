import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  /// Generates a visitor badge matching the Vizmo reference layout.
  ///
  /// Two-column landscape layout (1060×720):
  ///   LEFT COLUMN:  [Photo circle]  then  [QR code]
  ///   RIGHT COLUMN: [ANSR logo + text]  then  [Name, Date, Meeting, Purpose]
  ///
  /// Rotated 90° CW for the Brother QL-820NWB 62mm roll.
  static Future<Uint8List> generateBadge(BadgeData data) async {
    const double W = 1060;
    const double H = 720;

    const double leftColW = 390;
    const double gutter = 20;
    const double rightColX = leftColW + gutter;
    final double rightColW = W - rightColX - 30;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, W, H));
    canvas.drawRect(Rect.fromLTWH(0, 0, W, H), Paint()..color = Colors.white);

    // --- Load assets ---
    final photoImage = await _loadPhoto(data);
    ui.Image? logoImage;
    try {
      if (data.clientImageUrl != null && data.clientImageUrl!.isNotEmpty) {
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(data.clientImageUrl!));
        final response = await request.close();
        final bytes = await consolidateHttpClientResponseBytes(response);
        logoImage = await _decodeImage(bytes);
        client.close();
      }
    } catch (e) {
      debugPrint('[BadgeGen] ERROR loading client logo: $e');
    }

    // =================================================================
    // LEFT COLUMN: Photo (top) + QR code (bottom)
    // =================================================================

    const double photoSize = 350;
    final double photoX = (leftColW - photoSize) / 2;
    const double photoY = 15;

    if (photoImage != null) {
      await _drawCircularPhoto(canvas, photoImage, photoX, photoY, photoSize);
    } else {
      _drawPhotoPlaceholder(canvas, photoX, photoY, photoSize);
    }

    // QR code below photo
    const double qrSize = 240;
    final double qrX = (leftColW - qrSize) / 2;
    const double qrY = photoY + photoSize + 20;

    if (data.qrData != null && data.qrData!.isNotEmpty) {
      final qrPainter = QrPainter(
        data: data.qrData!,
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: const QrEyeStyle(color: Color(0xFF000000)),
        dataModuleStyle: const QrDataModuleStyle(color: Color(0xFF000000)),
      );
      final qrImage = await qrPainter.toImage(qrSize);
      canvas.drawImage(qrImage, Offset(qrX, qrY), Paint());
    }

    // =================================================================
    // RIGHT COLUMN: Client branding + visitor info
    // =================================================================
    final double photoCenterY = photoY + photoSize / 2;

    if (logoImage != null) {
      final double logoAspect = logoImage.width / logoImage.height;
      const double logoW = 480;
      final double logoH = logoW / logoAspect;

      final double logoX = rightColX + (rightColW - logoW) / 2;
      final double logoY = photoCenterY - logoH / 2 - 30;

      canvas.drawImageRect(
        logoImage,
        Rect.fromLTWH(
            0, 0, logoImage.width.toDouble(), logoImage.height.toDouble()),
        Rect.fromLTWH(logoX, logoY, logoW, logoH),
        Paint()..filterQuality = FilterQuality.high,
      );
    } else if (data.clientName.isNotEmpty) {
      _drawText(canvas, data.clientName, rightColX + 20, photoCenterY - 40,
          fontSize: 64, fontWeight: FontWeight.bold, maxWidth: rightColW - 20);
    }

    // Visitor info — right column, vertically centered in lower half
    // Shifted right with extra padding, and positioned higher
    final double textLeftPad = rightColX + 20;
    final double textMaxW = rightColW - 20;
    double rY = photoCenterY + photoSize * 0.28; // starts just below photo center

    // Visitor Name (large, bold)
    rY = _drawText(canvas, data.visitorName, textLeftPad, rY,
        fontSize: 72, fontWeight: FontWeight.bold, maxWidth: textMaxW);
    rY += 20;

    // Date/Time
    rY = _drawText(canvas, data.dateTime, textLeftPad, rY,
        fontSize: 50, color: const Color(0xFF444444), maxWidth: textMaxW);
    rY += 16;

    // Meeting
    rY = _drawText(canvas, 'Meeting: ${data.whomToMeet}', textLeftPad, rY,
        fontSize: 50, fontWeight: FontWeight.w600, maxWidth: textMaxW);
    rY += 16;

    // Purpose
    _drawText(canvas, 'Purpose: ${data.purpose}', textLeftPad, rY,
        fontSize: 50, fontWeight: FontWeight.w600, maxWidth: textMaxW);

    // --- Generate landscape image ---
    final picture = recorder.endRecording();
    final landscapeImg = await picture.toImage(W.toInt(), H.toInt());

    // --- Rotate 90° CW for the 62mm roll feed direction ---
    const double rotW = H; // 720
    const double rotH = W; // 1060
    final rotRecorder = ui.PictureRecorder();
    final rotCanvas = Canvas(rotRecorder, Rect.fromLTWH(0, 0, rotW, rotH));
    rotCanvas.translate(rotW, 0);
    rotCanvas.rotate(3.14159265 / 2);
    rotCanvas.drawImage(landscapeImg, Offset.zero, Paint());

    final rotPicture = rotRecorder.endRecording();
    final rotImg = await rotPicture.toImage(rotW.toInt(), rotH.toInt());
    final byteData = await rotImg.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Future<ui.Image?> _loadPhoto(BadgeData data) async {
    if (data.photoBytes != null) {
      debugPrint('[BadgeGen] Using photoBytes: ${data.photoBytes!.length} bytes');
      try {
        return await _decodeImage(data.photoBytes!);
      } catch (e) {
        debugPrint('[BadgeGen] ERROR decoding photoBytes: $e');
      }
    }

    if (data.photoUrl != null && data.photoUrl!.isNotEmpty) {
      debugPrint('[BadgeGen] Downloading photo from URL');
      try {
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(data.photoUrl!));
        final response = await request.close();
        final bytes = await consolidateHttpClientResponseBytes(response);
        debugPrint('[BadgeGen] Downloaded ${bytes.length} bytes');
        final img = await _decodeImage(bytes);
        debugPrint('[BadgeGen] Photo decoded: ${img.width}x${img.height}');
        client.close();
        return img;
      } catch (e) {
        debugPrint('[BadgeGen] ERROR downloading photo: $e');
      }
    }

    debugPrint('[BadgeGen] No photo available');
    return null;
  }

  static Future<void> _drawCircularPhoto(
      Canvas canvas, ui.Image photo, double x, double y, double size) async {
    final center = Offset(x + size / 2, y + size / 2);

    // Dither the photo for proper halftone rendering on thermal printer
    final dithered = await _ditherImage(photo);

    canvas.save();
    canvas.clipPath(Path()
      ..addOval(Rect.fromCenter(center: center, width: size, height: size)));

    final imgW = dithered.width.toDouble();
    final imgH = dithered.height.toDouble();
    final minDim = imgW < imgH ? imgW : imgH;
    final scale = size / minDim;
    final drawW = imgW * scale;
    final drawH = imgH * scale;
    canvas.drawImageRect(
      dithered,
      Rect.fromLTWH(0, 0, imgW, imgH),
      Rect.fromLTWH(
          x + (size - drawW) / 2, y + (size - drawH) / 2, drawW, drawH),
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();

    canvas.drawOval(
      Rect.fromCenter(center: center, width: size, height: size),
      Paint()
        ..color = const Color(0xFF005465)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  /// Floyd-Steinberg dithering: converts a photo to a halftone black-and-white
  /// image that looks like the Vizmo badge (newspaper-style dots).
  static Future<ui.Image> _ditherImage(ui.Image src) async {
    final w = src.width;
    final h = src.height;
    final byteData = await src.toByteData(format: ui.ImageByteFormat.rawRgba);
    final pixels = byteData!.buffer.asUint8List();

    // Convert to grayscale with reduced contrast and brightness boost
    // to preserve face detail and background in thermal dithering
    final gray = Float64List(w * h);
    for (int i = 0; i < w * h; i++) {
      final r = pixels[i * 4];
      final g = pixels[i * 4 + 1];
      final b = pixels[i * 4 + 2];
      gray[i] = (0.299 * r + 0.587 * g + 0.114 * b + 15).clamp(0, 255);
    }

    // Floyd-Steinberg dithering
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final idx = y * w + x;
        final oldVal = gray[idx];
        final newVal = oldVal > 128 ? 255.0 : 0.0;
        gray[idx] = newVal;
        final err = oldVal - newVal;

        if (x + 1 < w) gray[idx + 1] += err * 7 / 16;
        if (y + 1 < h) {
          if (x > 0) gray[(y + 1) * w + x - 1] += err * 3 / 16;
          gray[(y + 1) * w + x] += err * 5 / 16;
          if (x + 1 < w) gray[(y + 1) * w + x + 1] += err * 1 / 16;
        }
      }
    }

    // Write dithered result back to RGBA
    final output = Uint8List(w * h * 4);
    for (int i = 0; i < w * h; i++) {
      final v = gray[i].clamp(0, 255).toInt();
      output[i * 4] = v;
      output[i * 4 + 1] = v;
      output[i * 4 + 2] = v;
      output[i * 4 + 3] = 255;
    }

    final descriptor = ui.ImageDescriptor.raw(
      await ui.ImmutableBuffer.fromUint8List(output),
      width: w,
      height: h,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  static void _drawPhotoPlaceholder(
      Canvas canvas, double x, double y, double size) {
    final center = Offset(x + size / 2, y + size / 2);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size, height: size),
      Paint()..color = const Color(0xFFE0E0E0),
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size, height: size),
      Paint()
        ..color = const Color(0xFFBDBDBD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '?',
        style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9E9E9E)),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(canvas,
        Offset(center.dx - iconPainter.width / 2,
            center.dy - iconPainter.height / 2));
  }

  static double _drawText(
    Canvas canvas,
    String text,
    double x,
    double y, {
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.normal,
    Color color = const Color(0xFF212121),
    double maxWidth = 500,
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
      maxLines: 2,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: maxWidth);
    textPainter.paint(canvas, Offset(x, y));
    return y + textPainter.height;
  }

  static Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
