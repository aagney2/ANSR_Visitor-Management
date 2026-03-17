import 'dart:convert';
import 'dart:io';
import 'package:brother_printer/brother_printer.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPrinter {
  final String ipAddress;
  final String modelName;
  final String? macAddress;
  final String? nodeName;

  const SavedPrinter({
    required this.ipAddress,
    required this.modelName,
    this.macAddress,
    this.nodeName,
  });

  Map<String, dynamic> toJson() => {
        'ipAddress': ipAddress,
        'modelName': modelName,
        'macAddress': macAddress,
        'nodeName': nodeName,
      };

  factory SavedPrinter.fromJson(Map<String, dynamic> json) => SavedPrinter(
        ipAddress: json['ipAddress'] as String,
        modelName: json['modelName'] as String,
        macAddress: json['macAddress'] as String?,
        nodeName: json['nodeName'] as String?,
      );
}

class PrinterService {
  static const _prefsKey = 'saved_printer';

  /// Discover Brother printers on the local network.
  Future<List<BrotherDevice>> discoverPrinters() async {
    try {
      final devices = await BrotherPrinter.searchDevices(delay: 5);
      return devices;
    } catch (e) {
      debugPrint('[PrinterService] Discovery error: $e');
      return [];
    }
  }

  /// Print a badge image (PNG bytes) by converting to a temporary PDF-like
  /// image file and sending to the printer.
  Future<void> printBadge(Uint8List imageBytes) async {
    final saved = await getSavedPrinter();
    if (saved == null) {
      throw Exception('No printer configured. Please set up a printer in Settings.');
    }

    try {
      // Save image to a temp file so we can print it
      final dir = await getTemporaryDirectory();
      final tempFile = File('${dir.path}/badge_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(imageBytes);

      final device = BrotherDevice(
        source: BrotherDeviceSource.network,
        model: BRLMPrinterModelQL_820NWB,
        modelName: 'QL-820NWB',
        ipAddress: saved.ipAddress,
      );

      await BrotherPrinter.printPDF(
        path: tempFile.path,
        device: device,
        labelSize: BrotherLabelSize.QLRollW62,
      );

      // Clean up
      try { await tempFile.delete(); } catch (_) {}

      debugPrint('[PrinterService] Print job sent successfully');
    } catch (e) {
      debugPrint('[PrinterService] Print error: $e');
      rethrow;
    }
  }

  /// Save a selected printer to local storage.
  Future<void> savePrinter(SavedPrinter printer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(printer.toJson()));
  }

  /// Get the saved printer, if any.
  Future<SavedPrinter?> getSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json == null) return null;
    return SavedPrinter.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Clear the saved printer.
  Future<void> clearPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  /// Check if a printer is configured.
  Future<bool> hasPrinter() async {
    return (await getSavedPrinter()) != null;
  }
}
