import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinsage/screens/camera_view.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({
    super.key,
    required this.title,
    this.text,
    required this.onImage,
    required this.onDetectorViewModeChanged
  });

  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> with SingleTickerProviderStateMixin {
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _slideAnimation;
  bool _isNavigating = false; // Add this near _isLoading


  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    
    // Animation setup for loading/transitions
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (_image != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                setState(() {
                  _image = null;
                  _path = null;
                });
                _controller.reset();
                _controller.forward();
              },
            ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceVariant.withOpacity(0.5),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildImageSection(theme),
              const SizedBox(height: 20),
              if (_image != null) _buildImageInfo(theme),
              const Spacer(),
              _buildActionButtons(theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Expanded(
      flex: 4,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: FadeTransition(
              opacity: _animation,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _buildImageContent(theme),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageContent(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    } else if (_image != null) {
  return GestureDetector(
    onTap: () {
      if (!_isNavigating) {
        Get.to(() => FullScreenImage(image: _image!));
      }
    },
    child: Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'imagePreview',
          child: Image.file(
            _image!,
            fit: BoxFit.cover,
          ),
        ),
        if (_isLoading || _isNavigating)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.purple,
                strokeWidth: 4,
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.zoom_in_rounded, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Tap to view',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
    else {
      return _buildEmptyState(theme);
    }
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Processing image...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_photo_alternate_rounded,
              size: 50,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Add an image to analyze',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Take a photo or select from gallery',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageInfo(ThemeData theme) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Image Selected',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (widget.text != null && widget.text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 28),
                child: Text(
                  widget.text!,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_slideAnimation.value),
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () async {
                    final result = await Get.to(() => CameraView());
                    if (result != null && result is String) {
                      await _processFile(result);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.camera_alt_rounded, size: 24),
                  label: const Text(
                    'Take a Photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => _getImage(ImageSource.gallery),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.photo_library_rounded, size: 24),
                  label: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final pickedFile = await _imagePicker?.pickImage(source: source);
      if (pickedFile != null) {
        await _processFile(pickedFile.path);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

 Future<void> _processFile(String path) async {
  setState(() {
    _isLoading = true;
    _isNavigating = false;
  });

  final inputImage = InputImage.fromFilePath(path);

  try {
    await widget.onImage(inputImage); // e.g. processing image
    setState(() {
      _image = File(path);
      _path = path;
      _isLoading = false;
      _isNavigating = true;
    });

    // Simulate navigation delay
    await Future.delayed(const Duration(seconds: 2)); // simulate delay or real navigation here

    // For example:
    // await Get.to(() => ResultScreen(image: _image));

    setState(() {
      _isNavigating = false;
    });

  } catch (e) {
    setState(() {
      _isLoading = false;
      _isNavigating = false;
    });
    // Handle error appropriately
    Get.snackbar('Error', 'Failed to process image: $e');
  }
}
}

// New class for viewing images in full screen
class FullScreenImage extends StatelessWidget {
  final File image;
  
  const FullScreenImage({super.key, required this.image});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Center(
            child: Hero(
              tag: 'imagePreview',
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}