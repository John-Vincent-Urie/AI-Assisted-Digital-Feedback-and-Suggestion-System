import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class PrimaryPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;

  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 42,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
