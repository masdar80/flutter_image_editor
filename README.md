# Flutter Image Editor

A powerful Flutter image editor with cropping, resizing, and aspect ratio control. Perfect for apps that need image editing capabilities with custom aspect ratios and size limits.

## ✨ Features

- **Interactive Image Cropping** - Zoom, pan, and crop images with precision
- **Custom Aspect Ratios** - Support for any aspect ratio (1:1, 16:9, 4:3, custom)
- **Size Optimization** - Automatic compression to meet file size requirements
- **Modern UI** - Beautiful, intuitive interface with Material Design
- **Cross-Platform** - Works on iOS, Android, and web
- **Customizable** - Custom colors, titles, and translations
- **Real-time Preview** - See your changes before saving
- **Smart Validation** - Ensures images completely fill the crop frame
- **Enhanced UX** - Smooth zoom controls and intuitive touch interactions
- **Multilingual Support** - Built-in translation system with English and Arabic

## 🚀 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_image_editor_enhanced: ^1.0.2
```

You'll also need to add the following dependencies:

```yaml
dependencies:
  image: ^4.1.7
  get: ^4.6.6
```

## 📱 Usage

### Basic Usage

```dart
import 'package:flutter_image_editor_enhanced/flutter_image_editor_enhanced.dart';

// Edit an image with default settings
final File? editedFile = await ImageEditor.editImage(
  imageFile: yourImageFile,
);

if (editedFile != null) {
  // Image was edited successfully
  print('Edited image saved to: ${editedFile.path}');
}
```

### Advanced Usage

```dart
final File? editedFile = await ImageEditor.editImage(
  imageFile: yourImageFile,
  targetRatio: 16/9, // Landscape format
  maxSizeBytes: 1024000, // 1MB limit
  title: 'Edit My Image',
  primaryColor: Colors.purple,
  translations: {
    'save': 'Save Image',
    'cancel': 'Cancel',
    'warning': 'Warning',
    'ok': 'OK',
    'image_not_filling_frame': 'The image does not completely fill the crop frame...',
    'show_more': 'Show more',
    'instructions': 'Instructions',
  },
);
```

### Common Aspect Ratios

```dart
// Square (1:1) - Perfect for profile pictures
targetRatio: 1.0

// Landscape (16:9) - Great for wide images
targetRatio: 9/16

// Portrait (4:3) - Ideal for mobile screens
targetRatio: 3/4

// Custom ratio - Special formats
targetRatio: 112/235 // Offer format
```

## 🎯 API Reference

### ImageEditor.editImage()

The main method for editing images.

**Parameters:**
- `imageFile` (required): The image file to edit
- `targetRatio`: Target aspect ratio (default: 112/235)
- `maxSizeBytes`: Maximum file size in bytes (default: 524288 = 0.5MB)
- `title`: Dialog title (default: "Edit Image")
- `primaryColor`: Custom primary color (default: Material Blue)
- `translations`: Custom text translations

**Returns:**
- `Future<File?>`: The edited image file, or null if cancelled

### Default Values

```dart
class ImageEditor {
  static const double defaultAspectRatio = 112 / 235; // height/width
  static const int defaultMaxSizeBytes = 524288; // 0.5MB
}
```

## 🎨 Customization

### Colors

```dart
await ImageEditor.editImage(
  imageFile: imageFile,
  primaryColor: Colors.deepPurple, // Custom primary color
);
```

### Translations

```dart
await ImageEditor.editImage(
  imageFile: imageFile,
  translations: {
    'save': 'Guardar',
    'cancel': 'Cancelar',
    'warning': 'Advertencia',
    'ok': 'OK',
    'image_not_filling_frame': 'La imagen no llena completamente el marco de recorte...',
    'show_more': 'Mostrar más',
    'instructions': 'Instrucciones',
  },
);
```

## 🔧 Technical Features

### Enhanced Zoom Control
- **Smooth Zoom**: 1.05x multiplier for precise control (instead of 1.2x)
- **Range**: 0.1x to 5.0x zoom levels
- **Gesture Support**: Pinch to zoom with natural feel
- **Button Controls**: +, -, and reset buttons for precise adjustments

### Improved Touch Interaction
- **Full Area Panning**: Touch anywhere in the editor to pan the image
- **Frame-Aware**: Works inside and outside the blue crop frame
- **Responsive**: Smooth drag gestures with proper feedback

### Smart Validation
- **Frame Coverage Check**: Ensures image completely fills the crop area
- **Warning Dialog**: Prevents saving improperly cropped images
- **User Guidance**: Clear instructions on how to fix validation issues

### Compact Instructions
- **Space Efficient**: Shows 2 lines of instructions with ellipsis
- **Expandable**: "Show more" button reveals full instructions
- **Dialog View**: Separate dialog for complete instruction text
- **Multilingual**: All instructions support translations

## 📱 Example App

Check out the `example/` folder for a complete demonstration app that shows:

- Image picking from gallery/camera
- Different aspect ratio examples
- Size limit testing
- Custom colors and translations
- **Multilingual support** (English/Arabic)
- **Enhanced UX features**

To run the example:

```bash
cd example
flutter pub get
flutter run
```

## 🔧 Technical Details

### Image Processing

The package uses the `image` package for:
- Image decoding and encoding
- Cropping and resizing
- JPEG compression with quality control

### UI Components

- **Interactive Editor**: Gesture-based zoom and pan
- **Crop Frame**: Blue overlay showing the crop area
- **Zoom Controls**: +, -, and reset buttons
- **Responsive Design**: Adapts to different screen sizes
- **Validation System**: Smart crop area validation
- **Instruction System**: Compact instructions with expandable dialog

### Performance

- Efficient image processing with minimal memory usage
- Progressive compression to meet size requirements
- Optimized UI rendering for smooth interactions
- Smart validation to prevent processing errors

## 🌟 Use Cases

- **Social Media Apps**: Profile pictures, post images
- **E-commerce**: Product image optimization
- **Document Apps**: ID photos, document scans
- **Content Creation**: Blog images, thumbnails
- **Mobile Apps**: User-generated content
- **Multilingual Apps**: Apps requiring multiple language support

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Image Package](https://pub.dev/packages/image) for image processing
- [GetX](https://pub.dev/packages/get) for state management and translations
- Flutter team for the amazing framework

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/masdar80/flutter_image_editor/issues)
- **Discussions**: [GitHub Discussions](https://github.com/masdar80/flutter_image_editor/discussions)
- **Email**: mashhourmd@gmail.com

## 📈 Roadmap

- [ ] Batch image processing
- [ ] Filters and effects
- [ ] Text overlay support
- [ ] Advanced cropping tools
- [ ] Cloud storage integration
- [ ] More language support
- [ ] Custom crop shapes
- [ ] Undo/redo functionality

## 🔄 Recent Updates

### Version 1.0.0
- **Enhanced Zoom Control**: Smoother 1.05x zoom multiplier
- **Improved Touch Interaction**: Full area panning support
- **Smart Validation**: Frame coverage validation with warnings
- **Compact Instructions**: Space-efficient instruction system
- **Multilingual Support**: English and Arabic translations
- **Better UX**: More intuitive and responsive interface

---

**Made with ❤️ for the Flutter community**
