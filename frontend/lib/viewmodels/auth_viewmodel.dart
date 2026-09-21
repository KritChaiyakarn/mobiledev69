import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _authService.accessToken;

  void login() {
    _authService.login();
  }

  Future<void> checkCallback() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.handleCallback();
      _isAuthenticated = success;
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}