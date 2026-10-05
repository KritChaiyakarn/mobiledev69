import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  String? get accessToken => _authService.accessToken;
  String? get token => _authService.accessToken;

  AuthViewModel() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.handleCallback();
    _isLoggedIn = success || _authService.isAuthenticated;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkCallback() async {
    await checkAuthStatus();
  }

  Future<void> login() async {
    await _authService.login();
  }

  void logout() {
    _authService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}