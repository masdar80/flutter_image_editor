import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_editor/flutter_image_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Image Editor Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Image Editor Example'),
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'warning': 'Warning',
          'ok': 'OK',
          'image_not_filling_frame': 'The image does not completely fill the crop frame. Please move or zoom the image to ensure it covers the entire blue frame area.',
          'show_more': 'Show more',
          'show_less': 'Show less',
          'instructions': 'Instructions',
          'select_image': 'Select Image',
          'gallery': 'Gallery',
          'camera': 'Camera',
          'selected_image': 'Selected Image',
          'edit_options': 'Edit Options',
          'edited_image': 'Edited Image',
          'how_to_use': 'How to Use',
          'how_to_use_text': '1. Select an image from your gallery or take a photo\n'
              '2. Choose your desired aspect ratio and size limit\n'
              '3. Use the interactive editor to crop and adjust your image\n'
              '4. Save the edited image with the specified requirements',
          'square_1_1': 'Square (1:1)',
          'square_description': 'Perfect for profile pictures and social media',
          'landscape_16_9': 'Landscape (16:9)',
          'landscape_description': 'Great for wide images and videos',
          'portrait_4_3': 'Portrait (4:3)',
          'portrait_description': 'Ideal for mobile screens and documents',
          'custom_112_235': 'Custom (112:235)',
          'custom_description': 'Special format for offers and promotions',
          'small_size': 'Small Size (0.5MB)',
          'small_size_description': 'Optimized for fast loading and storage',
          'image_edited_successfully': 'Image edited successfully! Size: {size} KB',
        },
        'ar_SA': {
          'warning': 'تحذير',
          'ok': 'موافق',
          'image_not_filling_frame': 'الصورة لا تملأ إطار القص بالكامل. يرجى تحريك أو تكبير الصورة لضمان تغطيتها لمنطقة الإطار الأزرق بالكامل.',
          'show_more': 'عرض المزيد',
          'show_less': 'عرض أقل',
          'instructions': 'التعليمات',
          'select_image': 'اختر الصورة',
          'gallery': 'المعرض',
          'camera': 'الكاميرا',
          'selected_image': 'الصورة المختارة',
          'edit_options': 'خيارات التحرير',
          'edited_image': 'الصورة المحررة',
          'how_to_use': 'كيفية الاستخدام',
          'how_to_use_text': '1. اختر صورة من المعرض أو التقط صورة\n'
              '2. اختر نسبة العرض المطلوبة وحد الحجم\n'
              '3. استخدم المحرر التفاعلي لقص وتعديل الصورة\n'
              '4. احفظ الصورة المحررة بالمتطلبات المحددة',
          'square_1_1': 'مربع (1:1)',
          'square_description': 'مثالي لصور الملف الشخصي ووسائل التواصل الاجتماعي',
          'landscape_16_9': 'أفقي (16:9)',
          'landscape_description': 'ممتاز للصور العريضة والفيديوهات',
          'portrait_4_3': 'عمودي (4:3)',
          'portrait_description': 'مثالي للشاشات المحمولة والمستندات',
          'custom_112_235': 'مخصص (112:235)',
          'custom_description': 'تنسيق خاص للعروض والترويج',
          'small_size': 'حجم صغير (0.5 ميجابايت)',
          'small_size_description': 'محسن للتحميل السريع والتخزين',
          'image_edited_successfully': 'تم تحرير الصورة بنجاح! الحجم: {size} كيلوبايت',
        },
      };
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _selectedImage;
  File? _editedImage;
  final ImagePicker _picker = ImagePicker();
  String _currentLanguage = 'en';

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _editedImage = null;
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _editedImage = null;
      });
    }
  }

  Future<void> _editImage({
    required double aspectRatio,
    required int maxSizeBytes,
    required String title,
    required Color primaryColor,
  }) async {
    if (_selectedImage == null) return;

    final File? result = await ImageEditor.editImage(
      imageFile: _selectedImage!,
      targetRatio: aspectRatio,
      maxSizeBytes: maxSizeBytes,
      title: title,
      primaryColor: primaryColor,
      translations: {
        'warning': 'warning'.tr,
        'ok': 'ok'.tr,
        'image_not_filling_frame': 'image_not_filling_frame'.tr,
        'show_more': 'show_more'.tr,
        'instructions': 'instructions'.tr,
      },
    );

    if (result != null) {
      setState(() {
        _editedImage = result;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('image_edited_successfully'.trParams({
              'size': (result.lengthSync() / 1024).toStringAsFixed(1)
            })),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _toggleLanguage() {
    setState(() {
      _currentLanguage = _currentLanguage == 'en' ? 'ar' : 'en';
      Get.updateLocale(Locale(_currentLanguage, _currentLanguage == 'en' ? 'US' : 'SA'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _toggleLanguage,
            icon: Text(_currentLanguage == 'en' ? 'عربي' : 'EN'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image selection section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'select_image'.tr,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: Text('gallery'.tr),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: Text('camera'.tr),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selected image display
            if (_selectedImage != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'selected_image'.tr,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Size: ${(_selectedImage!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Aspect ratio options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'edit_options'.tr,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Square (1:1)
                      _buildEditOption(
                        'square_1_1'.tr,
                        'square_description'.tr,
                        Icons.crop_square,
                        Colors.blue,
                        1.0,
                        1024000, // 1MB
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Landscape (16:9)
                      _buildEditOption(
                        'landscape_16_9'.tr,
                        'landscape_description'.tr,
                        Icons.crop_landscape,
                        Colors.green,
                        9/16,
                        1024000, // 1MB
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Portrait (4:3)
                      _buildEditOption(
                        'portrait_4_3'.tr,
                        'portrait_description'.tr,
                        Icons.crop_portrait,
                        Colors.orange,
                        3/4,
                        1024000, // 1MB
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Custom (112:235)
                      _buildEditOption(
                        'custom_112_235'.tr,
                        'custom_description'.tr,
                        Icons.crop_free,
                        Colors.purple,
                        112/235,
                        524288, // 0.5MB
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Small size option
                      _buildEditOption(
                        'small_size'.tr,
                        'small_size_description'.tr,
                        Icons.compress,
                        Colors.red,
                        1.0,
                        524288, // 0.5MB
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Edited image display
            if (_editedImage != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'edited_image'.tr,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _editedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Size: ${(_editedImage!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Instructions
            if (_selectedImage == null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'how_to_use'.tr,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'how_to_use_text'.tr,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditOption(
    String title,
    String description,
    IconData icon,
    Color color,
    double aspectRatio,
    int maxSizeBytes,
  ) {
    return InkWell(
      onTap: () => _editImage(
        aspectRatio: aspectRatio,
        maxSizeBytes: maxSizeBytes,
        title: title,
        primaryColor: color,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }
}
