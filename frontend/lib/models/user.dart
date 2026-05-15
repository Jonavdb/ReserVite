import 'package:prbd_2526_f03/models/security.dart';

class User {
  static String? validateEmail(String? email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (email == null || email.trim().isEmpty) {
      return 'Champ email obligatoire.';
    }
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Veuillez saisir une adresse email valide.';
    }

    return null; // tout est ok
  }

  static Future<String?> validateEmailUnicity(String? value) async {
    var res = await Security.checkEmailAvailable(email: value?.trim());
    return res ? null : 'Email déjà utilisé.';
  }

  static String? validatePassword(String? password) {
    final passwordRegex = RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[,;.:!?/$%&@#]).{8,}$');

    if (password == null || password.isEmpty) {
      return 'Champ mot de passe obligatoire.';
    }
    if (!passwordRegex.hasMatch(password)) {
      return 'Doit contenir 8 caractères min, une majuscule, une minuscule, un chiffre et un symbole.';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    String? passwordError = validatePassword(value);
    if (passwordError != null) return passwordError;
    if (value != password) return 'Les mots de passe ne correspondent pas.';
    return null;
  }
}
