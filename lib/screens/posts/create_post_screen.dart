import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import 'image_upload_screen.dart';
import '../../services/posts_service.dart';
import '../../services/supabase_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _postController = TextEditingController();

  final List<String> _imagePaths = [];

  static const double _cardRadius = 20.0;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
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
              'Create Post',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteCard,
              ),
            ),
            Text(
              'पोस्ट बनाएँ',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                color: AppColors.whiteCard.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildContentCard(),
              const SizedBox(height: 16),
              _buildImagesCard(),
              const SizedBox(height: 24),
              _buildHelperText(),
              const SizedBox(height: 16),
              _buildPostButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post content / पोस्ट सामग्री',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.maroon,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _postController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText:
                    'Write your announcement here...\nअपनी सूचना यहाँ लिखें...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                filled: true,
                fillColor: AppColors.creamBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: AppColors.primarySaffron,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 15,
                height: 1.5,
                color: AppColors.maroon,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter post content / कृपया पोस्ट लिखें';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Images / छवियाँ',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maroon,
                  ),
                ),
                TextButton.icon(
                  onPressed: _openImageUpload,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(
                    _imagePaths.isEmpty ? 'Add images' : 'Edit images',
                    style: GoogleFonts.notoSans(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_imagePaths.isEmpty)
              Text(
                'आप चाहें तो घोषणा के साथ फोटो भी जोड़ सकते हैं।',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 13,
                  color: AppColors.maroon.withValues(alpha: 0.8),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _imagePaths
                    .map(
                      (p) => ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: Image.file(File(p), fit: BoxFit.cover),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelperText() {
    return Text(
      'पोस्ट सभी सदस्यों को दिखाई जाएगी',
      style: GoogleFonts.notoSansDevanagari(
        fontSize: 14,
        color: AppColors.maroon.withValues(alpha: 0.85),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _onPost,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primarySaffron,
          foregroundColor: AppColors.whiteCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Post'),
            const SizedBox(width: 8),
            Text(
              'प्रकाशित करें',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openImageUpload() async {
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => ImageUploadScreen(initialPaths: _imagePaths),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _imagePaths
          ..clear()
          ..addAll(result);
      });
    }
  }

  void _onPost() {
    if (!_formKey.currentState!.validate()) return;

    // check role
    () async {
      final profile = await fetchUserProfile();
      final role = profile?['role'] as String?;
      if (!(role == 'admin' || role == 'committee')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permission denied: only admins/committee can post',
              style: GoogleFonts.notoSans(),
            ),
          ),
        );
        return;
      }

      // prepare files
      final files = _imagePaths.map((p) => File(p)).toList();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final result = await createPostWithImages(
        content: _postController.text.trim(),
        imageFiles: files,
      );

      debugPrint(
        'Post creation result: '
        'post=${result?.post}, '
        'failedCount=${result?.failedCount}, '
        'errors=${result?.errors}',
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // remove dialog

      if (result != null && result.post != null) {
        // Successful post; handle image upload warnings if any.
        if (result.failedCount > 0 || result.errors.isNotEmpty) {
          final reason = result.errors.join(', ');
          debugPrint(reason);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'पोस्ट प्रकाशित हुई, लेकिन कुछ फोटो अपलोड नहीं हो पाईं (कारण: $reason)',
                style: GoogleFonts.notoSansDevanagari(fontSize: 14),
              ),
              backgroundColor: AppColors.maroon,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'पोस्ट सफलतापूर्वक प्रकाशित हुई',
                style: GoogleFonts.notoSansDevanagari(fontSize: 14),
              ),
              backgroundColor: AppColors.maroon,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create post',
              style: GoogleFonts.notoSans(),
            ),
          ),
        );
      }
    }();
  }
}
