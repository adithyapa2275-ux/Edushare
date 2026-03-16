import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/order_provider.dart';
import 'core/colors.dart';
import 'core/text_styles.dart';
import 'widgets/book_image.dart';
import 'package:go_router/go_router.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}
class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.iconTheme?.color,
        elevation: 1,
        shadowColor: Colors.black12,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text("No orders yet", style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  Text(
                    "Your purchased books will appear here.",
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    child: const Text('Start Shopping'),
                  )
                ],
              ),
            );
          }

          // Flatten orders into individual items
          List<Map<String, dynamic>> flatItems = [];
          for (var order in orderProvider.orders) {
            for (var entry in order.items.entries) {
              flatItems.add({
                'order': order,
                'book': entry.key,
                'quantity': entry.value,
              });
            }
          }

          return Column(
            children: [
              // Orders List
              Expanded(
                child: ListView.separated(
                  itemCount: flatItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
                  itemBuilder: (context, index) {
                    final item = flatItems[index];
                    final order = item['order'];
                    final book = item['book'];
                    
                    // Simple logic to interpret status display
                    String displayStatusText;
                    if (order.status.toLowerCase() == 'placed' || order.status.toLowerCase() == 'processing') {
                      displayStatusText = 'Placed on ${_formatDate(order.date)}';
                    } else if (order.status.toLowerCase() == 'delivered') {
                      displayStatusText = 'Delivered on ${_formatDate(order.date.add(const Duration(days: 4)))}';
                    } else if (order.status.toLowerCase().contains('replacement')) {
                       displayStatusText = 'Replacement completed';
                    } else {
                      displayStatusText = '${order.status} on ${_formatDate(order.date)}';
                    }

                    return InkWell(
                      onTap: () {
                        // Navigate to specific Book Details
                        context.push('/book', extra: book);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        color: Theme.of(context).cardColor,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Book Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: BookImage(
                                imageUrl: book.imageUrl,
                                title: book.title,
                                width: 60,
                                height: 85,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          displayStatusText,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    book.title,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Rating Stars Placeholder
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        Icons.star_border,
                                        size: 20,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rate this product now",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Chevron
                            const Padding(
                              padding: EdgeInsets.only(top: 24.0),
                              child: Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

