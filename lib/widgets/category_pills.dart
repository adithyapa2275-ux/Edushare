import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/colors.dart';

class CategoryPills extends StatelessWidget {
  const CategoryPills({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'IT & CS',
        'query': 'Computer Science India',
        'icon': Icons.computer,
        'color': const Color(0xFFE3F2FD),
        'iconColor': const Color(0xFF1E88E5),
      },
      {
        'title': 'Medical',
        'query': 'Nursing Medical India',
        'icon': Icons.medical_services_outlined,
        'color': const Color(0xFFF1F8E9),
        'iconColor': const Color(0xFF43A047),
      },
      {
        'title': 'Engineering',
        'query': 'Engineering India S.Chand',
        'icon': Icons.engineering_outlined,
        'color': const Color(0xFFFFF3E0),
        'iconColor': const Color(0xFFFB8C00),
      },
      {
        'title': 'Plus Two',
        'query': 'NCERT CBSE Class 12',
        'icon': Icons.menu_book_outlined,
        'color': const Color(0xFFF3E5F5),
        'iconColor': const Color(0xFF8E24AA),
      },
      {
        'title': 'Study Material',
        'query': 'NCERT CBSE Indian Textbooks',
        'icon': Icons.description_outlined,
        'color': const Color(0xFFE0F7FA),
        'iconColor': const Color(0xFF00ACC1),
      },
      {
        'title': 'Free Books',
        'query': 'free academic books',
        'icon': Icons.card_giftcard,
        'color': const Color(0xFFFCE4EC),
        'iconColor': const Color(0xFFD81B60),
      },
    ];

    return Container(
      height: 125,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 28),
            child: InkWell(
              onTap: () {
                context.push(
                  '/category',
                  extra: {
                    'title': category['title'],
                    'query': category['query'],
                  },
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 70,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? (category['iconColor'] as Color).withValues(
                                alpha: 0.15,
                              )
                            : category['color'] as Color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (category['iconColor'] as Color).withValues(
                            alpha: 0.1,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: category['iconColor'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
