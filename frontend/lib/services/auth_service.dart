import 'package:openid_client/openid_client_browser.dart' as openid;
import 'package:web/web.dart' as web;

class AuthService {
  static const String _issuerUrl = 'http://127.0.0.1:8000/openid';
  static const String clientId = '982825';

  openid.Client? _client;
  openid.Credential? _credential;
  String? _extractedToken;

  String? get accessToken =>
      _credential?.response?['access_token'] ?? _extractedToken;

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;

  AuthService() {
    _extractTokenFromInitialUrl();
  }

  void _extractTokenFromInitialUrl() {
    try {
      final uri = Uri.base;
      String rawString = uri.fragment.isNotEmpty ? uri.fragment : uri.query;

      if (rawString.contains('access_token=')) {
        final params = Uri.splitQueryString(rawString);
        if (params.containsKey('access_token') &&
            params['access_token']!.isNotEmpty) {
          _extractedToken = params['access_token'];
        }
      }
    } catch (e) {
      print('Error extracting token from URL: $e');
    }
  }

  Future<void> initAuth() async {
    if (_client != null) return;
    final issuer = await openid.Issuer.discover(Uri.parse(_issuerUrl));
    _client = openid.Client(issuer, clientId);
  }

  Future<void> login() async {
    await initAuth();
    final authenticator = openid.Authenticator(
      _client!,
      scopes: ['openid', 'profile', 'email'],
    );
    authenticator.authorize();
  }

  Future<bool> handleCallback() async {
    if (isAuthenticated) return true;

    _extractTokenFromInitialUrl();
    if (isAuthenticated) return true;

    try {
      await initAuth();
      final authenticator = openid.Authenticator(_client!);
      final credential = await authenticator.credential;
      if (credential != null) {
        _credential = credential;
        return true;
      }
    } catch (e) {
      print('OIDC client check skipped: $e');
    }

    return isAuthenticated;
  }

  void logout() {
    _credential = null;
    _extractedToken = null;

    // ชี้ไปที่ endpoint /logout/ ใหม่ของ Django
    web.window.location.href =
        'http://127.0.0.1:8000/logout/?next=http://localhost:50000/';
  }
}