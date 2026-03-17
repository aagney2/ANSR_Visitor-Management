import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/printer_service.dart';

final printerServiceProvider = Provider<PrinterService>((ref) {
  return PrinterService();
});

final savedPrinterProvider = FutureProvider<SavedPrinter?>((ref) async {
  final service = ref.read(printerServiceProvider);
  return service.getSavedPrinter();
});
