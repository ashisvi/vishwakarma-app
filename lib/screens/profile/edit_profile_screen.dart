import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.initialName = '',
    this.initialFatherName = '',
    this.initialAddress = '',
    this.initialVillage,
    this.initialPhotoFile,
  });

  final String initialName;
  final String initialFatherName;
  final String initialAddress;
  final String? initialVillage;
  final File? initialPhotoFile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _addressController = TextEditingController();

  File? _profileImageFile;
  String? _selectedVillage;

  static const double _inputBorderRadius = 14.0;
  static const double _cardBorderRadius = 20.0;
  static const double _buttonHeight = 56.0;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _fatherNameController.text = widget.initialFatherName;
    _addressController.text = widget.initialAddress;
    _selectedVillage = widget.initialVillage;
    _profileImageFile = widget.initialPhotoFile;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _addressController.dispose();
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
              'Edit Profile',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteCard,
              ),
            ),
            Text(
              'प्रोफ़ाइल संपादित करें',
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
              _buildProfilePhoto(),
              const SizedBox(height: 24),
              _buildFormCard(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteCard,
              border: Border.all(
                color: AppColors.primarySaffron.withValues(alpha: 0.7),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _profileImageFile != null
                  ? Image.file(_profileImageFile!, fit: BoxFit.cover)
                  : Icon(
                      Icons.person,
                      size: 56,
                      color: AppColors.maroon.withValues(alpha: 0.8),
                    ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: _showPhotoOptions,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primarySaffron,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: AppColors.whiteCard,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primarySaffron,
                ),
                title: Text(
                  'Camera / कैमरा',
                  style: GoogleFonts.notoSans(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primarySaffron,
                ),
                title: Text(
                  'Gallery / गैलरी',
                  style: GoogleFonts.notoSans(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImageFile != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.maroon,
                  ),
                  title: Text(
                    'Remove photo / फोटो हटाएँ',
                    style: GoogleFonts.notoSans(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _profileImageFile = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (!mounted) return;
    if (file != null) {
      setState(() => _profileImageFile = File(file.path));
    }
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
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
            _buildLabeledField(
              icon: Icons.person_outline,
              labelEn: 'Name',
              labelHi: 'नाम',
              child: TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration('Enter your name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildLabeledField(
              icon: Icons.family_restroom,
              labelEn: 'Father\'s Name',
              labelHi: 'पिता का नाम',
              child: TextFormField(
                controller: _fatherNameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration('Enter father\'s name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildLabeledField(
              icon: Icons.home_work_outlined,
              labelEn: 'Address',
              labelHi: 'पता',
              child: TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: _inputDecoration('House no., street, landmark'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildLabeledField(
              icon: Icons.home_outlined,
              labelEn: 'State',
              labelHi: 'राज्य',
              child: _buildVillageDropdown(),
            ),
            const SizedBox(height: 20),
            _buildLabeledField(
              icon: Icons.home_outlined,
              labelEn: 'District',
              labelHi: 'जिला',
              child: _buildVillageDropdown(),
            ),
            const SizedBox(height: 20),
            _buildLabeledField(
              icon: Icons.home_outlined,
              labelEn: 'Block',
              labelHi: 'ब्लॉक',
              child: _buildVillageDropdown(),
            ),
            const SizedBox(height: 20),
            _buildLabeledField(
              icon: Icons.home_outlined,
              labelEn: 'Village',
              labelHi: 'गाँव',
              child: _buildVillageDropdown(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required IconData icon,
    required String labelEn,
    required String labelHi,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primarySaffron),
            const SizedBox(width: 8),
            Text(
              labelEn,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.maroon,
              ),
            ),
            Text(
              ' / $labelHi',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 13,
                color: AppColors.maroon.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      filled: true,
      fillColor: AppColors.creamBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputBorderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputBorderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputBorderRadius),
        borderSide: const BorderSide(color: AppColors.primarySaffron, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }

  Widget _buildVillageDropdown() {
    final villages = const [
      'Vishwakarma Nagar',
      'Shivpuri',
      'Shanti Nagar',
      'Ganga Vihar',
      'Ramgarh',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.circular(_inputBorderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVillage,
          isExpanded: true,
          hint: Text(
            'Select village',
            style: GoogleFonts.notoSans(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(12),
          items: villages
              .map(
                (v) => DropdownMenuItem<String>(
                  value: v,
                  child: Text(
                    v,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: AppColors.maroon,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedVillage = value);
          },
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: FilledButton(
        onPressed: _onSave,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primarySaffron,
          foregroundColor: AppColors.whiteCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_inputBorderRadius),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Save Changes'),
            const SizedBox(width: 8),
            Text(
              'परिवर्तन सुरक्षित करें',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVillage == null || _selectedVillage!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'कृपया गाँव चुनें',
            style: GoogleFonts.notoSansDevanagari(fontSize: 14),
          ),
          backgroundColor: AppColors.maroon,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // TODO: Persist changes via API / local storage, then pop with result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'परिवर्तन सुरक्षित कर दिए गए',
          style: GoogleFonts.notoSansDevanagari(fontSize: 14),
        ),
        backgroundColor: AppColors.maroon,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }
}
