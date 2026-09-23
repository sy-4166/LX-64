import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = LX64Localizations.of(context);
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LX-64'),
        actions: [
          IconButton(
            tooltip: l10n.isChinese ? '退出登录' : 'Log out',
            onPressed: () async {
              await AuthService().logout();

              if (!context.mounted) return;

              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.isChinese ? '欢迎来到 LX-64' : 'Welcome to LX-64',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.isChinese
                    ? '你的个人成长旅程，从这里开始。'
                    : 'Your personal growth journey starts here.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/interview',
                    );
                  },
                  child: Text(
                    l10n.isChinese
                        ? '开始人生访谈'
                        : 'Start Your Interview',
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
