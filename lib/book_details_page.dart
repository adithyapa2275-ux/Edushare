import 'package:flutter/material.dart';
import 'core/colors.dart';
import 'core/text_styles.dart';
import 'models/book.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/marketplace_provider.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/book_image.dart';

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
    return Column(
      children: [
        Row(
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
                    child: BookImage(
                      imageUrl: book.imageUrl,
                      title: book.title,
                      height: 450,
                    ),
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
                            ScaffoldMessenger.of(context).clearSnackBars();
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
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 28,
                          color: Theme.of(context).textTheme.displayLarge?.color,
                        ),
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
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
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
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '₹${book.originalPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${book.effectiveDiscountPercentage.toInt()}% off',
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

                  // Trust & Safety Markers
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _TrustMarker(
                          icon: Icons.high_quality,
                          title: 'Quality Checked',
                          subtitle: 'Verified for condition & authenticity',
                        ),
                        const Divider(height: 24),
                        _TrustMarker(
                          icon: Icons.security,
                          title: 'Secure Payment',
                          subtitle: '100% safe and encrypted transactions',
                        ),
                        const Divider(height: 24),
                        _TrustMarker(
                          icon: Icons.assignment_return,
                          title: '7 Day Return',
                          subtitle: 'Easy returns if not satisfied',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Seller Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            book.sellerName[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Seller: ${book.sellerName}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!book.isDonation &&
                                      book.price > 0 &&
                                      book.effectiveDiscountPercentage > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.assured,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'VERIFIED',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                'Joined since ${book.uploadedAt != null ? "${book.uploadedAt!.day}/${book.uploadedAt!.month}/${book.uploadedAt!.year}" : "2024"}',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '4.5',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Text(
                              'Seller Rating',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Product Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Text(book.description, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),

                  // Specs
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text('Author', style: TextStyle(color: Colors.grey)),
                      ),
                      Text(book.author, style: TextStyle(fontWeight: FontWeight.w500)),
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
                      Text('English', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        _SimilarBooksShelf(currentBook: book),
        const SizedBox(height: 48),
      ],
    );
  }
}
class _TrustMarker extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustMarker({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
        Center(
          child: BookImage(
            imageUrl: book.imageUrl,
            title: book.title,
            height: 300,
          ),
        ),
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
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('₹${book.price.toStringAsFixed(0)}', style: AppTextStyles.h1),
            const SizedBox(width: 8),
            Text(
              '₹${book.originalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${book.effectiveDiscountPercentage.toInt()}% off',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Spacer(),
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
        // Trust Markers (Mobile)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _TrustMarker(
                icon: Icons.high_quality,
                title: 'Quality Checked',
                subtitle: 'Verified condition',
              ),
              const SizedBox(height: 12),
              _TrustMarker(
                icon: Icons.security,
                title: 'Secure',
                subtitle: '100% Safe Payments',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : Text(
                book.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
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
                  ScaffoldMessenger.of(context).clearSnackBars();
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
        const SizedBox(height: 48),
        _SimilarBooksShelf(currentBook: book),
        const SizedBox(height: 24),
      ],
    );
  }
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

class _SimilarBooksShelf extends StatelessWidget {
  final Book currentBook;

  const _SimilarBooksShelf({required this.currentBook});

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, marketplace, child) {
        if (marketplace.isLoading) {
          return const SizedBox(
            height: 320,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Filter and sort listings
        final List<Book> similarBooks = marketplace.recentListings.where((b) => b.id != currentBook.id).toList();

        similarBooks.sort((a, b) {
          int aScore = 0;
          int bScore = 0;

          // 1. Categories Match (weight: 2 per match)
          for (var cat in a.categories) {
            if (currentBook.categories.contains(cat)) aScore += 2;
          }
          for (var cat in b.categories) {
            if (currentBook.categories.contains(cat)) bScore += 2;
          }

          // 2. Author Match (weight: 5)
          if (a.author.toLowerCase() == currentBook.author.toLowerCase()) aScore += 5;
          if (b.author.toLowerCase() == currentBook.author.toLowerCase()) bScore += 5;

          // 3. Seller Match (weight: 2)
          if (a.sellerName.toLowerCase() == currentBook.sellerName.toLowerCase()) aScore += 2;
          if (b.sellerName.toLowerCase() == currentBook.sellerName.toLowerCase()) bScore += 2;

          // 4. Title Keywords Match (weight: 1 per common word)
          final currentWords = currentBook.title.toLowerCase().split(' ').where((w) => w.length > 3).toSet();
          final aWords = a.title.toLowerCase().split(' ').where((w) => w.length > 3).toSet();
          final bWords = b.title.toLowerCase().split(' ').where((w) => w.length > 3).toSet();
          aScore += aWords.intersection(currentWords).length;
          bScore += bWords.intersection(currentWords).length;

          // 5. Price Similarity Match (weight: 2 if within 20% price range)
          if (a.price > 0 && currentBook.price > 0) {
            final diff = (a.price - currentBook.price).abs();
            if (diff / currentBook.price <= 0.2) aScore += 2;
          }
          if (b.price > 0 && currentBook.price > 0) {
            final diff = (b.price - currentBook.price).abs();
            if (diff / currentBook.price <= 0.2) bScore += 2;
          }

          // Descending sort (highest score first)
          return bScore.compareTo(aScore);
        });

        if (similarBooks.isEmpty) {
          return const SizedBox.shrink();
        }

        final displayBooks = similarBooks.take(10).toList(); // Max 10 recommended

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended for You',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 480, // Increased height to completely prevent overflow
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: displayBooks.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 180, // Slightly reduced width for better mobile fit
                    child: _RecommendedBookCard(book: displayBooks[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecommendedBookCard extends StatefulWidget {
  final Book book;

  const _RecommendedBookCard({required this.book});

  @override
  State<_RecommendedBookCard> createState() => _RecommendedBookCardState();
}

class _RecommendedBookCardState extends State<_RecommendedBookCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Pushes a new book details page, keeping the backstack
        context.push('/book', extra: widget.book);
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(
            0.0,
            _isHovered ? -8.0 : 0.0,
            0.0,
          ),
          margin: const EdgeInsets.only(
            right: 16,
            bottom: 16,
          ), // Spacing between cards
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.05),
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Stack(
                    children: [
                      BookImage(
                        imageUrl: widget.book.imageUrl,
                        title: widget.book.title,
                      ),
                      if (widget.book.isDonation || widget.book.price == 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Text(
                              'FREE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 16),
                      maxLines: 2, // Allow 2 lines for title
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.book.author,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.book.isDonation || widget.book.price == 0
                          ? 'FREE'
                          : '₹${widget.book.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Pushes a new book details page when button is pressed
                          context.push('/book', extra: widget.book);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFB641B),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'View / Buy',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ), // Close Expanded
            ],
          ),
        ),
      ),
    );
  }
}

