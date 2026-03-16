import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/colors.dart';
import '../models/book.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

import 'book_image.dart';

class BookCard extends StatefulWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool _isHovered = false;

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


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
            right: 24,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Padding(
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.book.rating >= 4.0
                                ? AppColors.success
                                : AppColors.warning,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Text(
                                widget.book.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.star,
                                size: 10,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '(${widget.book.reviewCount})',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book.isDonation || widget.book.price == 0
                                    ? 'FREE'
                                    : '₹${widget.book.price.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (!widget.book.isDonation &&
                                  widget.book.price > 0 &&
                                  widget.book.effectiveDiscountPercentage > 0)
                                Row(
                                  children: [
                                    Text(
                                      '₹${widget.book.originalPrice.toStringAsFixed(0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.book.effectiveDiscountPercentage.toInt()}% off',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).addToCart(widget.book);
                            _showCartToast(context, widget.book.title);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Overlay Toast ───────────────────────────────────────────────────────────

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
