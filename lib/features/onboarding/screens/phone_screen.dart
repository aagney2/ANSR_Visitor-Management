import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../features/visitor_checkin/providers/checkin_provider.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _consentGiven = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _consentGiven &&
      _phoneController.text.trim().isNotEmpty &&
      Validators.phoneNumber(_phoneController.text) == null;

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate() || !_consentGiven) return;

    final notifier = ref.read(checkinProvider.notifier);
    notifier.setPhoneNumber(
      Validators.normalizePhone(_phoneController.text.trim()),
    );
    notifier.setConsent(true);
    await notifier.searchVisitor();

    if (!mounted) return;
    final state = ref.read(checkinProvider);
    if (state.errorMessage != null) return;

    if (state.isReturningVisitor) {
      context.go('/returning-visitor');
    } else {
      context.go('/purpose');
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(clientConfigProvider);
    final checkinState = ref.watch(checkinProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(config?.clientName ?? 'Visitor Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Enter your phone number',
                  subtitle: 'We\'ll use this to find or create your visitor profile',
                ),
                const SizedBox(height: 8),
                if (checkinState.errorMessage != null)
                  ErrorBanner(
                    message: checkinState.errorMessage!,
                    onDismiss: () =>
                        ref.read(checkinProvider.notifier).clearError(),
                    onRetry: _onContinue,
                  ),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\+\-\s\(\)]')),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+91 99999 99999',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  validator: Validators.phoneNumber,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () => setState(() => _consentGiven = !_consentGiven),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _consentGiven
                          ? theme.colorScheme.primary.withValues(alpha: 0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _consentGiven
                            ? theme.colorScheme.primary.withValues(alpha: 0.3)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _consentGiven,
                            onChanged: (v) =>
                                setState(() => _consentGiven = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I hereby declare that the information provided by me is best to my knowledge and can be used by ${config?.clientName ?? "the company"} during my visit. Also I agree to Vizmo\'s terms of service and privacy policy.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF616161),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: _canContinue ? _onContinue : null,
                  isLoading: checkinState.isLoading,
                  icon: Icons.arrow_forward_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
