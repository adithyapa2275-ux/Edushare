import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/book.dart';
import 'models/order_model.dart';
import 'core/colors.dart';
import 'core/text_styles.dart';
import 'widgets/book_image.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderModel order;
  final Book book;
  final int quantity;

  const OrderDetailsPage({
    super.key,
    required this.order,
    required this.book,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.iconTheme?.color,
        elevation: 1,
        shadowColor: Colors.black12,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(order.id).snapshots(),
        builder: (context, snapshot) {
          String currentStatus = order.status;
          DateTime currentDate = order.date;

          if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) {
              currentStatus = data['status'] ?? order.status;
              if (data['date'] is Timestamp) {
                currentDate = (data['date'] as Timestamp).toDate();
              } else if (data['date'] is String) {
                currentDate = DateTime.tryParse(data['date']) ?? order.date;
              }
            }
          }

          // Determine status text
          String displayStatusText;
          String statusDescription;
          IconData statusIcon;
          Color statusColor;

          if (currentStatus.toLowerCase() == 'placed' || currentStatus.toLowerCase() == 'processing') {
            displayStatusText = 'Order Placed';
            statusDescription = 'Your order was placed on ${_formatDate(currentDate)}';
            statusIcon = Icons.inventory;
            statusColor = Colors.blue;
          } else if (currentStatus.toLowerCase() == 'delivered') {
            displayStatusText = 'Delivered';
            statusDescription = 'Your order was delivered on ${_formatDate(currentDate.add(const Duration(days: 4)))}';
            statusIcon = Icons.check_circle;
            statusColor = Colors.green;
          } else if (currentStatus.toLowerCase().contains('replacement')) {
            displayStatusText = 'Replacement completed';
            statusDescription = 'Your replacement was completed.';
            statusIcon = Icons.swap_horiz;
            statusColor = Colors.orange;
          } else if (currentStatus.toLowerCase() == 'cancelled') {
            displayStatusText = 'Cancelled';
            statusDescription = 'Your order was cancelled on ${_formatDate(currentDate)}';
            statusIcon = Icons.cancel;
            statusColor = Colors.red;
          } else {
            displayStatusText = currentStatus;
            statusDescription = 'Status: $currentStatus on ${_formatDate(currentDate)}';
            statusIcon = Icons.info;
            statusColor = Colors.grey;
          }

          return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayStatusText,
                          style: AppTextStyles.h3.copyWith(color: statusColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusDescription,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Product Details Card
            Text('Product Information', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BookImage(
                      imageUrl: book.imageUrl,
                      title: book.title,
                      width: 80,
                      height: 120,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quantity: $quantity',
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              '₹${book.price.toStringAsFixed(2)}',
                              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Summary
            Text('Order Information', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow('Order ID', order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()),
                  const Divider(),
                  _buildInfoRow('Order Date', _formatDate(order.date)),
                  const Divider(),
                  _buildInfoRow('Payment Method', _formatPaymentMethod(order.paymentMethod)),
                  const Divider(),
                  _buildInfoRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(2)}', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Delivery Address
            Text('Delivery Address', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                order.deliveryAddress.isEmpty ? 'No address provided' : order.deliveryAddress,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            
            if (currentStatus.toLowerCase() == 'placed' || currentStatus.toLowerCase() == 'processing') ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _cancelOrder(context, order.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      );
    },
   ),
  );
 }

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Try getting the doc natively first (works for new orders securely)
        final collection = FirebaseFirestore.instance.collection('orders');
        final directDoc = await collection.doc(orderId).get();
        if (directDoc.exists) {
           await directDoc.reference.update({'status': 'cancelled'});
        } else {
           // For backwards compatibility with old orders that used epoch string mismatch
           final query = await collection.where('orderId', isEqualTo: orderId).get();
           if (query.docs.isNotEmpty) {
             await query.docs.first.reference.update({'status': 'cancelled'});
           } else {
             throw Exception('Order could not be located in the database.');
           }
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel order: $e')),
          );
        }
      }
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'upi': return 'UPI';
      case 'card': return 'Credit / Debit Card';
      case 'cod': return 'Cash on Delivery';
      default: return method.toUpperCase();
    }
  }
}
