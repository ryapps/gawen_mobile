abstract final class EditOrganizationValidator {
  static String formatPhone(String input) {
    final digits = digitsOnly(input);
    return digits.isEmpty ? '' : '+62$digits';
  }

  static String digitsOnly(String? value) {
    var digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('62')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  static String? nullable(String value) =>
      value.trim().isEmpty ? null : value.trim();

  static String? validatePhone(String? value) =>
      RegExp(r'^[1-9][0-9]{7,12}$').hasMatch(digitsOnly(value))
      ? null
      : 'Masukkan nomor 8–13 digit tanpa awalan 0.';

  static String? Function(String?) urlValidator(String label) => (value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    return uri != null &&
            uri.hasAuthority &&
            (uri.scheme == 'https' || uri.scheme == 'http')
        ? null
        : '$label harus berupa URL http/https.';
  };

  static String? emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)
        ? null
        : 'Masukkan email valid.';
  }

  static String? Function(String?) requiredTextValidator(
    String label, {
    int min = 1,
    required int max,
  }) => (value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label wajib diisi.';
    if (text.length < min) return '$label minimal $min karakter.';
    if (text.length > max) return '$label maksimal $max karakter.';
    return null;
  };

  static String? Function(String?) maxLengthValidator(int max, String label) =>
      (value) => (value?.trim().length ?? 0) > max
      ? '$label maksimal $max karakter.'
      : null;

  static String? optionalPhoneValidator(String? value) =>
      value == null || value.trim().isEmpty
      ? null
      : EditOrganizationValidator.validatePhone(value);
}
