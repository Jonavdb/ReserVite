import 'package:prbd_2526_f03/models/security.dart';

class User {
  static String? validateFullname(String? fullname) {
    if (fullname == null || fullname.trim().isEmpty) {
      return 'Champ nom complet obligatoire.';
    }

    if (fullname.trim().length < 3) {
      return 'Le nom complet doit contenir au moins 3 caractères.';
    }
    return null;
  }

  static Future<String?> validateFullnameUnicity(String? value) async {
    bool res = await Security.checkFullnameAvailable(fullname: value?.trim());
    return res ? null : 'Ce nom complet est déjà utilisé.';
  }

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
    return res ? null : 'Cet email est déjà utilisé.';
  }

  static String? validatePassword(String? password) {
    final passwordRegex = RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[,;.:!?/$%&@#]).{8,}$');

    if (password == null || password.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    if (!passwordRegex.hasMatch(password)) {
      return 'Doit contenir 8 caractères min, une majuscule, une minuscule, un chiffre et un symbole.';
    }

    return null;
  }

  static String? validateConfirmPassword(String? confirmPassword, String? password) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Veuillez confirmer votre mot de passe.';
    }

    if (confirmPassword != password) {
      return 'Les deux mots de passe doivent être identiques.';
    }

    return null;
  }

  static String? validatePhone(String? phone) {
    // regex pour les numéros belges
    final phoneRegex = RegExp(
      r'^(?:\+32|0032|0)(?:\s|\.|\-)?(?:[1-9]\d{1,2}|\d{3})(?:\s|\.|\-)?\d{2}(?:\s|\.|\-)?\d{2}(?:\s|\.|\-)?\d{2}$',
    );

    if (phone == null || phone.trim().isEmpty) {
      return null; // on accepte le champ vide vu qu'il est optionnel
    }

    if (!phoneRegex.hasMatch(phone)) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }
}
