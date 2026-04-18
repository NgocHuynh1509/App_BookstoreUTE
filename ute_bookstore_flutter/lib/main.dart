import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/admin_shell.dart';
import 'app/providers.dart';
import 'core/api_client.dart';
import 'core/session_storage.dart';
import 'features/auth/presentation/admin_login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = SessionStorage();
  final client = await ApiClient.create(storage);
  runApp(
    ProviderScope(
      overrides: [
        sessionStorageProvider.overrideWithValue(storage),
        apiClientProvider.overrideWithValue(client),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _hasToken() async {
    final storage = SessionStorage();
    final token = await storage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Bookstore',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4C6FFF),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: FutureBuilder<bool>(
        future: _hasToken(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final loggedIn = snapshot.data!;
          return loggedIn ? const AdminShell() : const AdminLoginScreen();
        },
      ),
    );
  }
}