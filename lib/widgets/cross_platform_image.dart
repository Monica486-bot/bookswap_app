import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';


class CrossPlatformImage extends StatelessWidget {
  final dynamic imageSource; // Can be File, Uint8List, or String (URL)
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const CrossPlatformImage({
    super.key,
    required this.imageSource,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageSource == null) {
      return placeholder ?? const SizedBox.shrink();
    }

    // For web platform
    if (kIsWeb) {
      if (imageSource is Uint8List) {
        return Image.memory(
          imageSource,
          width: width,
          height: height,
          fit: fit,
        );
      } else if (imageSource is String) {
        return Image.network(
          imageSource,
          width: width,
          height: height,
          fit: fit,
        );
      }
    }
    
    // For mobile platforms
    if (imageSource is File) {
      return Image.file(
        imageSource,
        width: width,
        height: height,
        fit: fit,
      );
    } else if (imageSource is String) {
      return Image.network(
        imageSource,
        width: width,
        height: height,
        fit: fit,
      );
    } else if (imageSource is Uint8List) {
      return Image.memory(
        imageSource,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return placeholder ?? const SizedBox.shrink();
  }
}