class Validators {
  Validators._();

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(cleaned)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w\.\-\+]+@[\w\.\-]+\.\w{2,}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String normalizePhone(String phone) {
    var cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!cleaned.startsWith('+')) {
      if (cleaned.length == 10) {
        cleaned = '+91$cleaned';
      } else {
        cleaned = '+$cleaned';
      }
    }
    return cleaned;
  }
}
