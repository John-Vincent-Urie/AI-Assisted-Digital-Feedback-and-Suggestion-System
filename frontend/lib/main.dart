import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/admin/admin_dashboard_page.dart';
import 'features/auth/create_account_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/spotify_callback_page.dart';
import 'features/mood/mood_input_page.dart';
import 'features/onboarding/get_started_page.dart';
import 'features/onboarding/intro_page.dart';
import 'features/onboarding/welcome_page.dart';
import 'features/recommendations/recommendations_page.dart';

void main() {
  runApp(const EmoTuneApp());
}

class EmoTuneApp extends StatelessWidget {
  const EmoTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EmoTune',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const GetStartedPage(),
      routes: {
        '/intro': (_) => const IntroPage(),
        '/login': (_) => const LoginPage(),
        '/create-account': (_) => const CreateAccountPage(),
        '/spotify-callback': (_) => const SpotifyCallbackPage(),
        '/welcome': (_) => const WelcomePage(),
        '/home': (_) => const MoodInputPage(),
        '/mood': (_) => const MoodInputPage(),
        '/recommendations': (_) => const RecommendationsPage(),
        '/admin': (_) => const AdminDashboardPage(),
      },
    );
  }
}
