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

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _scanForPrinters());
  }

  Future<void> _scanForPrinters() async {
    setState(() => _isScanning = true);
    await ref.read(discoveredPrintersProvider.notifier).scan();
    if (mounted) setState(() => _isScanning = false);
  }

  Future<void> _selectPrinter(DiscoveredPrinter device) async {
    final service = ref.read(printerServiceProvider);
    await service.saveDiscoveredPrinter(device);
    ref.invalidate(savedPrinterProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Printer saved: ${device.modelName} @ ${device.ipAddress}'),
          backgroundColor: const Color(0xFF005465),
        ),
      );
    }
  }

  Future<void> _savePrinterWithIp(String ip) async {
    final service = ref.read(printerServiceProvider);
    await service.savePrinter(SavedPrinter(ipAddress: ip));
    ref.invalidate(savedPrinterProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Printer saved: $ip'),
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
      await _savePrinterWithIp(ip);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savedPrinter = ref.watch(savedPrinterProvider);
    final discoveredPrinters = ref.watch(discoveredPrintersProvider);

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
              subtitle:
                  'Configure the Brother QL-820NWB for badge printing',
            ),

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
                        const Icon(Icons.info_outline,
                            color: Color(0xFFF57C00)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No printer configured. Select a printer below or enter an IP manually.',
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
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF2E7D32), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connected Printer',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
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
                ).animate().fadeIn(duration: 300.ms);
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Text(
                  'Available Printers',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh, size: 22),
                        onPressed: _scanForPrinters,
                        tooltip: 'Scan again',
                      ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Printers found on your network',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 12),

            discoveredPrinters.when(
              data: (devices) {
                if (devices.isEmpty && !_isScanning) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.print_disabled,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No printers found',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Make sure your printer is on and connected\nto the same WiFi network.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Scan Again'),
                          onPressed: _scanForPrinters,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: devices.map((device) {
                    final currentIp = savedPrinter.valueOrNull?.ipAddress;
                    final isSelected = device.ipAddress == currentIp;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE0F2F1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF005465)
                              : const Color(0xFFE0E0E0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF005465)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.print,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF757575),
                          ),
                        ),
                        title: Text(
                          device.modelName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${device.ipAddress ?? "N/A"} · ${device.source}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF757575),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF005465))
                            : const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Color(0xFFBDBDBD)),
                        onTap: isSelected ? null : () => _selectPrinter(device),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Scanning for printers...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              error: (e, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Scan failed: $e',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.red.shade700),
                ),
              ),
            ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Enter IP Address Manually'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: _manualEntry,
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it works',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. The app automatically scans for Brother printers on your WiFi network\n'
                    '2. Tap a printer to select it\n'
                    '3. Badges will auto-print after each check-in\n\n'
                    'If your printer doesn\'t appear, make sure it\'s powered on and connected to the same WiFi network. You can also enter the IP manually.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF757575),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
