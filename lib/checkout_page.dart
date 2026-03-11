import 'package:flutter/material.dart';
import 'models/book.dart';
import 'core/text_styles.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'models/order_model.dart';
import 'package:go_router/go_router.dart';
import 'widgets/book_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutPage extends StatefulWidget {
  final Map<Book, int> items;

  const CheckoutPage({super.key, required this.items});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 0;
  String _paymentMethod = 'upi';

  // Address State
  String _name = "Adithya";
  String _address = "123, Flutter Street, Code City, 560001\nKarnataka, India";
  String _phone = "+91 9876543210";

  double get _totalPrice {
    double total = 0;
    widget.items.forEach((book, quantity) {
      total += book.price * quantity;
    });
    return total;
  }

  void _showEditAddressDialog() {
    final nameController = TextEditingController(text: _name);
    final addressController = TextEditingController(text: _address);
    final phoneController = TextEditingController(text: _phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Address'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 3,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _name = nameController.text;
                _address = addressController.text;
                _phone = phoneController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.iconTheme?.color,
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepTapped: (step) {
          setState(() {
            _currentStep = step;
          });
        },
        onStepContinue: () async {
          if (_currentStep < 2) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            // Create Order
            final order = OrderModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: FirebaseAuth.instance.currentUser?.uid ?? '',
              date: DateTime.now(),
              items: Map.from(widget.items),
              totalAmount: _totalPrice,
              deliveryAddress: "$_name, $_address\n$_phone",
              paymentMethod: _paymentMethod,
            );

            try {
              // 1. Save to Firestore for Admin Dashboard
              var orderData = order.toMap();
              orderData['customerName'] = _name; // For convenience
              orderData['itemCount'] = order.items.length; // For convenience
              
              await FirebaseFirestore.instance.collection('orders').add(orderData);

              if (!mounted) return;

              // 2. Save to local OrderProvider for immediate UI update
              Provider.of<OrderProvider>(
                context,
                listen: false,
              ).addOrder(order);

              // 3. Clear Cart
              final cart = Provider.of<CartProvider>(context, listen: false);
              cart.clearCart();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order Placed Successfully!')),
                );
                context.go('/orders'); // Redirect to Orders page
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to place order: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB641B),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_currentStep == 2 ? 'CONFIRM ORDER' : 'CONTINUE'),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('BACK'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Delivery Address'),
            subtitle: Text('$_name, $_address'),
            content: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      Theme.of(context).dividerTheme.color ??
                      Theme.of(context).dividerColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(_address),
                  const SizedBox(height: 8),
                  Text(
                    _phone,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _showEditAddressDialog,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text("Change"),
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.editing,
          ),
          Step(
            title: const Text('Order Summary'),
            content: Column(
              children: [
                ...widget.items.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        BookImage(
                          imageUrl: entry.key.imageUrl,
                          title: entry.key.title,
                          width: 60,
                          height: 80,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                entry.key.author,
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                "Qty: ${entry.value}",
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${(entry.key.price * entry.value).toStringAsFixed(2)}",
                                style: AppTextStyles.h3.copyWith(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Payable",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₹${_totalPrice.toStringAsFixed(2)}",
                      style: AppTextStyles.h2.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Payment Options'),
            content: Column(
              children: [
                Column(
                  children: [
                    RadioListTile<String>(
                      value: 'upi',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                      title: const Text("UPI"),
                      subtitle: const Text("Google Pay, PhonePe, Paytm"),
                    ),
                    if (_paymentMethod == 'upi')
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 8,
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Enter UPI ID',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    RadioListTile<String>(
                      value: 'card',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                      title: const Text("Credit / Debit / ATM Card"),
                    ),
                    if (_paymentMethod == 'card')
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 8,
                        ),
                        child: Column(
                          children: [
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Card Number',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Expiry Date (MM/YY)',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'CVV',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    obscureText: true,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    RadioListTile<String>(
                      value: 'cod',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                      title: const Text("Cash on Delivery"),
                    ),
                  ],
                ),
              ],
            ),
            isActive: _currentStep >= 2,
            state: StepState.indexed,
          ),
        ],
      ),
    );
  }
}
