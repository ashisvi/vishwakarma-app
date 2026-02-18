import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_theme.dart';
import '../main_navigation_screen.dart';
import '../../services/supabase_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _pinCodeController = TextEditingController();

  DateTime? _dateOfBirth;
  File? _profileImageFile;
  String? _selectedStateId;
  String? _selectedDistrictId;
  String? _selectedBlockId;
  String? _selectedVillageId;

  // Track location names for display
  String? _selectedStateName;
  String? _selectedDistrictName;
  String? _selectedBlockName;
  String? _selectedVillageName;

  // Lists for dropdowns
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _blocks = [];
  List<Map<String, dynamic>> _villages = [];

  static const double _inputBorderRadius = 14.0;
  static const double _cardBorderRadius = 20.0;
  static const double _sectionSpacing = 28.0;
  static const double _fieldSpacing = 20.0;
  static const double _buttonHeight = 56.0;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    final states = await fetchLocations(type: 'state');
    setState(() => _states = states);
  }

  Future<void> _loadDistricts(String stateId) async {
    final districts = await fetchLocations(type: 'district', parentId: stateId);
    setState(() => _districts = districts);
  }

  Future<void> _loadBlocks(String districtId) async {
    final blocks = await fetchLocations(type: 'block', parentId: districtId);
    setState(() => _blocks = blocks);
  }

  Future<void> _loadVillages(String blockId) async {
    final villages = await fetchLocations(type: 'village', parentId: blockId);
    setState(() => _villages = villages);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _addressLineController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.creamBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          color: AppColors.maroon,
          style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
        title: Text(
          'Profile Setup',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.maroon,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfilePhotoSection(),
              const SizedBox(height: _sectionSpacing),
              _buildPersonalSection(),
              const SizedBox(height: _sectionSpacing),
              _buildAddressSection(),
              const SizedBox(height: _sectionSpacing),
              _buildSaveButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showPhotoOptions,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.whiteCard,
                border: Border.all(
                  color: AppColors.primarySaffron.withValues(alpha: 0.5),
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
              child: _profileImageFile != null
                  ? ClipOval(
                      child: Image.file(
                        _profileImageFile!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: AppColors.primarySaffron.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add Photo',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.maroon.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'प्रोफ़ाइल फोटो',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              color: AppColors.maroon.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primarySaffron,
                ),
                title: Text(
                  'Camera',
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
                  'Gallery',
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
                    'Remove photo',
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
    final XFile? file = source == ImageSource.camera
        ? await picker.pickImage(source: ImageSource.camera, imageQuality: 85)
        : await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (!mounted) return;
    if (file != null) {
      setState(() => _profileImageFile = File(file.path));
    }
  }

  Widget _buildPersonalSection() {
    return _buildSectionCard(
      titleEn: 'Personal Details',
      titleHi: 'व्यक्तिगत विवरण',
      children: [
        _buildLabeledField(
          labelEn: 'Name',
          labelHi: 'नाम',
          icon: Icons.person_outline,
          child: TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(hint: 'Enter your name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ),
        SizedBox(height: _fieldSpacing),
        _buildLabeledField(
          labelEn: "Father's Name",
          labelHi: 'पिता का नाम',
          icon: Icons.family_restroom,
          child: TextFormField(
            controller: _fatherNameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(hint: "Enter father's name"),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ),
        SizedBox(height: _fieldSpacing),
        _buildLabeledField(
          labelEn: 'Date of Birth',
          labelHi: 'जन्म तिथि',
          icon: Icons.calendar_today_outlined,
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dateOfBirth ?? DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primarySaffron,
                        onPrimary: AppColors.whiteCard,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) setState(() => _dateOfBirth = date);
            },
            borderRadius: BorderRadius.circular(_inputBorderRadius),
            child: InputDecorator(
              decoration: _inputDecoration(hint: 'Select date'),
              child: Text(
                _dateOfBirth == null
                    ? ''
                    : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: AppColors.maroon,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return _buildSectionCard(
      titleEn: 'Address',
      titleHi: 'पता',
      children: [
        _buildDropdownField(
          labelEn: 'State',
          labelHi: 'राज्य',
          icon: Icons.map_outlined,
          value: _selectedStateName,
          items: _states.map((s) => s['name'] as String).toList(),
          onChanged: (name) {
            final state = _states.firstWhere((s) => s['name'] == name);
            setState(() {
              _selectedStateId = state['id'];
              _selectedStateName = name;
              _selectedDistrictId = null;
              _selectedDistrictName = null;
              _selectedBlockId = null;
              _selectedBlockName = null;
              _selectedVillageId = null;
              _selectedVillageName = null;
              _districts.clear();
              _blocks.clear();
              _villages.clear();
            });
            _loadDistricts(state['id']);
          },
        ),
        SizedBox(height: _fieldSpacing),
        _buildDropdownField(
          labelEn: 'District',
          labelHi: 'जिला',
          icon: Icons.location_city_outlined,
          value: _selectedDistrictName,
          items: _districts.map((d) => d['name'] as String).toList(),
          onChanged: (name) {
            final district = _districts.firstWhere((d) => d['name'] == name);
            setState(() {
              _selectedDistrictId = district['id'];
              _selectedDistrictName = name;
              _selectedBlockId = null;
              _selectedBlockName = null;
              _selectedVillageId = null;
              _selectedVillageName = null;
              _blocks.clear();
              _villages.clear();
            });
            _loadBlocks(district['id']);
          },
        ),
        SizedBox(height: _fieldSpacing),
        _buildDropdownField(
          labelEn: 'Block',
          labelHi: 'ब्लॉक',
          icon: Icons.grid_view_rounded,
          value: _selectedBlockName,
          items: _blocks.map((b) => b['name'] as String).toList(),
          onChanged: (name) {
            final block = _blocks.firstWhere((b) => b['name'] == name);
            setState(() {
              _selectedBlockId = block['id'];
              _selectedBlockName = name;
              _selectedVillageId = null;
              _selectedVillageName = null;
              _villages.clear();
            });
            _loadVillages(block['id']);
          },
        ),
        SizedBox(height: _fieldSpacing),
        _buildDropdownField(
          labelEn: 'Village',
          labelHi: 'गाँव',
          icon: Icons.home_outlined,
          value: _selectedVillageName,
          items: _villages.map((v) => v['name'] as String).toList(),
          onChanged: (name) {
            final village = _villages.firstWhere((v) => v['name'] == name);
            setState(() {
              _selectedVillageId = village['id'];
              _selectedVillageName = name;
            });
          },
        ),
        SizedBox(height: _fieldSpacing),
        _buildLabeledField(
          labelEn: 'Address line',
          labelHi: 'पता (लाइन)',
          icon: Icons.home_work_outlined,
          child: TextFormField(
            controller: _addressLineController,
            maxLines: 2,
            decoration: _inputDecoration(hint: 'House no., street, landmark'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ),
        SizedBox(height: _fieldSpacing),
        _buildLabeledField(
          labelEn: 'PIN code',
          labelHi: 'पिन कोड',
          icon: Icons.pin_drop_outlined,
          child: TextFormField(
            controller: _pinCodeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: _inputDecoration(hint: '6 digit PIN'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (v.length != 6) return 'Enter 6 digits';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String titleEn,
    required String titleHi,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleEn,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.maroon,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titleHi,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.maroon.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabeledField({
    required String labelEn,
    required String labelHi,
    required IconData icon,
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
                fontWeight: FontWeight.w500,
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

  Widget _buildDropdownField({
    required String labelEn,
    required String labelHi,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
                fontWeight: FontWeight.w500,
                color: AppColors.maroon.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.creamBackground,
            borderRadius: BorderRadius.circular(_inputBorderRadius),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select $labelEn',
                style: GoogleFonts.notoSans(color: Colors.grey.shade600),
              ),
              icon: const Icon(Icons.arrow_drop_down),
              borderRadius: BorderRadius.circular(12),
              dropdownColor: AppColors.whiteCard,
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: AppColors.maroon,
              ),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: FilledButton(
        onPressed: _onSaveProfile,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primarySaffron,
          foregroundColor: AppColors.whiteCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_inputBorderRadius),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Save Profile'),
      ),
    );
  }

  void _onSaveProfile() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStateId == null || _selectedDistrictId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'कृपया राज्य और जिला चुनें',
            style: GoogleFonts.notoSansDevanagari(fontSize: 14),
          ),
          backgroundColor: AppColors.maroon,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
          backgroundColor: AppColors.maroon,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // save profile via supabase
    final userData = {
      'name': _nameController.text.trim(),
      'father_name': _fatherNameController.text.trim(),
      'address_line': _addressLineController.text.trim(),
      'pincode': _pinCodeController.text.trim(),
      'state_id': _selectedStateId,
      'district_id': _selectedDistrictId,
      'block_id': _selectedBlockId,
      'village_id': _selectedVillageId,
      'date_of_birth': _dateOfBirth?.toIso8601String(),
      'phone': supabase.auth.currentUser?.phone,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    upsertUserProfile(userData).then((ok) {
      Navigator.of(context).pop();
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'प्रोफ़ाइल सुरक्षित कर दिया गया',
              style: GoogleFonts.notoSansDevanagari(fontSize: 14),
            ),
            backgroundColor: AppColors.maroon,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'प्रोफ़ाइल सेव करने में विफल',
              style: GoogleFonts.notoSansDevanagari(fontSize: 14),
            ),
            backgroundColor: AppColors.maroon,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }
}
