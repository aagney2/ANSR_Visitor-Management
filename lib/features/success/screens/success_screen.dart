import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../data/services/badge_generator.dart';
import '../../../features/visitor_checkin/providers/checkin_provider.dart';
import '../../../features/printer/providers/printer_provider.dart';

class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({super.key});

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen> {
  String? _printStatus;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _autoPrintBadge());
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
      final now = DateTime.now();

      final badgeData = BadgeData(
        visitorName: state.name ?? 'Visitor',
        dateTime: DateFormat('MMM d, yyyy h:mm a').format(now),
        whomToMeet: state.selectedWhomToMeet?.name ?? '',
        purpose: state.purpose ?? 'Visitor',
        qrData: 'ANSR-VISITOR:${state.createdVisitEntryId ?? ""}|${state.name ?? ""}|${state.phoneNumber}',
        photoFile: state.photoFile,
        photoUrl: state.photoAttachment?.url ?? state.visitor?.photoUrl,
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

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF00C853),
              const Color(0xFF00C853).withValues(alpha: 0.85),
              const Color(0xFF00E676).withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(48),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 56,
                    color: Color(0xFF00C853),
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
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 12),
                Text(
                  'Welcome, ${state.name ?? "Visitor"}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
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
                      color: Colors.white.withValues(alpha: 0.15),
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
                              color: Colors.white,
                            ),
                          )
                        else
                          Icon(
                            _printStatus!.contains('failed')
                                ? Icons.print_disabled
                                : Icons.print,
                            color: Colors.white,
                            size: 18,
                          ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _printStatus!,
                            style: const TextStyle(
                              color: Colors.white,
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
                                color: Colors.white,
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
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF00C853),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      ref.read(checkinProvider.notifier).reset();
                      context.go('/');
                    },
                    child: const Text('Done'),
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      ref.read(checkinProvider.notifier).reset();
                      context.go('/phone');
                    },
                    child: const Text('New Check-In'),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                const SizedBox(height: 32),
              ],
            ),
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
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
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
