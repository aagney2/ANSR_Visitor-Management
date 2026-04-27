import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../data/services/badge_generator.dart';
import '../../../features/visitor_checkin/providers/checkin_provider.dart';
import '../../../features/printer/providers/printer_provider.dart';
import '../../../shared/providers/app_providers.dart';

class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({super.key});

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen> {
  String? _printStatus;
  bool _isPrinting = false;
  Timer? _redirectTimer;
  int _countdown = 5;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      Future.microtask(() => _autoPrintBadge());
      _startRedirectTimer();
    }
  }

  void _startRedirectTimer() {
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        _goHome();
      }
    });
  }

  void _goHome() {
    if (!mounted) return;
    ref.read(checkinProvider.notifier).reset();
    context.go(kIsWeb ? '/phone' : '/');
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  Future<void> _autoPrintBadge() async {
    final service = ref.read(printerServiceProvider);
    final hasPrinter = await service.hasPrinter();
    if (!hasPrinter) return;

    await _printBadge();
  }

  Future<void> _printBadge() async {
    if (_isPrinting) return;
    setState(() {
      _isPrinting = true;
      _printStatus = 'Printing badge...';
    });

    try {
      final state = ref.read(checkinProvider);
      final config = ref.read(clientConfigProvider);
      final now = DateTime.now();

      final badgeData = BadgeData(
        visitorName: state.name ?? 'Visitor',
        dateTime: DateFormat('MMM d, yyyy h:mm a').format(now),
        whomToMeet: state.selectedWhomToMeet?.name ?? '',
        purpose: state.purpose ?? 'Visitor',
        qrData: 'KVM:${state.createdVisitEntryId ?? ""}|${state.name ?? ""}|${state.phoneNumber}',
        photoBytes: state.photoBytes,
        photoUrl: state.photoAttachment?.url ?? state.visitor?.photoUrl,
        clientImageUrl: config?.clientImageUrl,
        clientName: config?.clientName ?? '',
      );

      final imageBytes = await BadgeGenerator.generateBadge(badgeData);
      final service = ref.read(printerServiceProvider);
      await service.printBadge(imageBytes);

      if (mounted) {
        setState(() {
          _printStatus = 'Badge printed!';
          _isPrinting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _printStatus = 'Print failed. Please check printer connection.';
          _isPrinting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkinProvider);
    final theme = Theme.of(context);
    final now = DateTime.now();
    const brandColor = Color(0xFF005465);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(48),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 56,
                  color: Color(0xFF4CAF50),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                    duration: 800.ms,
                  ),
              const SizedBox(height: 32),
              Text(
                'Check-In Successful!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: brandColor,
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: 12),
              Text(
                'Welcome, ${state.name ?? "Visitor"}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: DateFormat('EEEE, MMM d, yyyy').format(now),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.access_time_outlined,
                      label: 'Time',
                      value: DateFormat('h:mm a').format(now),
                    ),
                    if (state.selectedWhomToMeet != null) ...[
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Meeting',
                        value: state.selectedWhomToMeet!.name,
                      ),
                    ],
                    if (state.badgeNumber != null &&
                        state.badgeNumber!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Pass No.',
                        value: state.badgeNumber!,
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              if (_printStatus != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: brandColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isPrinting)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: brandColor,
                          ),
                        )
                      else
                        Icon(
                          _printStatus!.contains('failed')
                              ? Icons.print_disabled
                              : Icons.print,
                          color: brandColor,
                          size: 18,
                        ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _printStatus!,
                          style: const TextStyle(
                            color: brandColor,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_printStatus!.contains('failed')) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _printBadge,
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              color: brandColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ],
              const Spacer(flex: 3),
              if (kIsWeb)
                Text(
                  'You may now close this page',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF999999),
                    fontSize: 14,
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
              if (!kIsWeb) ...[
                Text(
                  'Redirecting in $_countdown seconds...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF999999),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _goHome,
                    child: const Text('Done'),
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF005465), size: 18),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
