class KelsaCustomField {
  final int id;
  final String name;
  final String identifier;
  final String fieldType;
  final bool isRequired;
  final List<KelsaFieldOption>? options;

  const KelsaCustomField({
    required this.id,
    required this.name,
    required this.identifier,
    required this.fieldType,
    this.isRequired = false,
    this.options,
  });

  factory KelsaCustomField.fromJson(Map<String, dynamic> json) {
    return KelsaCustomField(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      identifier: (json['identifier'] ?? '') as String,
      fieldType: (json['field_type'] ?? 'text') as String,
      isRequired: (json['is_required'] ?? false) as bool,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((o) => KelsaFieldOption.fromJson(o as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class KelsaFieldOption {
  final int id;
  final String name;

  const KelsaFieldOption({required this.id, required this.name});

  factory KelsaFieldOption.fromJson(Map<String, dynamic> json) {
    return KelsaFieldOption(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
