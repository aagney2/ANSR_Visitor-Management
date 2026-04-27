import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/kelsa_field.dart';
import '../../../shared/widgets/branded_header.dart';
import '../providers/checkin_provider.dart';
import '../providers/visitor_type_provider.dart';

class PurposeScreen extends ConsumerStatefulWidget {
  const PurposeScreen({super.key});

  @override
  ConsumerState<PurposeScreen> createState() => _PurposeScreenState();
}

class _PurposeScreenState extends ConsumerState<PurposeScreen> {
  KelsaFieldOption? _selected;

  @override
  Widget build(BuildContext context) {
    final vtState = ref.watch(visitorTypeProvider);
    final checkinState = ref.watch(checkinProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BrandedHeader(),

            const SizedBox(height: 16),

            Text(
              'Purpose of your visit',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 32),

            // Purpose options
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
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 2.8,
                            ),
                            itemCount: vtState.options.length,
                            itemBuilder: (context, index) {
                              final option = vtState.options[index];
                              final isSelected = _selected?.id == option.id;
                              return _PurposeTile(
                                purpose: option.name,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() => _selected = option);
                                  ref
                                      .read(checkinProvider.notifier)
                                      .setPurpose(option.name,
                                          optionId: option.id);
                                  ref
                                      .read(checkinProvider.notifier)
                                      .proceedFromPurpose();
                                  context.go('/employee-select');
                                },
                              )
                                  .animate()
                                  .fadeIn(
                                    delay:
                                        Duration(milliseconds: 80 * index),
                                    duration: 300.ms,
                                  );
                            },
                          ),
                        ),
            ),

            // Back button at bottom left
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go(
                    checkinState.isReturningVisitor
                        ? '/returning-visitor'
                        : '/phone',
                  ),
                  icon: Icon(
                    Icons.chevron_left,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: Text(
                    'Back',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurposeTile extends StatelessWidget {
  final String purpose;
  final bool isSelected;
  final VoidCallback onTap;

  const _PurposeTile({
    required this.purpose,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : const Color(0xFFEDF6F8),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : const Color(0xFFCCE3E8),
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            purpose,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? theme.colorScheme.primary
                  : const Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}
