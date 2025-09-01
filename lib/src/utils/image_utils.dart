import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Utility class for image processing operations
class ImageUtils {
  /// Calculate the optimal quality for JPEG compression to meet size requirements
  static int calculateOptimalQuality(img.Image image, int targetSizeBytes) {
    int quality = 95;
    Uint8List bytes;
    
    do {
      bytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      quality -= 5;
    } while (bytes.length > targetSizeBytes && quality > 10);
    
    return quality;
  }

  /// Validate if an image meets size requirements
  static bool meetsSizeRequirement(img.Image image, int maxSizeBytes) {
    final bytes = Uint8List.fromList(img.encodeJpg(image, quality: 90));
    return bytes.length <= maxSizeBytes;
  }

  /// Get image dimensions as a formatted string
  static String getImageDimensions(img.Image image) {
    return '${image.width} × ${image.height}';
  }

  /// Get image file size in human-readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Check if aspect ratio is valid
  static bool isValidAspectRatio(double ratio) {
    return ratio > 0 && ratio.isFinite;
  }

  /// Calculate target dimensions maintaining aspect ratio
  static Map<String, int> calculateTargetDimensions(
    int originalWidth,
    int originalHeight,
    double targetRatio,
  ) {
    if (targetRatio <= 0) {
      return {'width': originalWidth, 'height': originalHeight};
    }

    final currentRatio = originalHeight / originalWidth;
    
    if (currentRatio > targetRatio) {
      // Image is too tall, crop height
      final newHeight = (originalWidth * targetRatio).round();
      return {'width': originalWidth, 'height': newHeight};
    } else {
      // Image is too wide, crop width
      final newWidth = (originalHeight / targetRatio).round();
      return {'width': newWidth, 'height': originalHeight};
    }
  }
}
