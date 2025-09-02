import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageEditorDialog extends StatefulWidget {
  final File imageFile;
  final double targetRatio;
  final int maxSizeBytes;
  final String title;
  final Color primaryColor;
  final Map<String, String>? translations;

  const ImageEditorDialog({
    Key? key,
    required this.imageFile,
    required this.targetRatio,
    required this.maxSizeBytes,
    required this.title,
    required this.primaryColor,
    this.translations,
  }) : super(key: key);

  @override
  State<ImageEditorDialog> createState() => _ImageEditorDialogState();
}

class _ImageEditorDialogState extends State<ImageEditorDialog> {
  late img.Image _originalImage;
  late Offset _offset;
  late Size _imageSize;
  late Size _editorSize;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;

  // UI state
  double _zoomLevel = 1.0;
  static const double _minZoom = 0.1;
  static const double _maxZoom = 5.0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      _originalImage = img.decodeImage(bytes)!;
      
      setState(() {
        _offset = Offset.zero;
        _imageSize = Size(_originalImage.width.toDouble(), _originalImage.height.toDouble());
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load image: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _buildImageEditor(),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading image...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'Unknown error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadImage,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageEditor() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _editorSize = Size(constraints.maxWidth, constraints.maxHeight);
        return Container(
          color: Colors.grey[100],
          child: GestureDetector(
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onPanUpdate: _onPanUpdate,
            child: Stack(
              children: [
                // Image display area
                Center(
                  child: Transform.scale(
                    scale: _zoomLevel,
                    child: Transform.translate(
                      offset: _offset,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: _editorSize.width * 0.8,
                          maxHeight: _editorSize.height * 0.8,
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Crop frame overlay
                _buildCropFrame(),
                // Zoom controls
                _buildZoomControls(),
                // Instructions
                _buildInstructions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCropFrame() {
    final frameWidth = _editorSize.width * 0.6;
    final frameHeight = frameWidth * widget.targetRatio;
    final frameLeft = (_editorSize.width - frameWidth) / 2;
    final frameTop = (_editorSize.height - frameHeight) / 2;

    return Positioned(
      left: frameLeft,
      top: frameTop,
      child: Container(
        width: frameWidth,
        height: frameHeight,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue.withOpacity(0.8),
            width: 2,
          ),
          color: Colors.blue.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      right: 16,
      top: 16,
      child: Column(
        children: [
          FloatingActionButton.small(
            onPressed: _zoomIn,
            backgroundColor: Colors.white,
            child: const Icon(Icons.add, color: Colors.black),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            onPressed: _zoomOut,
            backgroundColor: Colors.white,
            child: const Icon(Icons.remove, color: Colors.black),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            onPressed: _resetZoom,
            backgroundColor: Colors.white,
            child: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      left: 16,
      bottom: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Use pinch to zoom and drag to move the image. Ensure the blue frame is completely filled.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showInstructionsDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 12, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      widget.translations?['show_more'] ?? 'Show more',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(widget.translations?['cancel'] ?? 'Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(widget.translations?['save'] ?? 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    // Handle scale start if needed
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      setState(() {
        _zoomLevel = (_zoomLevel * details.scale).clamp(_minZoom, _maxZoom);
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
    });
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel * 1.05).clamp(_minZoom, _maxZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel / 1.05).clamp(_minZoom, _maxZoom);
    });
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
      _offset = Offset.zero;
    });
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[600], size: 24),
            const SizedBox(width: 8),
            Text(widget.translations?['instructions'] ?? 'Instructions'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            '1. Use pinch gestures to zoom in and out of the image\n'
            '2. Drag the image to move it around the editor\n'
            '3. Use the zoom buttons (+/-) for precise control\n'
            '4. The blue frame shows the crop area\n'
            '5. Ensure the image completely fills the blue frame\n'
            '6. Use the reset button to return to the original view\n'
            '7. Click Save when you\'re satisfied with the crop',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.translations?['ok'] ?? 'OK'),
          ),
        ],
      ),
    );
  }

  bool _validateCropFrame() {
    // Calculate frame dimensions
    final frameWidth = _editorSize.width * 0.6;
    final frameHeight = frameWidth * widget.targetRatio;
    final frameLeft = (_editorSize.width - frameWidth) / 2;
    final frameTop = (_editorSize.height - frameHeight) / 2;

    // Calculate image bounds after zoom and offset
    final imageWidth = _imageSize.width * _zoomLevel;
    final imageHeight = _imageSize.height * _zoomLevel;
    final imageLeft = (_editorSize.width - imageWidth) / 2 + _offset.dx;
    final imageTop = (_editorSize.height - imageHeight) / 2 + _offset.dy;

    // Check if image completely covers the frame
    final imageRight = imageLeft + imageWidth;
    final imageBottom = imageTop + imageHeight;
    final frameRight = frameLeft + frameWidth;
    final frameBottom = frameTop + frameHeight;

    return imageLeft <= frameLeft &&
           imageTop <= frameTop &&
           imageRight >= frameRight &&
           imageBottom >= frameBottom;
  }

  Future<void> _processImage() async {
    // Validate crop frame before processing
    if (!_validateCropFrame()) {
      _showValidationWarning();
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final processedImage = await _cropAndResizeImage();
      final compressedImage = await _compressImage(processedImage);
      
      // Save to temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/edited_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedImage);
      
      Navigator.of(context).pop(tempFile);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to process image: $e';
        _isProcessing = false;
      });
    }
  }

  void _showValidationWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[600], size: 24),
            const SizedBox(width: 8),
            Text(widget.translations?['warning'] ?? 'Warning'),
          ],
        ),
        content: Text(
          widget.translations?['image_not_filling_frame'] ?? 
          'The image does not completely fill the crop frame. Please move or zoom the image to ensure it covers the entire blue frame area.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.translations?['ok'] ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<img.Image> _cropAndResizeImage() async {
    // Calculate crop area based on current zoom and offset
    final frameWidth = _editorSize.width * 0.6;
    final frameHeight = frameWidth * widget.targetRatio;
    final frameLeft = (_editorSize.width - frameWidth) / 2;
    final frameTop = (_editorSize.height - frameHeight) / 2;

    // Convert UI coordinates to image coordinates
    final imageLeft = ((frameLeft - _offset.dx) / _zoomLevel).round();
    final imageTop = ((frameTop - _offset.dy) / _zoomLevel).round();
    final imageWidth = (frameWidth / _zoomLevel).round();
    final imageHeight = (frameHeight / _zoomLevel).round();

    // Ensure coordinates are within bounds
    final cropX = imageLeft.clamp(0, _originalImage.width - 1);
    final cropY = imageTop.clamp(0, _originalImage.height - 1);
    final cropWidth = imageWidth.clamp(1, _originalImage.width - cropX);
    final cropHeight = imageHeight.clamp(1, _originalImage.height - cropY);

    // Crop the image
    final croppedImage = img.copyCrop(
      _originalImage,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    // Resize to target aspect ratio if needed
    final targetWidth = croppedImage.width;
    final targetHeight = (targetWidth * widget.targetRatio).round();
    
    return img.copyResize(
      croppedImage,
      width: targetWidth,
      height: targetHeight,
    );
  }

  Future<Uint8List> _compressImage(img.Image image) async {
    // Start with high quality and reduce until size is acceptable
    int quality = 95;
    Uint8List bytes;
    
    do {
      bytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      quality -= 5;
    } while (bytes.length > widget.maxSizeBytes && quality > 10);
    
    return bytes;
  }
}
