import 'package:flutter/material.dart';
import 'core/colors.dart';
import 'core/text_styles.dart';
import 'models/book.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'widgets/custom_app_bar.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text("Your cart is empty!", style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  Text(
                    "Explore our books and add items now.",
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text("Shop Now", style: AppTextStyles.button),
                  ),
                ],
              ),
            );
          }

          // Cart with items
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _buildCartList(context, cart)),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: _buildPriceDetails(context, cart),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildCartList(context, cart),
                      const SizedBox(height: 24),
                      _buildPriceDetails(context, cart),
                    ],
                  );
                }
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return MediaQuery.of(context).size.width <= 800 &&
                  cart.items.isNotEmpty
              ? _buildBottomBar(context, cart)
              : const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCartList(BuildContext context, CartProvider cart) {
    return Column(
      children: cart.items.entries.map((entry) {
        return _CartItemTile(
          book: entry.key,
          quantity: entry.value,
          onIncrement: () => cart.incrementQuantity(entry.key),
          onDecrement: () => cart.decrementQuantity(entry.key),
          onRemove: () => cart.removeFromCart(entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildPriceDetails(BuildContext context, CartProvider cart) {
    double total = cart.totalPrice;
    // Calculate total discount from individual items
    double discount = cart.items.entries.fold(0.0, (sum, entry) {
      if (entry.key.discountPercentage <= 0) return sum;
      double originalPrice =
          entry.key.price / (1 - entry.key.discountPercentage / 100);
      return sum + (originalPrice - entry.key.price) * entry.value;
    });
    double deliveryCharges = total >= 700 ? 0 : 50;
    double finalAmount =
        total +
        deliveryCharges; // total is already the sum of discounted prices

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PRICE DETAILS",
            style: AppTextStyles.h3.copyWith(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const Divider(height: 24),
          _priceRow(
            context,
            "Price (${cart.itemCount} items)",
            "₹${total.toStringAsFixed(2)}",
          ),
          _priceRow(
            context,
            "Discount",
            "-₹${discount.toStringAsFixed(2)}",
            color: AppColors.success,
          ),
          _priceRow(
            context,
            "Delivery Charges",
            deliveryCharges == 0
                ? "FREE"
                : "₹${deliveryCharges.toStringAsFixed(2)}",
            color: AppColors.success,
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: AppTextStyles.h2.copyWith(fontSize: 18),
              ),
              Text(
                "₹${finalAmount.toStringAsFixed(2)}",
                style: AppTextStyles.h2.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "You will save ₹${discount.toStringAsFixed(2)} on this order",
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (MediaQuery.of(context).size.width > 800) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/checkout', extra: cart.items);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB641B), // Flipkart Orange
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "PLACE ORDER",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartProvider cart) {
    double total = cart.totalPrice;
    double discount = cart.items.entries.fold(0.0, (sum, entry) {
      if (entry.key.discountPercentage <= 0) return sum;
      double originalPrice =
          entry.key.price / (1 - entry.key.discountPercentage / 100);
      return sum + (originalPrice - entry.key.price) * entry.value;
    });
    double deliveryCharges = total >= 700 ? 0 : 50;
    double finalAmount = total + deliveryCharges;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "₹${finalAmount.toStringAsFixed(2)}",
                  style: AppTextStyles.h2.copyWith(fontSize: 18),
                ),
                const Text(
                  "View Price Details",
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                context.push('/checkout', extra: cart.items);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFB641B),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "PLACE ORDER",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final Book book;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.book,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  book.imageUrl,
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(book.author, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "₹${book.price}",
                          style: AppTextStyles.h3.copyWith(fontSize: 18),
                        ),
                        if (book.discountPercentage > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            "₹${(book.price / (1 - book.discountPercentage / 100)).toStringAsFixed(2)}",
                            style: AppTextStyles.bodySmall.copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${book.discountPercentage.toInt()}% Off",
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onPressed: quantity <= 1 ? onRemove : onDecrement,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "$quantity",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _QuantityButton(icon: Icons.add, onPressed: onIncrement),
              const Spacer(),
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text("Remove"),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: Theme.of(context).cardColor,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16, color: Theme.of(context).iconTheme.color),
        onPressed: onPressed,
      ),
    );
  }
}
