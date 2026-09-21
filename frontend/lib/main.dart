import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/pet_viewmodel.dart'; // เพิ่มบรรทัดนี้
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'views/callback_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PetViewModel()), // เพิ่มบรรทัดนี้
      ],
      child: const PetCareApp(),
    ),
  );
}

class PetCareApp extends StatelessWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetCare Log',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGuard(),
        '/login': (context) => const LoginView(),
        '/callback': (context) => const CallbackView(),
      },
    );
  }
}

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    if (authVM.isAuthenticated) {
      return const HomeView();
    } else {
      return const LoginView();
    }
  }
}