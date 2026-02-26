import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/colors.dart';
import '../core/text_styles.dart';
import '../models/book.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class BookCard extends StatefulWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool _isHovered = false;

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
          width: 200,
          transform: Matrix4.identity()..translate(0, _isHovered ? -8.0 : 0.0),
          margin: const EdgeInsets.only(
            right: 24,
            bottom: 16,
          ), // Spacing between cards
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
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
                  child: _buildBookImage(
                    widget.book.imageUrl,
                    widget.book.title,
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
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.book.author,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.book.rating.toString(),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${widget.book.reviewCount})',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.book.price}',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).addToCart(widget.book);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.book.title} added to cart!',
                                ),
                              ),
                            );
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

  Widget _buildBookImage(String imageUrl, String title) {
    if (imageUrl.isEmpty) {
      return _buildErrorImage(title);
    }
    if (imageUrl.startsWith('http') || imageUrl.startsWith('blob:') || kIsWeb) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('Image Load Error for $imageUrl: $error');
          }
          return _buildErrorImage(title);
        },
      );
    } else if (imageUrl.isNotEmpty) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorImage(title),
      );
    }
    return _buildErrorImage(title);
  }

  Widget _buildErrorImage(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 20,
            child: Icon(
              Icons.book_outlined,
              size: 64,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primary.withOpacity(0.6),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            bottom: 20,
            child: Text(
              'EduShare Edition',
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.3),
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
