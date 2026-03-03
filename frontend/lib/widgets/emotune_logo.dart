import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class EmoTuneLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const EmoTuneLogo({
    super.key,
    this.size = 96,
    this.showWordmark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.accentBlue, AppColors.accentLime],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.multitrack_audio_rounded,
            color: Colors.white.withOpacity(0.9),
            size: size * 0.38,
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 10),
          const Text(
            'EmoTune',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
