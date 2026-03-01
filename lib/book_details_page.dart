import 'package:flutter/material.dart';
import 'core/colors.dart';
import 'core/text_styles.dart';
import 'models/book.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'widgets/custom_app_bar.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class BookDetailsPage extends StatefulWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  @override
  Widget build(BuildContext context) {
    // Determine if mobile layout is needed
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isMobile
              ? _MobileLayout(
                  book: widget.book,
                  description: widget.book.description,
                  isLoading: false,
                )
              : _DesktopLayout(
                  book: widget.book,
                  description: widget.book.description,
                  isLoading: false,
                ),
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final Book book;
  final String description;
  final bool isLoading;

  const _DesktopLayout({
    required this.book,
    required this.description,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Image & Buttons
        SizedBox(
          width: 400,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(16),
                child: _buildBookImage(context, book.imageUrl, height: 450),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).addToCart(book);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${book.title} added to cart!'),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              onPressed: () => context.push('/cart'),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFF9F00,
                        ), // Flipkart Yellow
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      child: const Text(
                        'ADD TO CART',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/checkout', extra: {book: 1});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFB641B,
                        ), // Flipkart Orange
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      child: const Text(
                        'BUY NOW',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Right Column: Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Breadcrumb(title: book.title),
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    book.title,
                    style: AppTextStyles.h2.copyWith(fontSize: 28),
                  ),
                  Consumer<FavoritesProvider>(
                    builder: (context, favorites, _) {
                      final isFav = favorites.isFavorite(book);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : AppColors.textSecondary,
                          size: 32,
                        ),
                        onPressed: () => favorites.toggleFavorite(book),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(
                          book.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, size: 12, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${book.reviewCount} Ratings & Reviews',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '₹${book.price}',
                    style: AppTextStyles.h1.copyWith(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '₹${(book.price * (1 + book.discountPercentage / 100)).toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${book.discountPercentage.toInt()}% off',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Offers
              const Text(
                'Available offers',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _OfferItem(
                icon: Icons.local_offer,
                text:
                    'Bank Offer 5% Unlimited Cashback on Axis Bank Credit Card',
              ),
              _OfferItem(
                icon: Icons.local_offer,
                text:
                    'Special Price Get extra 10% off (price inclusive of discount)',
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                'Product Description',
                style: AppTextStyles.h3.copyWith(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Text(description, style: AppTextStyles.bodyLarge),
              const SizedBox(height: 24),

              // Specs
              Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: Text('Author', style: TextStyle(color: Colors.grey)),
                  ),
                  Text(
                    book.author,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Mock specs
              Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      'Language',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Text(
                    'English',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final Book book;
  final String description;
  final bool isLoading;

  const _MobileLayout({
    required this.book,
    required this.description,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildBookImage(context, book.imageUrl, height: 300)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(book.title, style: AppTextStyles.h2)),
            Consumer<FavoritesProvider>(
              builder: (context, favorites, _) {
                final isFav = favorites.isFavorite(book);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : AppColors.textSecondary,
                    size: 28,
                  ),
                  onPressed: () => favorites.toggleFavorite(book),
                );
              },
            ),
          ],
        ),
        Text(book.author, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('₹${book.price}', style: AppTextStyles.h1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    book.rating.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 12, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : Text(description, style: AppTextStyles.bodyLarge),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).addToCart(book);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${book.title} added to cart!'),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'VIEW CART',
                        onPressed: () => context.push('/cart'),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                child: const Text('ADD TO CART'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.push('/checkout', extra: {book: 1});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB641B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                child: const Text('BUY NOW'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Helper for displaying book image (Network or File)
Widget _buildBookImage(
  BuildContext context,
  String imageUrl, {
  double? height,
}) {
  if (imageUrl.startsWith('http') || imageUrl.startsWith('blob:') || kIsWeb) {
    return Image.network(
      imageUrl,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          _buildErrorImage(context, height),
    );
  } else if (imageUrl.isNotEmpty) {
    return Image.file(
      File(imageUrl),
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          _buildErrorImage(context, height),
    );
  }
  return _buildErrorImage(context, height);
}

Widget _buildErrorImage(BuildContext context, double? height) {
  return Container(
    height: height,
    width: height != null ? height * 0.6 : null,
    color: Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]
        : Colors.grey[200],
    child: Center(
      child: Icon(
        Icons.book,
        size: 48,
        color: Theme.of(context).iconTheme.color,
      ),
    ),
  );
}

class _Breadcrumb extends StatelessWidget {
  final String title;
  const _Breadcrumb({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Home > Books > $title',
      style: TextStyle(fontSize: 12, color: Colors.grey),
    );
  }
}

class _OfferItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _OfferItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
