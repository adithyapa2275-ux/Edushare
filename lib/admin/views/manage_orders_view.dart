import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../providers/admin_provider.dart';

class ManageOrdersView extends StatelessWidget {
  const ManageOrdersView({super.key});

  Future<void> _updateOrderStatus(BuildContext context, String orderId, String currentStatus) async {
    String newStatus = currentStatus == 'placed' ? 'shipped' : (currentStatus == 'shipped' ? 'delivered' : 'placed');
    
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoadingOrders) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = adminProvider.allOrders;

        if (orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(32),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderData = orders[index];
            final orderId = orderData['orderId'] ?? '';
            final customerName = orderData['customerName'] ?? 'Unknown';
            final totalAmount = orderData['totalAmount'] ?? 0.0;
            final status = orderData['status'] ?? 'placed';
            final address = orderData['deliveryAddress'] ?? '';

            Color statusColor = AppColors.primary;
            if (status == 'shipped') statusColor = Colors.orange;
            if (status == 'delivered') statusColor = AppColors.success;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text('Order #${orderId.toString().length > 6 ? orderId.toString().substring(orderId.toString().length - 6) : orderId}', style: AppTextStyles.h3),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Customer: $customerName'),
                    Text('Address: $address'),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ₹${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _updateOrderStatus(context, orderId, status),
                      child: const Text(
                        'Update Status',
                        style: TextStyle(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
