import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/kelsa_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../providers/checkin_provider.dart';
import '../providers/visitor_type_provider.dart';

class PurposeScreen extends ConsumerStatefulWidget {
  const PurposeScreen({super.key});

  @override
  ConsumerState<PurposeScreen> createState() => _PurposeScreenState();
}

class _PurposeScreenState extends ConsumerState<PurposeScreen> {
  KelsaFieldOption? _selected;

  static const _purposeIcons = {
    'visitor': Icons.person_outline,
    'interview': Icons.work_outline,
    'new-joiner': Icons.person_add_outlined,
    'new joiner': Icons.person_add_outlined,
    'employee': Icons.badge_outlined,
    'client': Icons.handshake_outlined,
    'contractor': Icons.engineering_outlined,
    'vendor': Icons.store_outlined,
    'meeting': Icons.groups_outlined,
    'others': Icons.more_horiz_outlined,
  };

  IconData _iconFor(String name) {
    return _purposeIcons[name.toLowerCase()] ?? Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    final vtState = ref.watch(visitorTypeProvider);
    final checkinState = ref.watch(checkinProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purpose of Visit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go(
            checkinState.isReturningVisitor ? '/returning-visitor' : '/phone',
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Purpose of your visit',
                subtitle: 'Please select the reason for your visit today',
              ),
              const SizedBox(height: 8),
              Expanded(
                child: vtState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vtState.error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(vtState.error!,
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => ref
                                      .read(visitorTypeProvider.notifier)
                                      .reload(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: vtState.options.length,
                            itemBuilder: (context, index) {
                              final option = vtState.options[index];
                              final isSelected =
                                  _selected?.id == option.id;
                              return _PurposeTile(
                                purpose: option.name,
                                icon: _iconFor(option.name),
                                isSelected: isSelected,
                                onTap: () =>
                                    setState(() => _selected = option),
                              )
                                  .animate()
                                  .fadeIn(
                                    delay:
                                        Duration(milliseconds: 80 * index),
                                    duration: 300.ms,
                                  )
                                  .scale(
                                    begin: const Offset(0.9, 0.9),
                                    end: const Offset(1, 1),
                                    delay:
                                        Duration(milliseconds: 80 * index),
                                  );
                            },
                          ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: _selected != null
                    ? () {
                        ref
                            .read(checkinProvider.notifier)
                            .setPurpose(_selected!.name,
                                optionId: _selected!.id);
                        ref
                            .read(checkinProvider.notifier)
                            .proceedFromPurpose();
                        context.go('/employee-select');
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PurposeTile extends StatelessWidget {
  final String purpose;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PurposeTile({
    required this.purpose,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : const Color(0xFFE8E8E8),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? theme.colorScheme.primary
                    : const Color(0xFF757575),
              ),
              const SizedBox(height: 8),
              Text(
                purpose,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : const Color(0xFF424242),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
