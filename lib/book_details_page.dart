import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/colors.dart';
import 'core/text_styles.dart';
import 'models/book.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/book_image.dart';

class BookDetailsPage extends StatefulWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  void _showCartToast(BuildContext context, String title) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CartToast(
        title: title,
        onDone: () => entry.remove(),
        onViewCart: () {
          entry.remove();
          context.push('/cart');
        },
      ),
    );
    overlay.insert(entry);
  }

  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 1; i <= 5; i++) {
      if (i <= fullStars) {
        stars.add(const Icon(Icons.star, color: Color(0xFFFDCB6E), size: 20));
      } else if (i == fullStars + 1 && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, color: Color(0xFFFDCB6E), size: 20));
      } else {
        stars.add(const Icon(Icons.star_border, color: Color(0xFFFDCB6E), size: 20));
      }
    }
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final dividerColor = isDark ? AppColors.dividerDark : AppColors.divider;

    // Build categories/tags widgets
    Widget buildCategoryChips() {
      if (widget.book.categories.isEmpty) return const SizedBox.shrink();
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.book.categories.map((category) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: dividerColor),
            ),
            child: Text(
              category,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? Colors.white70 : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      );
    }

    // Build specs/metadata widgets
    Widget buildSpecifications() {
      final specItems = <Map<String, String>>[];
      if (widget.book.isbn.isNotEmpty) {
        specItems.add({'label': 'ISBN', 'value': widget.book.isbn});
      }
      specItems.add({'label': 'Seller Type', 'value': widget.book.uploaderId != null ? 'Student Listing' : 'EduShare Store'});
      specItems.add({'label': 'Seller Name', 'value': widget.book.sellerName});
      if (widget.book.uploadedAt != null) {
        final date = widget.book.uploadedAt!;
        specItems.add({
          'label': 'Listed On',
          'value': '${date.day}/${date.month}/${date.year}'
        });
      }

      if (specItems.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specifications',
              style: AppTextStyles.h3.copyWith(color: primaryTextColor),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: specItems.length,
              separatorBuilder: (context, index) => Divider(color: dividerColor, height: 16),
              itemBuilder: (context, index) {
                final item = specItems[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label']!,
                      style: AppTextStyles.bodyMedium.copyWith(color: secondaryTextColor),
                    ),
                    Text(
                      item['value']!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: primaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    }

    // Book Price Display
    Widget buildPriceDisplay() {
      final isFree = widget.book.isDonation || widget.book.price == 0;
      if (isFree) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volunteer_activism, color: AppColors.success, size: 18),
              const SizedBox(width: 6),
              Text(
                'FREE / DONATION',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }

      final hasDiscount = widget.book.effectiveDiscountPercentage > 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${widget.book.price.toStringAsFixed(0)}',
                style: AppTextStyles.h1.copyWith(
                  color: primaryTextColor,
                  fontSize: 36,
                ),
              ),
              if (hasDiscount) ...[
                const SizedBox(width: 12),
                Text(
                  '₹${widget.book.originalPrice.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: secondaryTextColor,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${widget.book.effectiveDiscountPercentage.toInt()}% OFF',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    // Safety badge for peer-to-peer student transactions
    Widget buildSafetyBadge() {
      if (widget.book.uploaderId == null) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.security, color: Colors.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Peer-to-Peer Transaction: For safety, always meet in a public campus location to exchange books.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? Colors.amber[200] : Colors.amber[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Left block content (Cover & desktop actions)
    Widget buildLeftBlock() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cover Image card with overlaid favorite icon
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 2 / 3,
                  child: BookImage(
                    imageUrl: widget.book.imageUrl,
                    title: widget.book.title,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Consumer<FavoritesProvider>(
                    builder: (context, favProvider, child) {
                      final isFav = favProvider.isFavorite(widget.book);
                      return CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : AppColors.primary,
                          ),
                          onPressed: () {
                            favProvider.toggleFavorite(widget.book);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.push('/checkout', extra: {widget.book: 1});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 2,
              ),
              child: Text(
                'BUY NOW',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).addToCart(widget.book);
                _showCartToast(context, widget.book.title);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'ADD TO CART',
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ],
      );
    }

    // Right block content (Main text, details, specs)
    Widget buildRightBlock() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chips
          buildCategoryChips(),
          const SizedBox(height: 16),

          // Title
          Text(
            widget.book.title,
            style: AppTextStyles.h1.copyWith(
              color: primaryTextColor,
              fontSize: isMobile ? 26 : 36,
            ),
          ),
          const SizedBox(height: 8),

          // Author
          Text(
            'by ${widget.book.author}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: secondaryTextColor,
              fontStyle: FontStyle.italic,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),

          // Rating
          Row(
            children: [
              _buildStarRating(widget.book.rating),
              const SizedBox(width: 8),
              Text(
                widget.book.rating.toString(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${widget.book.reviewCount} reviews)',
                style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: dividerColor),
          const SizedBox(height: 16),

          // Price Display
          buildPriceDisplay(),
          const SizedBox(height: 20),

          // Safety message
          buildSafetyBadge(),
          const SizedBox(height: 16),

          // Description Section
          Text(
            'About the Book',
            style: AppTextStyles.h3.copyWith(color: primaryTextColor),
          ),
          const SizedBox(height: 8),
          Text(
            widget.book.description,
            style: AppTextStyles.bodyMedium.copyWith(color: secondaryTextColor, height: 1.6),
          ),
          const SizedBox(height: 24),
          Divider(color: dividerColor),
          const SizedBox(height: 16),

          // Specifications list
          buildSpecifications(),
          const SizedBox(height: 32),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back, color: AppColors.primary),
                    label: Text(
                      'Back to browse',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Responsive body layout
                  if (isMobile) ...[
                    buildLeftBlock(),
                    const SizedBox(height: 24),
                    buildRightBlock(),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left block (Cover, buttons)
                        Expanded(
                          flex: 4,
                          child: buildLeftBlock(),
                        ),
                        const SizedBox(width: 48),
                        // Right block (Meta details)
                        Expanded(
                          flex: 7,
                          child: buildRightBlock(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: isMobile
          ? Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              child: Row(
                children: [
                  Consumer<FavoritesProvider>(
                    builder: (context, favProvider, child) {
                      final isFav = favProvider.isFavorite(widget.book);
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            favProvider.toggleFavorite(widget.book);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).addToCart(widget.book);
                        _showCartToast(context, widget.book.title);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: AppTextStyles.button.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/checkout', extra: {widget.book: 1});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Buy Now',
                        style: AppTextStyles.button.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

// ─── Overlay Toast (Matching BookCard) ───────────────────────────────────────

class _CartToast extends StatefulWidget {
  final String title;
  final VoidCallback onDone;
  final VoidCallback onViewCart;

  const _CartToast({
    required this.title,
    required this.onDone,
    required this.onViewCart,
  });

  @override
  State<_CartToast> createState() => _CartToastState();
}

class _CartToastState extends State<_CartToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    // Auto-dismiss after 2.5 s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _ctrl.reverse().then((_) => widget.onDone());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF323232),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF00C48C), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${widget.title} added to cart!',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onViewCart,
                  child: const Text(
                    'VIEW CART',
                    style: TextStyle(
                      color: Color(0xFF00C48C),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
