import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../features/visitor_checkin/providers/checkin_provider.dart';

class VisitorDetailsScreen extends ConsumerStatefulWidget {
  const VisitorDetailsScreen({super.key});

  @override
  ConsumerState<VisitorDetailsScreen> createState() =>
      _VisitorDetailsScreenState();
}

class _VisitorDetailsScreenState extends ConsumerState<VisitorDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _serialCtrl;
  late final TextEditingController _badgeCtrl;

  File? _photoFile;
  String? _savedPhotoUrl;
  bool _signatureCaptured = false;

  final SignatureController _sigController = SignatureController(
    penStrokeWidth: 3,
    penColor: const Color(0xFF1A237E),
    exportBackgroundColor: Colors.white,
    exportPenColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    final state = ref.read(checkinProvider);
    _nameCtrl = TextEditingController(text: state.name ?? '');
    _emailCtrl = TextEditingController(text: state.email ?? '');
    _companyCtrl = TextEditingController(text: state.company ?? '');
    _locationCtrl = TextEditingController(text: state.location ?? '');
    _serialCtrl = TextEditingController(text: state.serialNumber ?? '');
    _badgeCtrl = TextEditingController(text: state.badgeNumber ?? '');
    _photoFile = state.photoFile;
    _savedPhotoUrl = state.visitor?.photoUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _companyCtrl.dispose();
    _locationCtrl.dispose();
    _serialCtrl.dispose();
    _badgeCtrl.dispose();
    _sigController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _photoFile = File(image.path));
      ref.read(checkinProvider.notifier).setPhotoFile(_photoFile!);
    }
  }

  String? _photoError;
  String? _signatureError;

  bool get _hasPhoto => _photoFile != null || _savedPhotoUrl != null;

  Future<void> _proceed() async {
    final formValid = _formKey.currentState!.validate();

    setState(() {
      _photoError = !_hasPhoto ? 'Photo is required' : null;
      _signatureError = !_signatureCaptured ? 'Signature is required' : null;
    });

    if (!formValid || !_hasPhoto || !_signatureCaptured) return;

    final notifier = ref.read(checkinProvider.notifier);
    notifier.updateDetails(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      serialNumber: _serialCtrl.text.trim(),
      badgeNumber: _badgeCtrl.text.trim(),
    );

    final sigBytes = await _sigController.toPngBytes();
    if (sigBytes != null) {
      notifier.setSignatureBytes(sigBytes);
    }

    final state = ref.read(checkinProvider);
    if (state.selectedWhomToMeet == null) {
      // Purpose & employee not yet selected — go there first
      if (mounted) context.go('/purpose');
    } else {
      notifier.proceedToReview();
      if (mounted) context.go('/review');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            final state = ref.read(checkinProvider);
            if (state.selectedWhomToMeet == null) {
              context.go('/returning-visitor');
            } else {
              context.go('/employee-select');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SectionHeader(
                title: 'Your details',
                subtitle: 'Fill in or update your information',
              ),
              _buildField(
                controller: _nameCtrl,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (v) => Validators.required(v, 'Full name'),
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _companyCtrl,
                label: 'Company',
                icon: Icons.business_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _locationCtrl,
                label: 'Location',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _serialCtrl,
                label: 'Laptop Serial Number',
                icon: Icons.laptop_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _badgeCtrl,
                label: 'Badge Number',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 28),
              // Photo capture
              Text(
                'Photo',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _photoError != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: _photoFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            _photoFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : _savedPhotoUrl != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    _savedPhotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.broken_image, size: 48),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Tap to retake',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 48,
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to capture photo',
                              style: TextStyle(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_photoError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    _photoError!,
                    style: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              // Signature capture
              Text(
                'Signature',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _signatureError != null
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      Signature(
                        controller: _sigController,
                        backgroundColor: Colors.white,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          children: [
                            _MiniAction(
                              icon: Icons.refresh,
                              onTap: () {
                                _sigController.clear();
                                setState(() => _signatureCaptured = false);
                              },
                            ),
                            const SizedBox(width: 4),
                            _MiniAction(
                              icon: Icons.check,
                              onTap: () {
                                if (_sigController.isNotEmpty) {
                                  setState(() => _signatureCaptured = true);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      if (_signatureCaptured)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Captured',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_signatureError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    _signatureError!,
                    style: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              Builder(builder: (context) {
                final state = ref.watch(checkinProvider);
                final needsPurpose = state.selectedWhomToMeet == null;
                return PrimaryButton(
                  label: needsPurpose ? 'Save & Continue' : 'Review & Submit',
                  icon: needsPurpose
                      ? Icons.arrow_forward_rounded
                      : Icons.rate_review_outlined,
                  onPressed: _proceed,
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: const Color(0xFF616161)),
        ),
      ),
    );
  }
}
