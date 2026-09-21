import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class CallbackView extends StatefulWidget {
  const CallbackView({super.key});

  @override
  State<CallbackView> createState() => _CallbackViewState();
}

class _CallbackViewState extends State<CallbackView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authVM = context.read<AuthViewModel>();
      await authVM.checkCallback();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('กำลังยืนยันตัวตน กรุณารอสักครู่...'),
          ],
        ),
      ),
    );
  }
}