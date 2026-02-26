import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/colors.dart';
import 'core/text_styles.dart';
import 'providers/sell_provider.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/book_card.dart';

class MyListingsPage extends StatelessWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Listings', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<SellProvider>(
                builder: (context, sellProvider, child) {
                  if (sellProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (sellProvider.userListings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storefront,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          const Text('You haven\'t listed any books yet.'),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio:
                              0.45, // Taller cards to avoid overflow
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: sellProvider.userListings.length,
                    itemBuilder: (context, index) {
                      final book = sellProvider.userListings[index];
                      // We can reuse BookCard but maybe add a "Delete" button instead of "Add to Cart"?
                      // For simplicity, let's wrap BookCard in a Stack to add Delete button.
                      return Stack(
                        children: [
                          BookCard(book: book),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 14,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Remove Listing?'),
                                      content: Text(
                                        'Are you sure you want to remove "${book.title}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            sellProvider.removeBook(book.id);
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Remove',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
