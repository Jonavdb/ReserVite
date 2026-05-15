import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/core/tools/validating_text_editing_controller.dart';
import '../../models/user.dart';
import '../../providers/security_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = ValidatingTextEditingController(validator: User.validateEmail, initialValue: '');
  final _passwordController = ValidatingTextEditingController(validator: User.validatePassword, initialValue: '');

  @override
  void initState() {
    _emailController.onAfterValidated = () => setState(() {});
    _passwordController.onAfterValidated = () => setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(securityProvider);

    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      const Icon(Icons.restaurant, size: 80, color: Colors.blue),
                      const SizedBox(height: 12),
                      const Text(
                        'Connectez-vous',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),

                      // Champ Email
                      const SizedBox(height: 12),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _emailController,
                        onFieldSubmitted: (value) => _submitForm(context),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorText: _emailController.errorText,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),

                      // Champ Password
                      const SizedBox(height: 10),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _passwordController,
                        onFieldSubmitted: (value) => _submitForm(context),
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          errorText: _passwordController.errorText,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _submitForm(context),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                        child: const Text('Se connecter'),
                      ),
                      const SizedBox(height: 6),
                      TextButton(onPressed: () {}, child: const Text('Pas encore de compte ? S\'inscrire')),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Raccourcis de débogage',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Se connecter directement en tant que :',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),

                  // Raccourcis Clients
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _login(context, 'brlacroix@epfc.eu'),
                          icon: const Icon(Icons.person),
                          label: const Text('Client (Bruno)'),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _login(context, 'mamichel@epfc.eu'),
                          icon: const Icon(Icons.person),
                          label: const Text('Client (Marc)'),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                        ),
                      ),
                    ],
                  ),

                  // Raccourcis Managers
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _login(context, 'bepenelle@epfc.eu'),
                          icon: const Icon(Icons.manage_accounts),
                          label: const Text('Manager (Benoît)'),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _login(context, 'gedielman@epfc.eu'),
                          icon: const Icon(Icons.manage_accounts),
                          label: const Text('Manager (Geoffrey)'),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réinitialiser la base de données'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // supprime ce qu'il y a en mémoire quand on quitte la page
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (!_validateForm()) return;
    _login(context, _emailController.text, password: _passwordController.text);
  }

  bool _validateForm() {
    _emailController.validate();
    _passwordController.validate();
    return _isFormValid;
  }

  bool get _isFormValid => _emailController.isValid == true && _passwordController.isValid == true;

  void _login(BuildContext context, String mail, {String? password}) async {
    // si password est null, on utilise 'Password1,' par défaut
    final passwordToUse = password ?? 'Password1,';

    await ref.read(securityProvider.notifier).login(mail, passwordToUse);
    final securityState = ref.read(securityProvider);

    if (!context.mounted) return;

    securityState.when(
      data: (token) {
        if (token != null) {
          final notifier = ref.read(securityProvider.notifier);

          if (notifier.isManager) {
            Navigator.pushReplacementNamed(context, '/my_restaurants');
          } else {
            Navigator.pushReplacementNamed(context, '/list_reservation_client');
          }
        }
      },
      error: (error, _) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Email ou mot de passe incorrect.'), backgroundColor: Colors.red));
      },
      loading: () {},
    );
  }
}
