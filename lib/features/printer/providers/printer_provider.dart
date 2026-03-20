import 'package:brother_printer/brother_printer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/printer_service.dart';

final printerServiceProvider = Provider<PrinterService>((ref) {
  return PrinterService();
});

final savedPrinterProvider = FutureProvider<SavedPrinter?>((ref) async {
  final service = ref.read(printerServiceProvider);
  return service.getSavedPrinter();
});

final discoveredPrintersProvider =
    StateNotifierProvider<DiscoveredPrintersNotifier, AsyncValue<List<BrotherDevice>>>(
  (ref) => DiscoveredPrintersNotifier(ref.read(printerServiceProvider)),
);

class DiscoveredPrintersNotifier extends StateNotifier<AsyncValue<List<BrotherDevice>>> {
  final PrinterService _service;

  DiscoveredPrintersNotifier(this._service) : super(const AsyncValue.data([]));

  Future<void> scan() async {
    state = const AsyncValue.loading();
    try {
      final devices = await _service.discoverPrinters(timeoutSeconds: 5);
      state = AsyncValue.data(devices);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
