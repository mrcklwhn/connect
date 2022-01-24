class AccountChangePassword {

  static bool isPasswordStrong(String password, [int minLength = 6]) {
    if (password == null || password.isEmpty) {
      return false;
    }

    bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(new RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
    bool hasMinLength = password.length > minLength;

    return hasDigits & hasUppercase & hasLowercase &  hasMinLength;
  }

}