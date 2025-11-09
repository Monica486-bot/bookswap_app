import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';


class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery - returns XFile for cross-platform compatibility
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Upload image to Firebase Storage - cross-platform
  Future<String> uploadBookImage(dynamic imageFile, String userId) async {
    try {
      // Create unique filename
      String fileName = 'book_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String path = 'book_images/$userId/$fileName';

      TaskSnapshot snapshot;
      
      if (kIsWeb) {
        // For web: use putData with Uint8List
        if (imageFile is XFile) {
          Uint8List bytes = await imageFile.readAsBytes();
          snapshot = await _storage.ref(path).putData(bytes);
        } else {
          throw Exception('Invalid image file type for web');
        }
      } else {
        // For mobile: use putFile with File
        File file;
        if (imageFile is XFile) {
          file = File(imageFile.path);
        } else if (imageFile is File) {
          file = imageFile;
        } else {
          throw Exception('Invalid image file type for mobile');
        }
        snapshot = await _storage.ref(path).putFile(file);
      }

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
      // Extract storage path from Firebase Storage URL
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Don't throw error for delete failures to avoid breaking flows
      if (e is FirebaseException && e.code == 'object-not-found') {
        // Image already deleted or doesn't exist - that's fine
        return;
      }
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
    }
  }

  // Upload user profile image - cross-platform
  Future<String> uploadProfileImage(dynamic imageFile, String userId) async {
    try {
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String path = 'profile_images/$userId/$fileName';

      TaskSnapshot snapshot;
      
      if (kIsWeb) {
        // For web: use putData with Uint8List
        if (imageFile is XFile) {
          Uint8List bytes = await imageFile.readAsBytes();
          snapshot = await _storage.ref(path).putData(bytes);
        } else {
          throw Exception('Invalid image file type for web');
        }
      } else {
        // For mobile: use putFile with File
        File file;
        if (imageFile is XFile) {
          file = File(imageFile.path);
        } else if (imageFile is File) {
          file = imageFile;
        } else {
          throw Exception('Invalid image file type for mobile');
        }
        snapshot = await _storage.ref(path).putFile(file);
      }

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
