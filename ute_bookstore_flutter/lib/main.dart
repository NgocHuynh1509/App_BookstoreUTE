import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/admin_shell.dart';
import 'app/providers.dart';
import 'core/api_client.dart';
import 'core/session_storage.dart';
import 'features/auth/presentation/admin_login_screen.dart';
import 'theme/admin_theme.dart';

Future<void> main() async {
  runApp(const BootstrapApp());
}

class BootstrapApp extends StatelessWidget {
  const BootstrapApp({super.key});

  Future<_BootstrapData> _init() async {
    final storage = SessionStorage();
    final client = await ApiClient.create(storage);
    return _BootstrapData(storage: storage, client: client);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootstrapData>(
      future: _init(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final data = snapshot.data!;
        return ProviderScope(
          overrides: [
            sessionStorageProvider.overrideWithValue(data.storage),
            apiClientProvider.overrideWithValue(data.client),
          ],
          child: MyApp(storage: data.storage),
        );
      },
    );
  }
}

class _BootstrapData {
  const _BootstrapData({required this.storage, required this.client});

  final SessionStorage storage;
  final ApiClient client;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.storage});

  final SessionStorage storage;

  Future<bool> _hasToken() async {
    final token = await storage.getToken();
    return token != null && token.isNotEmpty;
  }

  ThemeData _buildTheme(Brightness brightness) {
    return brightness == Brightness.dark ? AdminTheme.dark() : AdminTheme.light();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản trị Bookstore',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
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