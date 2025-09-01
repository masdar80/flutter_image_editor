import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'image_editor_dialog.dart';

class ImageEditor {
  // Default aspect ratio for offer images: height 112, width 235
  static const double defaultAspectRatio = 112 / 235; // height/width
  static const int defaultMaxSizeBytes = 524288; // 0.5MB

  /// Edit an image to meet size and aspect ratio requirements
  /// Returns the edited image file or null if cancelled
  static Future<File?> editImage({
    required File imageFile,
    double targetRatio = defaultAspectRatio,
    int maxSizeBytes = defaultMaxSizeBytes,
    String? title,
    Color primaryColor = const Color(0xFF1976D2),
    Map<String, String>? translations,
  }) async {
    final result = await showDialog<File>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => ImageEditorDialog(
        imageFile: imageFile,
        targetRatio: targetRatio,
        maxSizeBytes: maxSizeBytes,
        title: title ?? 'Edit Image',
        primaryColor: primaryColor,
        translations: translations,
      ),
    );
    
    return result;
  }
}
