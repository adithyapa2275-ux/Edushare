import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMoreTap;

  const SectionHeader({super.key, required this.title, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h2),
          if (onMoreTap != null)
            TextButton(
              onPressed: onMoreTap,
              child: Text(
                'View All',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.secondary,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
