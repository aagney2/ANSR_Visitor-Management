import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/services/printer_service.dart';
import '../../../shared/widgets/section_header.dart';
import '../providers/printer_provider.dart';

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() =>
      _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState
    extends ConsumerState<PrinterSettingsScreen> {
  bool _isScanning = false;
  List<DiscoveredPrinterInfo> _discoveredPrinters = [];
  String? _scanError;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _scanError = null;
      _discoveredPrinters = [];
    });

    try {
      final service = ref.read(printerServiceProvider);
      final devices = await service.discoverPrinters();

      final printers = devices
          .where((d) => d.ipAddress != null && d.ipAddress!.isNotEmpty)
          .map((d) => DiscoveredPrinterInfo(
                ipAddress: d.ipAddress!,
                modelName: d.modelName,
                macAddress: d.macAddress,
                nodeName: d.nodeName,
              ))
          .toList();

      setState(() {
        _discoveredPrinters = printers;
        _isScanning = false;
        if (printers.isEmpty) {
          _scanError = 'No printers found on this network.\n'
              'Make sure the printer is on and connected to the same WiFi.';
        }
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _scanError = 'Scan failed: $e';
      });
    }
  }

  Future<void> _selectPrinter(DiscoveredPrinterInfo printer) async {
    final service = ref.read(printerServiceProvider);
    await service.savePrinter(SavedPrinter(
      ipAddress: printer.ipAddress,
      modelName: printer.modelName,
      macAddress: printer.macAddress,
      nodeName: printer.nodeName,
    ));
    ref.invalidate(savedPrinterProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Printer saved: ${printer.modelName} (${printer.ipAddress})'),
          backgroundColor: const Color(0xFF005465),
        ),
      );
    }
  }

  Future<void> _removePrinter() async {
    final service = ref.read(printerServiceProvider);
    await service.clearPrinter();
    ref.invalidate(savedPrinterProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printer removed')),
      );
    }
  }

  Future<void> _manualEntry() async {
    final controller = TextEditingController();
    final ip = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Printer IP'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '192.168.1.100',
            labelText: 'IP Address',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ip != null && ip.isNotEmpty) {
      await _selectPrinter(DiscoveredPrinterInfo(
        ipAddress: ip,
        modelName: 'Brother QL-820NWB',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savedPrinter = ref.watch(savedPrinterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SectionHeader(
              title: 'Badge Printer',
              subtitle: 'Configure the Brother label printer for this device',
            ),

            // Saved printer card
            savedPrinter.when(
              data: (printer) {
                if (printer == null) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFCC02)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFF57C00)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No printer configured. Badges will not print after check-in.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms);
                }

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF81C784)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.print, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  printer.modelName,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  printer.ipAddress,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Color(0xFFD32F2F)),
                            onPressed: _removePrinter,
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // Scan section
            Row(
              children: [
                Text(
                  'Available Printers',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: _isScanning
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : const Icon(Icons.refresh, size: 18),
                  label: Text(_isScanning ? 'Scanning...' : 'Rescan'),
                  onPressed: _isScanning ? null : _startScan,
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_isScanning)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Searching for printers on this network...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),

            if (!_isScanning && _scanError != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.wifi_find, size: 48, color: Color(0xFF9E9E9E)),
                    const SizedBox(height: 12),
                    Text(
                      _scanError!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),

            if (!_isScanning)
              ..._discoveredPrinters.map((printer) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.print_outlined,
                          color: theme.colorScheme.primary),
                      title: Text(printer.modelName),
                      subtitle: Text(printer.ipAddress),
                      trailing: FilledButton(
                        onPressed: () => _selectPrinter(printer),
                        child: const Text('Select'),
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms)),

            const SizedBox(height: 16),

            // Manual entry option
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Enter IP Manually'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: _manualEntry,
            ),
          ],
        ),
      ),
    );
  }
}

class DiscoveredPrinterInfo {
  final String ipAddress;
  final String modelName;
  final String? macAddress;
  final String? nodeName;

  const DiscoveredPrinterInfo({
    required this.ipAddress,
    required this.modelName,
    this.macAddress,
    this.nodeName,
  });
}
