import 'dart:typed_data';

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
  Future<List<DiscoveredPrinter>> discoverPrinters({int timeoutSeconds = 5}) async => [];

  Future<void> saveDiscoveredPrinter(DiscoveredPrinter device) async {}

  Future<void> printBadge(Uint8List imageBytes) async {
    throw UnsupportedError('Printing is not supported on web');
  }

  Future<void> savePrinter(SavedPrinter printer) async {}

  Future<SavedPrinter?> getSavedPrinter() async => null;

  Future<void> clearPrinter() async {}

  Future<bool> hasPrinter() async => false;
}
