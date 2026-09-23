import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final l10n = LX64Localizations.of(context);
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        l10n.isChinese
            ? '请输入 Email。'
            : 'Please enter your email.',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _authService.resetPassword(email: email);

      if (!mounted) return;

      _showMessage(
        l10n.isChinese
            ? '密码重置邮件已发送，请检查你的 Email。'
            : 'Password reset email sent. Please check your email.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'invalid-email') {
        _showMessage(
          l10n.isChinese
              ? 'Email 格式不正确。'
              : 'Invalid email address.',
        );
      } else {
        _showMessage(
          l10n.isChinese
              ? '发送失败，请确认 Email 是否正确。'
              : 'Could not send reset email. Please check your email.',
        );
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        l10n.isChinese
            ? '发送失败，请稍后再试。'
            : 'Failed to send email. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LX64Localizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.isChinese ? '忘记密码' : 'Forgot Password',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                l10n.isChinese
                    ? '重置你的密码'
                    : 'Reset your password',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.isChinese
                    ? '输入注册时使用的 Email，我们会发送密码重置邮件。'
                    : 'Enter your registered email and we will send you a password reset email.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: const Color(0xFF11141C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _loading ? null : _resetPassword,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.isChinese
                              ? '发送重置邮件'
                              : 'Send Reset Email',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
