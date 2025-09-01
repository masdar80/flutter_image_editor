import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_image_editor/flutter_image_editor.dart';
import 'package:image/image.dart' as img;

void main() {
  group('ImageEditor', () {
    testWidgets('should have correct default values', (WidgetTester tester) async {
      expect(ImageEditor.defaultAspectRatio, equals(112 / 235));
      expect(ImageEditor.defaultMaxSizeBytes, equals(524288));
    });

    testWidgets('should create ImageEditorDialog with correct parameters',
        (WidgetTester tester) async {
      // Create a temporary test image
      final testImage = _createTestImage();
      final tempFile = await _saveTestImage(testImage);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
                             onPressed: () async {
                 await ImageEditor.editImage(
                   imageFile: tempFile,
                   targetRatio: 1.0,
                   maxSizeBytes: 1024000,
                   title: 'Test Title',
                   primaryColor: Colors.red,
                 );
                 return;
               },
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Find and tap the button
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets);

      // Clean up
      await tempFile.delete();
    });

    testWidgets('should handle image loading errors gracefully',
        (WidgetTester tester) async {
      // Create a non-existent file
      final nonExistentFile = File('/non/existent/path/image.jpg');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
                             onPressed: () async {
                 await ImageEditor.editImage(
                   imageFile: nonExistentFile,
                 );
                 return;
               },
              child: const Text('Test Error'),
            ),
          ),
        ),
      );

      // Find and tap the button
      await tester.tap(find.text('Test Error'));
      await tester.pumpAndSettle();

      // Verify error state is shown
      expect(find.text('Failed to load image:'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should show correct UI elements', (WidgetTester tester) async {
      final testImage = _createTestImage();
      final tempFile = await _saveTestImage(testImage);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await ImageEditor.editImage(
                  imageFile: tempFile,
                  targetRatio: 1.0,
                );
                return;
              },
              child: const Text('Test UI'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test UI'));
      await tester.pumpAndSettle();

      // Verify all UI elements are present
      expect(find.text('Edit Image'), findsOneWidget); // Default title
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget); // Zoom in
      expect(find.byIcon(Icons.remove), findsOneWidget); // Zoom out
      expect(find.byIcon(Icons.refresh), findsOneWidget); // Reset zoom

      // Clean up
      await tempFile.delete();
    });

    testWidgets('should handle zoom controls correctly',
        (WidgetTester tester) async {
      final testImage = _createTestImage();
      final tempFile = await _saveTestImage(testImage);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await ImageEditor.editImage(
                  imageFile: tempFile,
                  targetRatio: 1.0,
                );
                return;
              },
              child: const Text('Test Zoom'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Zoom'));
      await tester.pumpAndSettle();

      // Test zoom in
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Test zoom out
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      // Test reset zoom
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Clean up
      await tempFile.delete();
    });

    testWidgets('should handle custom colors and translations',
        (WidgetTester tester) async {
      final testImage = _createTestImage();
      final tempFile = await _saveTestImage(testImage);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await ImageEditor.editImage(
                  imageFile: tempFile,
                  targetRatio: 1.0,
                  title: 'Custom Title',
                  primaryColor: Colors.purple,
                  translations: {
                    'save': 'Guardar',
                    'cancel': 'Cancelar',
                  },
                );
                return;
              },
              child: const Text('Test Custom'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Custom'));
      await tester.pumpAndSettle();

      // Verify custom title
      expect(find.text('Custom Title'), findsOneWidget);

      // Clean up
      await tempFile.delete();
    });

    testWidgets('should process image successfully', (WidgetTester tester) async {
      final testImage = _createTestImage();
      final tempFile = await _saveTestImage(testImage);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await ImageEditor.editImage(
                  imageFile: tempFile,
                  targetRatio: 1.0,
                  maxSizeBytes: 1024000,
                );
                if (result != null) {
                  // Verify the result file exists and is smaller
                  expect(result.existsSync(), isTrue);
                  expect(result.lengthSync(), lessThanOrEqualTo(1024000));
                }
              },
              child: const Text('Test Processing'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Processing'));
      await tester.pumpAndSettle();

      // Clean up
      await tempFile.delete();
    });
  });

  group('ImageEditorDialog', () {
    testWidgets('should build without errors', (WidgetTester tester) async {
      final testImage = _createTestImage();
      final tempFile = await _saveTestImage(testImage);

      await tester.pumpWidget(
        MaterialApp(
          home: ImageEditorDialog(
            imageFile: tempFile,
            targetRatio: 1.0,
            maxSizeBytes: 1024000,
            title: 'Test Dialog',
            primaryColor: Colors.blue,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dialog elements
      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.byType(ImageEditorDialog), findsOneWidget);

      // Clean up
      await tempFile.delete();
    });

    testWidgets('should handle different aspect ratios', (WidgetTester tester) async {
      final testImage = _createTestImage();
      final tempFile = await _saveTestImage(testImage);

      // Test square ratio
      await tester.pumpWidget(
        MaterialApp(
          home: ImageEditorDialog(
            imageFile: tempFile,
            targetRatio: 1.0,
            maxSizeBytes: 1024000,
            title: 'Square',
            primaryColor: Colors.blue,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Square'), findsOneWidget);

      // Test landscape ratio
      await tester.pumpWidget(
        MaterialApp(
          home: ImageEditorDialog(
            imageFile: tempFile,
            targetRatio: 16/9,
            maxSizeBytes: 1024000,
            title: 'Landscape',
            primaryColor: Colors.blue,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Landscape'), findsOneWidget);

      // Clean up
      await tempFile.delete();
    });
  });
}

// Helper functions for testing

img.Image _createTestImage() {
  // Create a simple test image (100x100 pixels)
  final image = img.Image(width: 100, height: 100);
  
  // Fill with a gradient pattern for testing
  for (int y = 0; y < 100; y++) {
    for (int x = 0; x < 100; x++) {
      final r = (x * 255 / 100).round();
      final g = (y * 255 / 100).round();
      final b = 128;
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }
  
  return image;
}

Future<File> _saveTestImage(img.Image image) async {
  final bytes = Uint8List.fromList(img.encodeJpg(image, quality: 90));
  final tempDir = Directory.systemTemp;
  final tempFile = File('${tempDir.path}/test_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
  await tempFile.writeAsBytes(bytes);
  return tempFile;
}
