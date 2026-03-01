import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import 'dart:io';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: isMobile
            ? Text(
                'EduShare',
                style: AppTextStyles.h2.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textPrimaryDark
                      : AppColors.primary,
                ),
              )
            : Row(
                children: [
                  // Logo
                  InkWell(
                    onTap: () => context.go('/home'),
                    child: Text(
                      'EduShare',
                      style: AppTextStyles.h2.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textPrimaryDark
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Search Bar
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              Theme.of(context).dividerTheme.color ??
                              AppColors.divider,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                try {
                                  Provider.of<SearchProvider>(
                                    context,
                                    listen: false,
                                  ).setQuery(value);
                                } catch (e) {
                                  // Handle provider not found
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Search for books, authors...',
                                hintStyle: AppTextStyles.bodyMedium,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      actions: isMobile
          ? [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        key: ValueKey<bool>(themeProvider.isDarkMode),
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    onPressed: () => themeProvider.toggleTheme(),
                  );
                },
              ),
              IconButton(
                // Mobile Search Icon
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () => context.go('/cart'),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.menu,
                  color: Theme.of(context).iconTheme.color,
                ),
                onSelected: (value) {
                  if (value == 'home') context.go('/home');
                  if (value == 'orders') context.go('/orders');
                  if (value == 'favorites') context.go('/favorites');
                  if (value == 'listings') context.go('/my_listings');
                  if (value == 'sell') context.go('/sell');
                  if (value == 'profile') context.go('/profile');
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'home',
                    child: ListTile(
                      leading: Icon(Icons.home),
                      title: Text('Home'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'orders',
                    child: ListTile(
                      leading: Icon(Icons.history),
                      title: Text('My Orders'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'favorites',
                    child: ListTile(
                      leading: Icon(Icons.favorite_border),
                      title: Text('Favorites'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'listings',
                    child: ListTile(
                      leading: Icon(Icons.list_alt),
                      title: Text('My Listings'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'sell',
                    child: ListTile(
                      leading: Icon(Icons.storefront),
                      title: Text('Sell Book'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ]
          : [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        key: ValueKey<bool>(themeProvider.isDarkMode),
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    onPressed: () => themeProvider.toggleTheme(),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: Theme.of(context).iconTheme.color,
                ),
                tooltip: 'Home',
                onPressed: () => context.go('/home'),
              ),
              IconButton(
                icon: Icon(
                  Icons.history,
                  color: Theme.of(context).iconTheme.color,
                ),
                tooltip: 'My Orders',
                onPressed: () => context.go('/orders'),
              ),
              IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () => context.go('/favorites'),
              ),
              IconButton(
                icon: Icon(
                  Icons.list_alt,
                  color: Theme.of(context).iconTheme.color,
                ),
                tooltip: 'My Listings',
                onPressed: () => context.go('/my_listings'),
              ),
              IconButton(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () => context.go('/cart'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => context.go('/sell'),
                icon: Icon(
                  Icons.storefront,
                  color: Theme.of(context).iconTheme.color,
                ),
                label: const Text(
                  'SELL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: Consumer<UserProvider>(
                    builder: (context, user, _) {
                      return CircleAvatar(
                        backgroundColor: AppColors.secondary,
                        radius: 16,
                        backgroundImage:
                            user.profileImage.isNotEmpty &&
                                !user.profileImage.startsWith('http')
                            ? FileImage(File(user.profileImage))
                                  as ImageProvider
                            : (user.profileImage.startsWith('http')
                                  ? NetworkImage(user.profileImage)
                                  : null),
                        child: user.profileImage.isEmpty
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : 'U',
                                style: AppTextStyles.button,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
