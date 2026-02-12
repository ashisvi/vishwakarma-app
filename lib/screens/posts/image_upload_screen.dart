import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_theme.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key, this.initialPaths = const []});

  final List<String> initialPaths;

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final List<String> _paths = [];

  @override
  void initState() {
    super.initState();
    _paths.addAll(widget.initialPaths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primarySaffron,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Add Images',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteCard,
              ),
            ),
            Text(
              'चित्र जोड़ें',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                color: AppColors.whiteCard.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_paths),
            child: Text(
              'Done / पूर्ण करें',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteCard,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImageGrid(),
                  const SizedBox(height: 16),
                  _buildAddButtons(),
                ],
              ),
            ),
          ),
          if (_paths.isNotEmpty) _buildPreviewSlider(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    if (_paths.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'कोई छवि चयनित नहीं है\nAdd images to include with your post.',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              color: AppColors.maroon.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _paths.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = _paths.removeAt(oldIndex);
            _paths.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final path = _paths[index];
          return Container(
            key: ValueKey(path),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Image.file(File(path), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Image ${index + 1}',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.maroon,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Drag to reorder / खींचकर क्रम बदलें',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 12,
                          color: AppColors.maroon.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _paths.removeAt(index));
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.maroon,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickFromCamera(),
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(
              'Camera / कैमरा',
              style: GoogleFonts.notoSans(fontSize: 14),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.maroon,
              side: const BorderSide(color: AppColors.primarySaffron),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _pickFromGallery(),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              'Add more / और जोड़ें',
              style: GoogleFonts.notoSans(fontSize: 14),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primarySaffron,
              foregroundColor: AppColors.whiteCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSlider() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Preview / पूर्वावलोकन',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.maroon,
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: _paths.length,
              controller: PageController(viewportFraction: 0.8),
              itemBuilder: (context, index) {
                final path = _paths[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(path), fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (!mounted || file == null) return;
    setState(() => _paths.add(file.path));
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final List<XFile> files = await picker.pickMultiImage(imageQuality: 85);
    if (!mounted || files.isEmpty) return;
    setState(() => _paths.addAll(files.map((f) => f.path)));
  }
}
