import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/visitor.dart';
import '../../../data/services/kelsa_upload_service.dart';
import '../../../features/employee_select/providers/employee_provider.dart';
import '../../../shared/providers/app_providers.dart';

enum CheckinStep {
  phone,
  visitorLookup,
  purpose,
  employeeSelect,
  details,
  review,
  submitting,
  success,
}

class CheckinState {
  final CheckinStep step;
  final String phoneNumber;
  final bool consentGiven;
  final Visitor? visitor;
  final bool isReturningVisitor;
  final String? purpose;
  final int? purposeOptionId;
  final EmployeeOption? selectedWhomToMeet;
  final String? name;
  final String? email;
  final String? company;
  final String? location;
  final String? serialNumber;
  final String? badgeNumber;
  final File? photoFile;
  final AttachmentValue? photoAttachment;
  final Uint8List? signatureBytes;
  final AttachmentValue? signatureAttachment;
  final bool detailsEdited;
  final bool isLoading;
  final String? errorMessage;
  final int? createdVisitorDbId;
  final int? createdVisitEntryId;

  const CheckinState({
    this.step = CheckinStep.phone,
    this.phoneNumber = '',
    this.consentGiven = false,
    this.visitor,
    this.isReturningVisitor = false,
    this.purpose,
    this.purposeOptionId,
    this.selectedWhomToMeet,
    this.name,
    this.email,
    this.company,
    this.location,
    this.serialNumber,
    this.badgeNumber,
    this.photoFile,
    this.photoAttachment,
    this.signatureBytes,
    this.signatureAttachment,
    this.detailsEdited = false,
    this.isLoading = false,
    this.errorMessage,
    this.createdVisitorDbId,
    this.createdVisitEntryId,
  });

  CheckinState copyWith({
    CheckinStep? step,
    String? phoneNumber,
    bool? consentGiven,
    Visitor? visitor,
    bool? isReturningVisitor,
    String? purpose,
    int? purposeOptionId,
    EmployeeOption? selectedWhomToMeet,
    String? name,
    String? email,
    String? company,
    String? location,
    String? serialNumber,
    String? badgeNumber,
    File? photoFile,
    AttachmentValue? photoAttachment,
    Uint8List? signatureBytes,
    AttachmentValue? signatureAttachment,
    bool? detailsEdited,
    bool? isLoading,
    String? errorMessage,
    int? createdVisitorDbId,
    int? createdVisitEntryId,
  }) {
    return CheckinState(
      step: step ?? this.step,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      consentGiven: consentGiven ?? this.consentGiven,
      visitor: visitor ?? this.visitor,
      isReturningVisitor: isReturningVisitor ?? this.isReturningVisitor,
      purpose: purpose ?? this.purpose,
      purposeOptionId: purposeOptionId ?? this.purposeOptionId,
      selectedWhomToMeet: selectedWhomToMeet ?? this.selectedWhomToMeet,
      name: name ?? this.name,
      email: email ?? this.email,
      company: company ?? this.company,
      location: location ?? this.location,
      serialNumber: serialNumber ?? this.serialNumber,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      photoFile: photoFile ?? this.photoFile,
      photoAttachment: photoAttachment ?? this.photoAttachment,
      signatureBytes: signatureBytes ?? this.signatureBytes,
      signatureAttachment: signatureAttachment ?? this.signatureAttachment,
      detailsEdited: detailsEdited ?? this.detailsEdited,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      createdVisitorDbId: createdVisitorDbId ?? this.createdVisitorDbId,
      createdVisitEntryId: createdVisitEntryId ?? this.createdVisitEntryId,
    );
  }

  Visitor toVisitor() {
    return Visitor(
      databaseLeadId: visitor?.databaseLeadId,
      name: name ?? visitor?.name,
      email: email ?? visitor?.email,
      phoneNumber: phoneNumber,
      company: company ?? visitor?.company,
      location: location ?? visitor?.location,
      serialNumber: serialNumber ?? visitor?.serialNumber,
      photoUrl: photoAttachment?.url ?? visitor?.photoUrl,
      photoSize: photoAttachment?.size ?? visitor?.photoSize,
      photoUploadId: photoAttachment?.uploadId,
      signatureUrl: signatureAttachment?.url,
      signatureSize: signatureAttachment?.size,
      signatureUploadId: signatureAttachment?.uploadId,
      badgeNumber: badgeNumber ?? visitor?.badgeNumber,
      purpose: purpose,
      purposeOptionId: purposeOptionId,
      visitorTypeName: purpose,
      visitorTypeOptionId: purposeOptionId,
      whomToMeet: selectedWhomToMeet?.name,
      whomToMeetOptionId: selectedWhomToMeet?.leadId,
    );
  }
}

class CheckinNotifier extends StateNotifier<CheckinState> {
  final Ref _ref;

  CheckinNotifier(this._ref) : super(const CheckinState());

  void setPhoneNumber(String phone) =>
      state = state.copyWith(phoneNumber: phone);

  void setConsent(bool value) =>
      state = state.copyWith(consentGiven: value);

  void clearError() => state = state.copyWith(errorMessage: null);

  Future<void> searchVisitor() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = _ref.read(visitorRepositoryProvider);
      final visitor = await repo.searchByPhone(state.phoneNumber);
      if (visitor != null) {
        state = state.copyWith(
          step: CheckinStep.visitorLookup,
          visitor: visitor,
          isReturningVisitor: true,
          name: visitor.name,
          email: visitor.email,
          company: visitor.company,
          location: visitor.location,
          serialNumber: visitor.serialNumber,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          step: CheckinStep.purpose,
          isReturningVisitor: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setPurpose(String purpose, {int? optionId}) {
    state = state.copyWith(purpose: purpose, purposeOptionId: optionId);
  }

  void proceedFromReturningVisitor() {
    state = state.copyWith(step: CheckinStep.employeeSelect);
  }

  void proceedFromPurpose() {
    state = state.copyWith(step: CheckinStep.employeeSelect);
  }

  void selectWhomToMeet(EmployeeOption employee) {
    state = state.copyWith(
      selectedWhomToMeet: employee,
      step: CheckinStep.details,
    );
  }

  void updateDetails({
    String? name,
    String? email,
    String? company,
    String? location,
    String? serialNumber,
    String? badgeNumber,
  }) {
    state = state.copyWith(
      name: name,
      email: email,
      company: company,
      location: location,
      serialNumber: serialNumber,
      badgeNumber: badgeNumber,
      detailsEdited: true,
    );
  }

  void setPhotoFile(File file) =>
      state = state.copyWith(photoFile: file);

  void setSignatureBytes(Uint8List bytes) =>
      state = state.copyWith(signatureBytes: bytes);

  void proceedToReview() {
    state = state.copyWith(step: CheckinStep.review);
  }

  Future<void> submit() async {
    if (state.isLoading) return;
    state = state.copyWith(
      step: CheckinStep.submitting,
      isLoading: true,
      errorMessage: null,
    );

    try {
      final config = _ref.read(clientConfigProvider)!;
      final uploadService = _ref.read(kelsaUploadServiceProvider);
      final repo = _ref.read(visitorRepositoryProvider);

      // Upload photo to visitor database pipeline
      AttachmentValue? photoAttachment;
      if (state.photoFile != null) {
        photoAttachment = await uploadService.uploadPhoto(
          file: state.photoFile!,
          pipelineId: config.visitorDatabasePipelineId,
        );
        state = state.copyWith(photoAttachment: photoAttachment);
      }

      // Upload signature to visitor management pipeline
      AttachmentValue? signatureAttachment;
      if (state.signatureBytes != null) {
        signatureAttachment = await uploadService.uploadSignature(
          signatureBytes: state.signatureBytes!,
          pipelineId: config.visitorManagementPipelineId,
        );
        state = state.copyWith(signatureAttachment: signatureAttachment);
      }

      final visitor = state.toVisitor();

      // Step 1: Create/update in Visitor Database
      final dbId = await repo.createOrUpdateVisitorDatabase(visitor);

      // Step 2: Create visit entry in Visitor Management
      final visitId = await repo.createVisitEntry(
        visitor: visitor,
        databaseLeadId: dbId,
      );

      state = state.copyWith(
        step: CheckinStep.success,
        isLoading: false,
        createdVisitorDbId: dbId,
        createdVisitEntryId: visitId,
      );
    } catch (e) {
      state = state.copyWith(
        step: CheckinStep.review,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const CheckinState();
  }
}

final checkinProvider =
    StateNotifierProvider<CheckinNotifier, CheckinState>((ref) {
  return CheckinNotifier(ref);
});
