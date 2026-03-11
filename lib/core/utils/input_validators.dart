abstract final class InputValidators {
  static String? email(String? value) {
    final normalizedValue = value?.trim() ?? '';

    if (normalizedValue.isEmpty) {
      return 'Email is required.';
    }

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(normalizedValue)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? password(String? value) {
    final normalizedValue = value ?? '';

    if (normalizedValue.isEmpty) {
      return 'Password is required.';
    }

    if (normalizedValue.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  static String? requiredField(String? value, {required String fieldName}) {
    if ((value?.trim() ?? '').isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  static String? yearsOfExperience(String? value) {
    final normalizedValue = value?.trim() ?? '';

    if (normalizedValue.isEmpty) {
      return 'Years of experience is required.';
    }

    final years = int.tryParse(normalizedValue);
    if (years == null) {
      return 'Enter years as a whole number.';
    }

    if (years < 0 || years > 50) {
      return 'Enter a value between 0 and 50.';
    }

    return null;
  }
}
