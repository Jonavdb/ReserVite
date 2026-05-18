import 'dart:math';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../app/params.dart';
import '../../models/security/security.dart';

final currentUserProvider = AsyncNotifierProvider<CurrentUserNotifier, String?>(() => CurrentUserNotifier());

class CurrentUserNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    // pour que le state soit initialisée de manière synchrone
    state = AsyncData(Params.getValue('token'));
    return state.value;
  }

  Future<void> signup({
    required String fullname,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      await Security.signup(fullname: fullname, email: email, password: password, phone: phone);
      await login(email, password);
      state = AsyncValue.data(Params.getValue('token'));
    } catch (e) {
      state = AsyncValue.error("Signup failed", StackTrace.current);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      var token = await Security.login(email, password);
      Params.setValue('token', token);
      state = AsyncData(token);
    } catch (e) {
      state = AsyncError("Something went wrong!\nPlease try again later.", StackTrace.current);
    }
  }

  void logout() {
    Params.clearValue('token');
    state = AsyncData(null);
  }

  bool get isLoggedIn => loggedUser != null;

  String? get loggedUser {
    return _getUserFromToken(state.value);
  }

  String? get loggedUserName {
    if (state.value == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(state.value!);
      return decodedToken['name'];
    } catch (e) {
      return null;
    }
  }

  static String? _getUserFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub'];
    } catch (e) {
      return null;
    }
  }

  static String? _getRoleFromToken(String? token) {
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['role'];
    } catch (e) {
      return null;
    }
  }

  bool get isManager => _getRoleFromToken(state.value) == 'manager';

  bool get isClient => _getRoleFromToken(state.value) == 'client';
}
