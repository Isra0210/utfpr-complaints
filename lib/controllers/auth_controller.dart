import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authService) {
    _subscription = _authService.authStateChanges().listen((firebaseUser) {
      user = firebaseUser;
      isInitialized = true;
      notifyListeners();
    });
  }

  final AuthService _authService;

  late final StreamSubscription<User?> _subscription;
  User? user;
  bool isInitialized = false;
  bool isLoading = false;
  String? errorMessage;
  bool registerMode = false;

  bool get isAuthenticated => user != null;

  Future<bool> signIn(String email, String password) {
    return _run(
      () => _authService.signIn(email, password),
      'E-mail e/ou senha inválidos.',
    );
  }

  Future<bool> register(String name, String email, String password) {
    return _run(
      () => _authService.register(name, email, password),
      'Não foi possível registrar. Verifique os dados.',
    );
  }

  Future<void> signOut() => _authService.signOut();

  void toggleRegisterMode() {
    registerMode = !registerMode;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(
    Future<void> Function() action,
    String failureMessage,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (_) {
      errorMessage = failureMessage;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
