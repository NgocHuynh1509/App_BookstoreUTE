import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class AdminForgotPasswordScreen extends StatefulWidget {
  const AdminForgotPasswordScreen({super.key});

  @override
  State<AdminForgotPasswordScreen> createState() =>
      _AdminForgotPasswordScreenState();
}

class _AdminForgotPasswordScreenState
    extends State<AdminForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _message;
  Color _messageColor = Colors.green;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final msg = await AuthService.forgotPassword(
        email: _emailController.text.trim(),
      );
      setState(() {
        _message = msg.isNotEmpty ? msg : 'Vui lòng kiểm tra email';
        _messageColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
        _messageColor = Colors.red;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_reset_outlined,
                    size: 60,
                    color: Color(0xFF4C6FFF),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Khôi phục mật khẩu',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhập email của admin. Hệ thống sẽ gửi hướng dẫn đặt lại mật khẩu nếu email hợp lệ.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'admin@example.com',
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_message != null) ...[
                    Text(
                      _message!,
                      style: TextStyle(
                        color: _messageColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  PrimaryButton(
                    text: 'Gửi yêu cầu',
                    isLoading: _isLoading,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

