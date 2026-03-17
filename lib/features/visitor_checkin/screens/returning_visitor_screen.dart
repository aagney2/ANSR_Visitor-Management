import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/info_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../providers/checkin_provider.dart';

class ReturningVisitorScreen extends ConsumerWidget {
  const ReturningVisitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkinProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/phone'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.waving_hand_rounded,
                      color: theme.colorScheme.secondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF757575),
                          ),
                        ),
                        Text(
                          state.visitor?.name ?? 'Visitor',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Your saved details',
                subtitle: 'Review your information below. You can edit any details before checking in.',
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (state.visitor?.photoUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 240),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                state.visitor!.photoUrl!,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 64,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                        ),
                      InfoCard(
                        rows: [
                          InfoCardRow(
                            label: 'Full Name',
                            value: state.visitor?.name,
                            icon: Icons.person_outline,
                          ),
                          InfoCardRow(
                            label: 'Email',
                            value: state.visitor?.email,
                            icon: Icons.email_outlined,
                          ),
                          InfoCardRow(
                            label: 'Phone',
                            value: state.visitor?.phoneNumber,
                            icon: Icons.phone_outlined,
                          ),
                          InfoCardRow(
                            label: 'Company',
                            value: state.visitor?.company,
                            icon: Icons.business_outlined,
                          ),
                          InfoCardRow(
                            label: 'Location',
                            value: state.visitor?.location,
                            icon: Icons.location_on_outlined,
                          ),
                          InfoCardRow(
                            label: 'Laptop Serial Number',
                            value: state.visitor?.serialNumber,
                            icon: Icons.laptop_outlined,
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Confirm & Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  ref.read(checkinProvider.notifier).proceedFromReturningVisitor();
                  context.go('/purpose');
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit My Details'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: theme.colorScheme.primary),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    ref.read(checkinProvider.notifier).proceedFromReturningVisitor();
                    context.go('/details');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
