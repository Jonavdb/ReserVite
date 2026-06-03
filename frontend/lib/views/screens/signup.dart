import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/core/tools/validating_text_editing_controller.dart';
import '../../models/security/user.dart';
import '../../providers/security/current_user_provider.dart';

class Signup extends ConsumerStatefulWidget {
  @override
  ConsumerState<Signup> createState() => _SignupState();
}

class _SignupState extends ConsumerState<Signup> {
  late ValidatingTextEditingController _fullNameController;
  late ValidatingTextEditingController _emailController;
  late ValidatingTextEditingController _passwordController;
  late ValidatingTextEditingController _confirmPasswordController;
  late ValidatingTextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    _fullNameController = ValidatingTextEditingController(
      validator: User.validateFullname,
      asyncValidator: User.validateFullnameUnicity,
    );
    _fullNameController.onAfterValidated = () => setState(() {});

    _emailController = ValidatingTextEditingController(
      validator: User.validateEmail,
      asyncValidator: User.validateEmailUnicity,
    );
    _emailController.onAfterValidated = () => setState(() {});

    _passwordController = ValidatingTextEditingController(validator: User.validatePassword);
    _passwordController.onAfterValidated = () {
      setState(() {});
      // on force le champ 'confirm' à s'évaluer dès qu'on touche au champ password
      _confirmPasswordController.validate();
    };

    _confirmPasswordController = ValidatingTextEditingController(
      validator: (value) => User.validateConfirmPassword(value, _passwordController.text),
    );
    _confirmPasswordController.onAfterValidated = () => setState(() {});

    _phoneController = ValidatingTextEditingController(validator: (value) => User.validatePhone(value));
    _phoneController.onAfterValidated = () => setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        title: const Text('Inscription'),
        automaticallyImplyLeading: false,
        actions: [IconButton(icon: const Icon(Icons.refresh), tooltip: 'Rafraîchir les données', onPressed: () {})],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(simulatedTime),
                  style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 32),
                const Text(
                  'Créez votre compte',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                _fullNameFormField(context, (_) => _submitForm(context)),
                const SizedBox(height: 16),

                _emailFormField(context, (_) => _submitForm(context)),
                const SizedBox(height: 16),

                _passwordFormField(context, (_) => _submitForm(context)),
                const SizedBox(height: 16),

                _confirmPasswordFormField(context, (_) => _submitForm(context)),
                const SizedBox(height: 16),

                _phoneFormField(context, (_) => _submitForm(context)),
                const SizedBox(height: 32),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async => await _submitForm(context),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('S\'inscrire'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Déjà un compte ? Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widgets découpés
  Widget _fullNameFormField(BuildContext context, Future<void> Function(String) onFieldSubmitted) {
    return TextFormField(
      controller: _fullNameController,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: 'Nom complet',
        errorText: _fullNameController.errorText,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
    );
  }

  Widget _emailFormField(BuildContext context, Future<void> Function(String) onFieldSubmitted) {
    return TextFormField(
      controller: _emailController,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: _emailController.errorText,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _passwordFormField(BuildContext context, Future<void> Function(String) onFieldSubmitted) {
    return TextFormField(
      controller: _passwordController,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      obscuringCharacter: '•',
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        errorText: _passwordController.errorText,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
      ),
    );
  }

  Widget _confirmPasswordFormField(BuildContext context, Future<void> Function(String) onFieldSubmitted) {
    return TextFormField(
      controller: _confirmPasswordController,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      obscuringCharacter: '•',
      decoration: InputDecoration(
        labelText: 'Confirmer le mot de passe',
        errorText: _confirmPasswordController.errorText,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock_outline),
      ),
    );
  }

  Widget _phoneFormField(BuildContext context, Future<void> Function(String) onFieldSubmitted) {
    return TextFormField(
      controller: _phoneController,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: 'Téléphone (optionnel)',
        errorText: _phoneController.errorText,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.phone),
      ),
      keyboardType: TextInputType.phone,
    );
  }

  // Méthodes
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!await _validateForm()) return;

    String? rawPhone = _phoneController.text.trim();
    String? cleanPhone;

    if (rawPhone.isNotEmpty) {
      // regex qui remplace tout ce qui est espace, point ou tiret par du vide
      cleanPhone = rawPhone.replaceAll(RegExp(r'[\s\.\-]'), '');
    }

    await ref
        .read(currentUserProvider.notifier)
        .signup(
          fullname: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: cleanPhone,
        );
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/list_reservation_client', (route) => false);
    }
  }

  Future<bool> _validateForm() async {
    await _fullNameController.validateAndWait();
    await _emailController.validateAndWait();
    await _passwordController.validateAndWait();
    await _confirmPasswordController.validateAndWait();
    await _phoneController.validateAndWait();
    return _isFormValid;
  }

  bool get _isFormValid =>
      _fullNameController.isValid == true &&
      _emailController.isValid == true &&
      _passwordController.isValid == true &&
      _confirmPasswordController.isValid == true &&
      _phoneController.isValid == true;
}
