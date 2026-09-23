import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'localization.dart';
import 'routes.dart';

class LX64App extends StatelessWidget {
  const LX64App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LX-64',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08090D),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        LX64LocalizationsDelegate(),
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return const Locale('en');
        }

        if (locale.languageCode == 'zh') {
          return const Locale('zh');
        }

        return const Locale('en');
      },
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const _HomeEntry();
        }

        return const _LoginEntry();
      },
    );
  }
}

class _LoginEntry extends StatelessWidget {
  const _LoginEntry();

  @override
  Widget build(BuildContext context) {
    return LX64Routes.routes['/login']!(context);
  }
}

class _HomeEntry extends StatelessWidget {
  const _HomeEntry();

  @override
  Widget build(BuildContext context) {
    return LX64Routes.routes['/home']!(context);
  }
}
