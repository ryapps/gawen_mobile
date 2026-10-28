abstract final class PasswordValidator {
  static const minLength = 8;
  static const maxLength = 128;

  static String? validateNewPassword(String? value) {
    final password = value ?? '';
    final characterCount = password.runes.length;
    if (characterCount < minLength) {
      return 'Kata sandi minimal 8 karakter.';
    }
    if (characterCount > maxLength) {
      return 'Kata sandi maksimal 128 karakter.';
    }
    return null;
  }

  static String? validateConfirmation({
    required String? confirmation,
    required String password,
  }) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Ulangi kata sandi.';
    }
    if (confirmation != password) return 'Kata sandi belum sama.';
    return null;
  }

  static String? validateAuthPassword({required String? password}) {
    final passwordValue = password ?? '';
    if (passwordValue.isEmpty) {
      return 'Kata sandi wajib diisi.';
    }
    if (passwordValue.length < minLength) {
      return 'Kata sandi minimal 8 karakter.';
    }
    if (passwordValue.length > maxLength) {
      return 'Kata sandi maksimal 128 karakter.';
    }
    return null;
  }
}
