import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../providers/user_auth_provider.dart';
import '../providers/book_provider.dart';
import '../models/book_model.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/cross_platform_image.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();

  String _selectedCondition = AppConstants.bookConditions[0];
  XFile? _selectedImage;
  Uint8List? _webImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
        
        // For web, also load bytes for preview
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add books')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final book = BookModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        condition: _selectedCondition,
        imageUrl: '',
        ownerId: authProvider.currentUser!.uid,
        ownerName: authProvider.currentUser!.displayName ?? 'Unknown User',
        status: AppConstants.bookAvailable,
        createdAt: DateTime.now(),
      );

      final success = await bookProvider.addBook(book, _selectedImage);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book added successfully!')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add book: ${bookProvider.error}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textLight),
                    borderRadius: BorderRadius.circular(12.0),
                    color: AppColors.surface,
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: CrossPlatformImage(
                            imageSource: kIsWeb ? _webImage : File(_selectedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 40.0,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Add Cover',
                              style: TextStyle(color: AppColors.textLight),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Book Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: Validators.validateBookTitle,
              ),
              const SizedBox(height: 16.0),

              // Author Field
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: Validators.validateAuthor,
              ),
              const SizedBox(height: 16.0),

              // Condition Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCondition,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: AppConstants.bookConditions.map((String condition) {
                  return DropdownMenuItem<String>(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCondition = newValue!;
                  });
                },
              ),
              const SizedBox(height: 32.0),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56.0,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Add Book',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}
