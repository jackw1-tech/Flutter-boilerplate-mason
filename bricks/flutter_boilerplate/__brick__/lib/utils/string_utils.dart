class StringUtils {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    return RegExp(r'^[+]?[\s./0-9]*[(]?[0-9]{1,4}[)]?[-\s./0-9]*$')
        .hasMatch(phoneNumber);
  }

  static bool isValidPassword(String password) {
    // Almeno 8 caratteri, una lettera maiuscola, una minuscola e un numero
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$')
        .hasMatch(password);
  }
}
