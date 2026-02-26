import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'core/colors.dart';
import 'core/text_styles.dart';
import 'models/book.dart';
import 'providers/sell_provider.dart';
import 'widgets/custom_app_bar.dart';
import 'core/image_service.dart';
import 'dart:io';

class SellBookPage extends StatefulWidget {
  const SellBookPage({super.key});

  @override
  State<SellBookPage> createState() => _SellBookPageState();
}

class _SellBookPageState extends State<SellBookPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
  XFile? _pickedFile;

  bool _isSubmitting = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      String imageUrl = _imageUrlController.text;

      // Upload image if a local one was picked
      if (_pickedFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading cover image...')),
        );

        final ImageService imageService = ImageService();
        final String? uploadedUrl = await imageService.uploadImage(
          _pickedFile!,
          'book_covers',
        );

        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded! Listing book...')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image upload failed. Using placeholder.'),
              ),
            );
          }
        }
      }

      if (imageUrl.isEmpty) {
        imageUrl = 'https://via.placeholder.com/300?text=No+Image';
      }

      final book = Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        author: _authorController.text,
        description: _descController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        rating: 0.0,
        reviewCount: 0,
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      await Provider.of<SellProvider>(context, listen: false).addBook(book);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book Listed Successfully!')),
      );

      context.pushReplacement('/my_listings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sell Your Book',
                    style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  const Text('Enter details to list your book for sale.'),
                  const SizedBox(height: 32),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Book Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter title' : null,
                  ),
                  const SizedBox(height: 16),

                  // Author
                  TextFormField(
                    controller: _authorController,
                    decoration: const InputDecoration(
                      labelText: 'Author Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter author' : null,
                  ),
                  const SizedBox(height: 16),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter price';
                      if (double.tryParse(value) == null)
                        return 'Invalid price';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Image Picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Book Cover Image',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _pickedFile != null
                                ? (kIsWeb
                                      ? Image.network(
                                          _pickedFile!.path,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_pickedFile!.path),
                                          fit: BoxFit.cover,
                                        ))
                                : (_imageUrlController.text.isNotEmpty
                                      ? Image.network(
                                          _imageUrlController.text,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                          ),
                                        )),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                setState(() {
                                  _pickedFile = image;
                                  _imageUrlController
                                      .clear(); // Use local preview
                                });
                              }
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Pick Image'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Or enter URL manually:'),
                    ],
                  ),

                  // Image URL (Mocking upload with URL input)
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL (Optional)',
                      hintText: 'http://example.com/image.jpg',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter description' : null,
                  ),
                  const SizedBox(height: 32),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'LIST BOOK FOR SALE',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
