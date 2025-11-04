import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadBookImage(File imageFile, String userId) async {
    try {
      // Create unique filename
      String fileName = 'book_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String path = 'book_images/$userId/$fileName';

      // Upload to Firebase Storage
      TaskSnapshot snapshot = await _storage.ref(path).putFile(imageFile);

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract path from URL
      Uri uri = Uri.parse(imageUrl);
      String path = uri.path;

      // Remove the leading '/'
      if (path.startsWith('/')) {
        path = path.substring(1);
      }

      // Get reference and delete
      Reference ref = _storage.ref(path);
      await ref.delete();
    } catch (e) {
      // Don't throw error for delete failures to avoid breaking flows
      if (e is FirebaseException && e.code == 'object-not-found') {
        // Image already deleted or doesn't exist - that's fine
        return;
      }
      print('Error deleting image: $e');
    }
  }

  // Upload user profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String path = 'profile_images/$userId/$fileName';

      TaskSnapshot snapshot = await _storage.ref(path).putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
