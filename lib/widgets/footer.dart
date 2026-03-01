import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/text_styles.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).cardColor
          : AppColors.primary,
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EduShare',
                      style: AppTextStyles.h2.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).textTheme.displayMedium?.color
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your premium destination for books.\nDiscover, Read, Inspire.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore',
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    _FooterLink('Bestsellers'),
                    _FooterLink('New Arrivals'),
                    _FooterLink('Authors'),
                    _FooterLink('Collections'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Help',
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    _FooterLink('Contact Us'),
                    _FooterLink('FAQs'),
                    _FooterLink('Shipping & Returns'),
                    _FooterLink('Privacy Policy'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect',
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.facebook, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ), // Instagram
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            '© 2026 EduShare. All rights reserved.',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  const _FooterLink(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {},
        child: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
        ),
      ),
    );
  }
}
