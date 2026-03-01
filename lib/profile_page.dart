import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'core/colors.dart';
import 'core/text_styles.dart';
import 'providers/user_provider.dart';
import 'providers/sell_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/custom_app_bar.dart';
import 'core/image_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Uploading image...')));

      final ImageService imageService = ImageService();
      final String? imageUrl = await imageService.uploadImage(
        image,
        'profile_images',
      );

      if (imageUrl != null && mounted) {
        await Provider.of<UserProvider>(
          context,
          listen: false,
        ).updateUser(profileImage: imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image. Check console.'),
          ),
        );
      }
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      Provider.of<UserProvider>(context, listen: false).updateUser(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
      );
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    // Sync controllers if not editing
    if (!_isEditing) {
      if (_nameController.text != user.name) _nameController.text = user.name;
      if (_emailController.text != user.email)
        _emailController.text = user.email;
      if (_phoneController.text != user.phone)
        _phoneController.text = user.phone;
      if (_addressController.text != user.address)
        _addressController.text = user.address;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: user.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              backgroundImage: user.profileImage.isNotEmpty
                                  ? (user.profileImage.startsWith('http')
                                        ? NetworkImage(user.profileImage)
                                        : (kIsWeb
                                              ? null
                                              : FileImage(
                                                      File(user.profileImage),
                                                    )
                                                    as ImageProvider))
                                  : null,
                              child:
                                  user.profileImage.isEmpty ||
                                      (kIsWeb &&
                                          !user.profileImage.startsWith('http'))
                                  ? Text(
                                      user.name.isNotEmpty
                                          ? user.name[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    onPressed: _pickImage,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('My Profile', style: AppTextStyles.h2),
                            IconButton(
                              icon: Icon(_isEditing ? Icons.close : Icons.edit),
                              onPressed: () {
                                if (_isEditing) {
                                  // Cancel editing, reset fields
                                  _nameController.text = user.name;
                                  _emailController.text = user.email;
                                  _phoneController.text = user.phone;
                                  _addressController.text = user.address;
                                }
                                setState(() => _isEditing = !_isEditing);
                              },
                              tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Fields
                        _buildTextField(
                          'Full Name',
                          _nameController,
                          Icons.person,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Email',
                          _emailController,
                          Icons.email,
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Phone Number',
                          _phoneController,
                          Icons.phone,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Address',
                          _addressController,
                          Icons.location_on,
                          maxLines: 3,
                          enabled: _isEditing,
                        ),

                        const SizedBox(height: 32),

                        if (_isEditing)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'SAVE CHANGES',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                        if (!_isEditing && user.isAdmin) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () => context.go('/admin'),
                              icon: const Icon(Icons.admin_panel_settings),
                              label: const Text(
                                'ADMIN PORTAL',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],

                        if (!_isEditing)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () async {
                                // Clear session data
                                Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                ).clearData();
                                Provider.of<SellProvider>(
                                  context,
                                  listen: false,
                                ).clearListings();

                                // Sign out from Firebase
                                // Sign out from Firebase
                                await FirebaseAuth.instance.signOut();
                                // Better to add `FirebaseAuth.instance.signOut()` here for safety.

                                // Navigate to Login
                                context.go('/login');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text('LOGOUT'),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }
}
