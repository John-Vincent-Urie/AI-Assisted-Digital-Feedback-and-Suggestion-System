import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/emotune_logo.dart';
import '../../widgets/primary_pill_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Text(
                'Welcome to EmoTune !',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 28,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Let your mood decide your music',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
              const Spacer(flex: 2),
              const EmoTuneLogo(size: 98),
              const Spacer(flex: 3),
              PrimaryPillButton(
                label: 'Continue',
                onPressed: () => Navigator.pushNamed(context, '/home'),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
