import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _authService = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final l10n = LX64Localizations.of(context);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage(
        l10n.isChinese
            ? '请填写所有资料。'
            : 'Please fill in all fields.',
      );
      return;
    }

    if (password.length < 6) {
      _showMessage(
        l10n.isChinese
            ? '密码至少需要 6 个字符。'
            : 'Password must be at least 6 characters.',
      );
      return;
    }

    if (password != confirm) {
      _showMessage(
        l10n.isChinese
            ? '两次输入的密码不一致。'
            : 'Passwords do not match.',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _authService.register(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showMessage(_authError(e.code, l10n));
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        l10n.isChinese
            ? '注册失败，请稍后再试。'
            : 'Registration failed. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _authError(String code, LX64Localizations l10n) {
    if (l10n.isChinese) {
      switch (code) {
        case 'email-already-in-use':
          return '这个 Email 已经注册过了。';
        case 'invalid-email':
          return 'Email 格式不正确。';
        case 'weak-password':
          return '密码强度不足。';
        case 'operation-not-allowed':
          return 'Email 登录方式尚未启用。';
        default:
          return '注册失败，请稍后再试。';
      }
    }

    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled.';
      default:
        return 'Registration failed. Please try again.';
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
          l10n.isChinese ? '注册' : 'Register',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                l10n.isChinese
                    ? '创建你的 LX-64 账号'
                    : 'Create your LX-64 account',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration('Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _decoration(
                  l10n.isChinese ? '密码' : 'Password',
                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: _decoration(
                  l10n.isChinese ? '确认密码' : 'Confirm Password',
                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.isChinese ? '注册' : 'Register',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(
    String label, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFF11141C),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
