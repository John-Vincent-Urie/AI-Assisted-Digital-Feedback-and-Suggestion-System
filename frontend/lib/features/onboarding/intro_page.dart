import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/emotune_logo.dart';
import '../../widgets/primary_pill_button.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 18),
              const EmoTuneLogo(size: 98),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your mood matters. EmoTune listens to what you feel '
                      'and turns it into playlists that match your moment.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.8,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 18),
                    PrimaryPillButton(
                      label: 'Continue',
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      height: 38,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
