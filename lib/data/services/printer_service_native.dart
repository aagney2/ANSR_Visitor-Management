import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:brother_printer/brother_printer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class SavedPrinter {
  final String ipAddress;
  final String modelName;

  const SavedPrinter({
    required this.ipAddress,
    this.modelName = 'Brother QL-820NWB',
  });

  Map<String, dynamic> toJson() => {
        'ipAddress': ipAddress,
        'modelName': modelName,
      };

  factory SavedPrinter.fromJson(Map<String, dynamic> json) => SavedPrinter(
        ipAddress: json['ipAddress'] as String,
        modelName: json['modelName'] as String? ?? 'Brother QL-820NWB',
      );
}

class DiscoveredPrinter {
  final String modelName;
  final String? ipAddress;
  final String source;
  final dynamic nativeDevice;

  const DiscoveredPrinter({
    required this.modelName,
    this.ipAddress,
    required this.source,
    this.nativeDevice,
  });
}

class PrinterService {
  static const _prefsKey = 'saved_printer';

  Future<List<DiscoveredPrinter>> discoverPrinters({int timeoutSeconds = 5}) async {
    try {
      debugPrint('[PrinterService] Scanning for printers ($timeoutSeconds s)...');
      final devices = await BrotherPrinter.searchDevices(delay: timeoutSeconds);
      debugPrint('[PrinterService] Found ${devices.length} printer(s)');
      return devices.map((d) {
        debugPrint('  -> ${d.modelName} @ ${d.ipAddress} (${d.source.name})');
        return DiscoveredPrinter(
          modelName: d.modelName,
          ipAddress: d.ipAddress,
          source: _sourceLabel(d.source),
          nativeDevice: d,
        );
      }).toList();
    } catch (e) {
      debugPrint('[PrinterService] Discovery error: $e');
      return [];
    }
  }

  Future<void> saveDiscoveredPrinter(DiscoveredPrinter device) async {
    final printer = SavedPrinter(
      ipAddress: device.ipAddress ?? '',
      modelName: device.modelName,
    );
    await savePrinter(printer);
  }

  Future<void> printBadge(Uint8List imageBytes) async {
    final saved = await getSavedPrinter();
    if (saved == null) {
      throw Exception('No printer configured. Please set up a printer in Settings.');
    }

    try {
      final pdfDoc = pw.Document();
      final image = pw.MemoryImage(imageBytes);

      pdfDoc.addPage(pw.Page(
        pageFormat: const PdfPageFormat(
          62 * PdfPageFormat.mm,
          90 * PdfPageFormat.mm,
          marginAll: 0,
        ),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ));

      final dir = await getTemporaryDirectory();
      final pdfPath = '${dir.path}/badge_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final pdfFile = File(pdfPath);
      await pdfFile.writeAsBytes(await pdfDoc.save());

      final device = BrotherDevice(
        source: BrotherDeviceSource.network,
        model: BRLMPrinterModelQL_820NWB,
        modelName: 'QL-820NWB',
        ipAddress: saved.ipAddress,
      );

      final labelSizesToTry = <BrotherLabelSize?>[
        BrotherLabelSize.QLRollW62RB,
        BrotherLabelSize.QLRollW62,
        BrotherLabelSize.QLDieCutW62H100,
        null,
      ];

      PlatformException? lastError;

      for (final labelSize in labelSizesToTry) {
        try {
          debugPrint('[PrinterService] Trying label size: ${labelSize?.name ?? "auto-detect"}');

          await BrotherPrinter.printPDF(
            path: pdfPath,
            device: device,
            labelSize: labelSize,
          );

          debugPrint('[PrinterService] Print succeeded with: ${labelSize?.name ?? "auto-detect"}');

          try { await pdfFile.delete(); } catch (_) {}
          return;
        } on PlatformException catch (e) {
          debugPrint('[PrinterService] Failed with ${labelSize?.name ?? "auto-detect"}: ${e.code}');
          lastError = e;

          if (e.code != 'BRPrintErrorCodeSetLabelSizeError') {
            try { await pdfFile.delete(); } catch (_) {}
            rethrow;
          }

          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      try { await pdfFile.delete(); } catch (_) {}
      throw lastError ?? Exception('Print failed: all label sizes rejected');
    } catch (e) {
      debugPrint('[PrinterService] Print error: $e');
      rethrow;
    }
  }

  Future<void> savePrinter(SavedPrinter printer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(printer.toJson()));
  }

  Future<SavedPrinter?> getSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json == null) return null;
    return SavedPrinter.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> clearPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<bool> hasPrinter() async {
    return (await getSavedPrinter()) != null;
  }

  static String _sourceLabel(BrotherDeviceSource source) {
    switch (source) {
      case BrotherDeviceSource.network:
        return 'WiFi';
      case BrotherDeviceSource.bluetooth:
        return 'Bluetooth';
      case BrotherDeviceSource.ble:
        return 'BLE';
      case BrotherDeviceSource.usb:
        return 'USB';
    }
  }
}
