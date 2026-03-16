class Visitor {
  final int? databaseLeadId;
  final String? name;
  final String? email;
  final String phoneNumber;
  final String? company;
  final String? location;
  final String? serialNumber;
  final String? photoUrl;
  final int? photoSize;
  final int? photoUploadId;
  final String? signatureUrl;
  final int? signatureSize;
  final int? signatureUploadId;
  final String? badgeNumber;
  final String? purpose;
  final int? purposeOptionId;
  final String? visitorTypeName;
  final int? visitorTypeOptionId;
  final String? whomToMeet;
  final int? whomToMeetOptionId;
  final Map<String, dynamic>? rawCustomFields;

  const Visitor({
    this.databaseLeadId,
    this.name,
    this.email,
    required this.phoneNumber,
    this.company,
    this.location,
    this.serialNumber,
    this.photoUrl,
    this.photoSize,
    this.photoUploadId,
    this.signatureUrl,
    this.signatureSize,
    this.signatureUploadId,
    this.badgeNumber,
    this.purpose,
    this.purposeOptionId,
    this.visitorTypeName,
    this.visitorTypeOptionId,
    this.whomToMeet,
    this.whomToMeetOptionId,
    this.rawCustomFields,
  });

  Visitor copyWith({
    int? databaseLeadId,
    String? name,
    String? email,
    String? phoneNumber,
    String? company,
    String? location,
    String? serialNumber,
    String? photoUrl,
    int? photoSize,
    int? photoUploadId,
    String? signatureUrl,
    int? signatureSize,
    int? signatureUploadId,
    String? badgeNumber,
    String? purpose,
    int? purposeOptionId,
    String? visitorTypeName,
    int? visitorTypeOptionId,
    String? whomToMeet,
    int? whomToMeetOptionId,
    Map<String, dynamic>? rawCustomFields,
  }) {
    return Visitor(
      databaseLeadId: databaseLeadId ?? this.databaseLeadId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      company: company ?? this.company,
      location: location ?? this.location,
      serialNumber: serialNumber ?? this.serialNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      photoSize: photoSize ?? this.photoSize,
      photoUploadId: photoUploadId ?? this.photoUploadId,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      signatureSize: signatureSize ?? this.signatureSize,
      signatureUploadId: signatureUploadId ?? this.signatureUploadId,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      purpose: purpose ?? this.purpose,
      purposeOptionId: purposeOptionId ?? this.purposeOptionId,
      visitorTypeName: visitorTypeName ?? this.visitorTypeName,
      visitorTypeOptionId: visitorTypeOptionId ?? this.visitorTypeOptionId,
      whomToMeet: whomToMeet ?? this.whomToMeet,
      whomToMeetOptionId: whomToMeetOptionId ?? this.whomToMeetOptionId,
      rawCustomFields: rawCustomFields ?? this.rawCustomFields,
    );
  }

  bool get isReturning => databaseLeadId != null;
}
