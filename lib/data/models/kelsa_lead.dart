class KelsaLead {
  final int? id;
  final String? name;
  final Map<String, dynamic> customFieldValues;

  const KelsaLead({
    this.id,
    this.name,
    required this.customFieldValues,
  });

  factory KelsaLead.fromJson(Map<String, dynamic> json) {
    return KelsaLead(
      id: json['id'] as int?,
      name: json['name'] as String?,
      customFieldValues:
          (json['custom_field_values'] as Map<String, dynamic>?) ?? {},
    );
  }

  dynamic operator [](String key) => customFieldValues[key];

  String? getString(String key) {
    final val = customFieldValues[key];
    if (val == null) return null;
    if (val is String) return val;
    return val.toString();
  }

  Map<String, dynamic>? getMap(String key) {
    final val = customFieldValues[key];
    if (val is Map<String, dynamic>) return val;
    return null;
  }
}

class KelsaDraft {
  final int id;
  final int? leadId;

  const KelsaDraft({required this.id, this.leadId});

  factory KelsaDraft.fromJson(Map<String, dynamic> json) {
    return KelsaDraft(
      id: json['id'] as int,
      leadId: json['lead_id'] as int?,
    );
  }

  bool get isResolved => leadId != null;
}
