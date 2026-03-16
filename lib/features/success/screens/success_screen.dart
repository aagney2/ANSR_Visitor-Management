import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../features/visitor_checkin/providers/checkin_provider.dart';

class SuccessScreen extends ConsumerWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
