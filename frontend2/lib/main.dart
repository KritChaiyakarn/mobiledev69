import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_browser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: OIDCAuthScreen(),
    );
  }
}

class OIDCAuthScreen extends StatefulWidget {
  const OIDCAuthScreen({super.key});

  @override
  State<OIDCAuthScreen> createState() => _OIDCAuthScreenState();
}

class _OIDCAuthScreenState extends State<OIDCAuthScreen> {
  String _userInfo = 'Not logged in';

  Future<Credential?> _signIn() async {
    // 1. Discover Endpoints จาก backend2[cite: 1]
    final issuer = await Issuer.discover(Uri.parse('http://localhost:8000'));
    // ใส่ Client ID ที่ลงทะเบียนจากหน้า Django Admin ของ backend2[cite: 1]
    final client = Client(issuer, 'YOUR_CLIENT_ID_FROM_BACKEND2'); 
    final auth = Authenticator(client, scopes: ['openid', 'profile', 'email']);

    final c = await auth.credential;
    if (c == null) {
      auth.authorize(); // Redirect ไป Login หน้า Django[cite: 1]
      return null;
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Frontend2 - OIDC App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_userInfo),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Sign in with OIDC'),
              onPressed: () async {
                final cred = await _signIn();
                if (cred != null) {
                  final info = await cred.getUserInfo();
                  setState(() {
                    _userInfo = 'User: ${info.name} (${info.email})';
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}