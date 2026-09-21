import 'package:openid_client/openid_client_browser.dart' as openid;

class AuthService {
  // URL ของ Django OIDC Provider
  static const String _issuerUrl = 'http://127.0.0.1:8000/openid';
  
  // ⚠️ อย่าลืมเปลี่ยนเป็น Client ID ที่คัดลอกมาจาก Django Admin
  static const String clientId = 'YOUR_CLIENT_ID_HERE'; 

  openid.Client? _client;
  openid.Credential? _credential;

  String? get accessToken => _credential?.response?['access_token'];

  Future<void> initAuth() async {
    if (_client != null) return;
    final issuer = await openid.Issuer.discover(Uri.parse(_issuerUrl));
    _client = openid.Client(issuer, clientId);
  }

  // เรียกหน้า Login OIDC
  Future<void> login() async {
    await initAuth();
    final authenticator = openid.Authenticator(
      _client!,
      scopes: ['openid', 'profile', 'email'],
    );
    authenticator.authorize();
  }

  // ตรวจสอบการกลับมาจากหน้า Callback หลัง Login สำเร็จ
  Future<bool> handleCallback() async {
    await initAuth();
    final authenticator = openid.Authenticator(_client!);
    final credential = await authenticator.credential;
    if (credential != null) {
      _credential = credential;
      return true;
    }
    return false;
  }

  void logout() {
    _credential = null;
  }
}