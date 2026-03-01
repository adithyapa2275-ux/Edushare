import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'category_books_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'book_details_page.dart';
import 'cart_page.dart';
import 'checkout_page.dart';
import 'models/book.dart';
import 'core/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/search_provider.dart';
import 'providers/sell_provider.dart';
import 'providers/user_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/theme_provider.dart';
import 'orders_page.dart';
import 'favorites_page.dart';
import 'sell_book_page.dart';
import 'my_listings_page.dart';
import 'profile_page.dart';
import 'admin/admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isLoggingIn =
        state.matchedLocation == '/login' || state.matchedLocation == '/';
    final bool isRegistering = state.matchedLocation == '/register';

    if (user == null) {
      // Not logged in -> can only be on login or register
      if (!isLoggingIn && !isRegistering) return '/login';
      return null;
    }

    // Logged in -> shouldn't be on login or register
    if (isLoggingIn || isRegistering) {
      if (user.email == 'admin@edushare.com') return '/admin';
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/book',
      builder: (context, state) {
        final book = state.extra as Book;
        return BookDetailsPage(book: book);
      },
    ),
    GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
    GoRoute(
      path: '/checkout',
      builder: (context, state) {
        final items = state.extra as Map<Book, int>;
        return CheckoutPage(items: items);
      },
    ),
    GoRoute(path: '/orders', builder: (context, state) => const OrdersPage()),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
    GoRoute(path: '/sell', builder: (context, state) => const SellBookPage()),
    GoRoute(
      path: '/my_listings',
      builder: (context, state) => const MyListingsPage(),
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/category',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        return CategoryBooksPage(
          title: extras['title'] as String,
          query: extras['query'] as String,
        );
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
        ChangeNotifierProvider(create: (context) => SearchProvider()),
        ChangeNotifierProvider(create: (context) => SellProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (context) => AdminProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'EduShare',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            themeAnimationDuration: const Duration(milliseconds: 600),
            themeAnimationCurve: Curves.easeInOut,
            scrollBehavior: MyScrollBehavior(),
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
