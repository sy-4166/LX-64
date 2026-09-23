import 'package:flutter/material.dart';

import '../screens/interview/interview_page.dart';
import '../screens/welcome/welcome_page.dart';

class LX64Routes {
  static Map<String, WidgetBuilder> get routes {
    return {
      '/': (context) => const WelcomePage(),
      '/interview': (context) => const InterviewPage(),
    };
  }
}
