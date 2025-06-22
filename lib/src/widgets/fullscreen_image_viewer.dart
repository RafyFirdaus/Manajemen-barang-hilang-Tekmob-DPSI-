import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class FullscreenImageViewer extends StatelessWidget {
  final String imagePath;
  final int currentIndex;
  final List<String> allImages;

  const FullscreenImageViewer({
    Key? key,
    required this.imagePath,
    this.currentIndex = 0,
    this.allImages = const [],
  }) : super(key: key);

  static void show({
    required BuildContext context,
    required String imagePath,
    int currentIndex = 0,
    List<String> allImages = const [],
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenImageViewer(
          imagePath: imagePath,
          currentIndex: currentIndex,
          allImages: allImages,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image viewer
          Center(
            child: allImages.isNotEmpty
                ? PageView.builder(
                    itemCount: allImages.length,
                    controller: PageController(initialPage: currentIndex),
                    itemBuilder: (context, index) {
                      return InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Center(
                          child: _buildImageWidget(allImages[index]),
                        ),
                      );
                    },
                  )
                : InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                      child: _buildImageWidget(imagePath),
                    ),
                  ),
          ),
          
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // Image counter (if multiple images)
          if (allImages.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${currentIndex + 1} / ${allImages.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    try {
      // Check if it's a base64 encoded image
      if (imagePath.startsWith('data:image')) {
        // Extract base64 data from data URL
        final base64Data = imagePath.split(',')[1];
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade800,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 80,
                color: Colors.white,
              ),
            );
          },
        );
      } else {
        // Fallback for network images or other formats
        return Image.network(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade800,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 80,
                color: Colors.white,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade800,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      // Error handling
      return Container(
        color: Colors.grey.shade800,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 80,
          color: Colors.white,
        ),
      );
    }
  }
}