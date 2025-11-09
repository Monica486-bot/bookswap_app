import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageUtils {
  /// Get image bytes from XFile for cross-platform compatibility
  static Future<Uint8List?> getImageBytes(XFile? imageFile) async {
    if (imageFile == null) return null;

    try {
      return await imageFile.readAsBytes();
    } catch (e) {
      if (kDebugMode) {
        print('Error reading image bytes: $e');
      }
      return null;
    }
  }

  /// Get File from XFile (mobile only)
  static File? getImageFile(XFile? imageFile) {
    if (imageFile == null || kIsWeb) return null;

    try {
      return File(imageFile.path);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating File from XFile: $e');
      }
      return null;
    }
  }

  /// Check if running on web platform
  static bool get isWeb => kIsWeb;
}
