import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/text_styles.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/Book_Library_zoom_backgrounds_charlene_chronicles_33-1024x576.png', // Generic library image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'India\'s #1 Academic Marketplace',
                  style: AppTextStyles.h1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Access NCERT, Engineering, Nursing & Degree materials from top Indian publishers.\nBuy and sell your used books with ease.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                  ),
                  child: const Text('Shop Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
