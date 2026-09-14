import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GlowCard extends StatelessWidget {
  final Widget child;
  const GlowCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.blackSurface : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.yellow : AppColors.darkText,
          width: 1.2,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: AppColors.yellowGlow,
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
