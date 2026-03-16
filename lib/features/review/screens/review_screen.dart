import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/info_card.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../features/visitor_checkin/providers/checkin_provider.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkinProvider);
    final theme = Theme.of(context);

    ref.listen<CheckinState>(checkinProvider, (prev, next) {
      if (next.step == CheckinStep.success) {
        context.go('/success');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Submit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/details'),
        ),
      ),
      body: LoadingOverlay(
        isLoading: state.isLoading,
        message: 'Submitting your check-in...\nThis may take a moment.',
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SectionHeader(
                title: 'Review your details',
                subtitle: 'Please confirm everything looks correct',
              ),
              if (state.errorMessage != null)
                ErrorBanner(
                  message: state.errorMessage!,
                  onDismiss: () =>
                      ref.read(checkinProvider.notifier).clearError(),
                  onRetry: () =>
                      ref.read(checkinProvider.notifier).submit(),
                ),
              InfoCard(
                header: Row(
                  children: [
                    Icon(Icons.person,
                        color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Personal Information',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                rows: [
                  InfoCardRow(
                    label: 'Full Name',
                    value: state.name,
                    icon: Icons.person_outline,
                  ),
                  InfoCardRow(
                    label: 'Email',
                    value: state.email,
                    icon: Icons.email_outlined,
                  ),
                  InfoCardRow(
                    label: 'Phone',
                    value: state.phoneNumber,
                    icon: Icons.phone_outlined,
                  ),
                  InfoCardRow(
                    label: 'Company',
                    value: state.company,
                    icon: Icons.business_outlined,
                  ),
                  InfoCardRow(
                    label: 'Location',
                    value: state.location,
                    icon: Icons.location_on_outlined,
                  ),
                  InfoCardRow(
                    label: 'Laptop Serial No.',
                    value: state.serialNumber,
                    icon: Icons.laptop_outlined,
                  ),
                  if (state.badgeNumber != null &&
                      state.badgeNumber!.isNotEmpty)
                    InfoCardRow(
                      label: 'Badge Number',
                      value: state.badgeNumber,
                      icon: Icons.badge_outlined,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              InfoCard(
                header: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Visit Information',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                rows: [
                  if (state.purpose != null)
                    InfoCardRow(
                      label: 'Purpose',
                      value: state.purpose,
                      icon: Icons.category_outlined,
                    ),
                  InfoCardRow(
                    label: 'Whom to Meet',
                    value: state.selectedWhomToMeet?.name ?? '—',
                    icon: Icons.handshake_outlined,
                  ),
                  InfoCardRow(
                    label: 'Status',
                    value: state.isReturningVisitor
                        ? 'Returning Visitor'
                        : 'New Visitor',
                    icon: Icons.verified_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Photo preview
              if (state.photoFile != null) ...[
                Text(
                  'Photo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    state.photoFile!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Signature preview
              if (state.signatureBytes != null) ...[
                Text(
                  'Signature',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.memory(
                      state.signatureBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              PrimaryButton(
                label: 'Submit Check-In',
                icon: Icons.check_circle_outline,
                isLoading: state.isLoading,
                onPressed: state.isLoading
                    ? null
                    : () => ref.read(checkinProvider.notifier).submit(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
