import 'package:flutter/material.dart';

import '../../widgets/emotune_logo.dart';
import '../../widgets/primary_pill_button.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 4),
              const EmoTuneLogo(size: 106),
              const Spacer(flex: 5),
              PrimaryPillButton(
                label: 'Get Started',
                onPressed: () => Navigator.pushNamed(context, '/intro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
