import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../shared/providers/app_providers.dart';

class BrandingScreen extends ConsumerWidget {
  const BrandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(clientConfigProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final touchlessUrl = config?.touchlessCheckinUrl ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                    onPressed: () => context.go('/printer-settings'),
                    tooltip: 'Printer Settings',
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.03),

                    Image.asset(
                      'assets/images/ansr_logo_full.png',
                      width: size.width * 0.55,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Text(
                        config?.clientName ?? 'ANSR',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms),

                    const SizedBox(height: 24),

                    Text(
                      'Welcomes you',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF333333),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                    const SizedBox(height: 28),

                    if (touchlessUrl.isNotEmpty) ...[
                      Text(
                        'Scan QR',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: touchlessUrl,
                          version: QrVersions.auto,
                          size: size.width * 0.4,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF000000),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                      const SizedBox(height: 16),

                      Text(
                        'or',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF999999),
                        ),
                      ).animate().fadeIn(delay: 500.ms),

                      const SizedBox(height: 8),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF666666),
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: 'Open "'),
                              TextSpan(
                                text: touchlessUrl,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    '" on your\nmobile browser to check-in\nusing your mobile phone',
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                      const SizedBox(height: 16),

                      Text(
                        'or',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF999999),
                        ),
                      ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 16),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () => context.go('/phone'),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded, size: 20),
                            SizedBox(width: 10),
                            Text('Check In'),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 500.ms)
                        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Powered by Kelsa',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFAAAAAA),
                      fontSize: 12,
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                  GestureDetector(
                    onTap: () => context.go('/checkout'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Check Out',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
