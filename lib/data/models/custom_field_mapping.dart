import 'kelsa_field.dart';

/// Resolves Kelsa custom field identifiers dynamically from the API response.
/// Maps logical field names to actual `cf_...` identifiers at runtime.
class CustomFieldMapping {
  final Map<String, KelsaCustomField> _byIdentifier = {};
  final Map<String, KelsaCustomField> _byName = {};

  CustomFieldMapping(List<KelsaCustomField> fields) {
    for (final field in fields) {
      _byIdentifier[field.identifier] = field;
      _byName[field.name.toLowerCase()] = field;
    }
  }

  KelsaCustomField? byIdentifier(String identifier) =>
      _byIdentifier[identifier];

  KelsaCustomField? byName(String name) =>
      _byName[name.toLowerCase()];

  String? resolveIdentifier(String identifier) =>
      _byIdentifier.containsKey(identifier) ? identifier : null;

  /// Find a field matching any of the given candidate identifiers.
  /// Returns the first match found.
  String? resolveFirst(List<String> candidates) {
    for (final c in candidates) {
      if (_byIdentifier.containsKey(c)) return c;
    }
    return null;
  }

  List<KelsaFieldOption>? optionsFor(String identifier) =>
      _byIdentifier[identifier]?.options;

  bool has(String identifier) => _byIdentifier.containsKey(identifier);

  List<String> get allIdentifiers => _byIdentifier.keys.toList();
}
