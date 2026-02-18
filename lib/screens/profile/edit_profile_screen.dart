import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.initialName = '',
    this.initialFatherName = '',
    this.initialAddress = '',
    this.initialStateId,
    this.initialStateName,
    this.initialDistrictId,
    this.initialDistrictName,
    this.initialBlockId,
    this.initialBlockName,
    this.initialVillageId,
    this.initialVillage,
    this.initialPhotoFile,
  });

  final String initialName;
  final String initialFatherName;
  final String initialAddress;
  final String? initialStateId;
  final String? initialStateName;
  final String? initialDistrictId;
  final String? initialDistrictName;
  final String? initialBlockId;
  final String? initialBlockName;
  final String? initialVillageId;
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

  // Location state variables (store both ID and name)
  String? _selectedStateId;
  String? _selectedStateName;
  String? _selectedDistrictId;
  String? _selectedDistrictName;
  String? _selectedBlockId;
  String? _selectedBlockName;
  String? _selectedVillageId;
  String? _selectedVillageName;

  // Lists for dropdowns
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _blocks = [];
  List<Map<String, dynamic>> _villages = [];

  static const double _inputBorderRadius = 14.0;
  static const double _cardBorderRadius = 20.0;
  static const double _buttonHeight = 56.0;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _fatherNameController.text = widget.initialFatherName;
    _addressController.text = widget.initialAddress;
    _selectedStateId = widget.initialStateId;
    _selectedStateName = widget.initialStateName;
    _selectedDistrictId = widget.initialDistrictId;
    _selectedDistrictName = widget.initialDistrictName;
    _selectedBlockId = widget.initialBlockId;
    _selectedBlockName = widget.initialBlockName;
    _selectedVillageId = widget.initialVillageId;
    _selectedVillageName = widget.initialVillage;
    _profileImageFile = widget.initialPhotoFile;
    _initializeLocationHierarchy();
  }

  Future<void> _initializeLocationHierarchy() async {
    // Load states
    await _loadStates();

    // If state is selected, load districts (don't reset selection during init)
    if (_selectedStateId != null) {
      await _loadDistricts(_selectedStateId!, resetSelection: false);
    }

    // If district is selected, load blocks (don't reset selection during init)
    if (_selectedDistrictId != null) {
      await _loadBlocks(_selectedDistrictId!, resetSelection: false);
    }

    // If block is selected, load villages (don't reset selection during init)
    if (_selectedBlockId != null) {
      await _loadVillages(_selectedBlockId!, resetSelection: false);
    }
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
            _buildAddressSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabeledField(
          icon: Icons.location_city_outlined,
          labelEn: 'State',
          labelHi: 'राज्य',
          child: _buildStateDropdown(),
        ),
        const SizedBox(height: 20),
        _buildLabeledField(
          icon: Icons.location_city_outlined,
          labelEn: 'District',
          labelHi: 'जिला',
          child: _buildDistrictDropdown(),
        ),
        const SizedBox(height: 20),
        _buildLabeledField(
          icon: Icons.location_city_outlined,
          labelEn: 'Block',
          labelHi: 'ब्लॉक',
          child: _buildBlockDropdown(),
        ),
        const SizedBox(height: 20),
        _buildLabeledField(
          icon: Icons.home_outlined,
          labelEn: 'Village',
          labelHi: 'गाँव',
          child: _buildVillageDropdown(),
        ),
      ],
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

  Future<void> _loadStates() async {
    final states = await fetchLocations(type: 'state');
    if (mounted) {
      setState(() {
        _states = states;
        // If we have an initial state id but no name, try to resolve it
        if ((_selectedStateName == null || _selectedStateName!.isEmpty) &&
            _selectedStateId != null) {
          final s = _states.firstWhere(
            (e) => e['id'] == _selectedStateId,
            orElse: () => {},
          );
          if (s.isNotEmpty) _selectedStateName = s['name'];
        }
      });
    }
  }

  Future<void> _loadDistricts(
    String stateId, {
    bool resetSelection = true,
  }) async {
    final districts = await fetchLocations(type: 'district', parentId: stateId);
    if (mounted) {
      setState(() {
        _districts = districts;
        if (resetSelection) {
          _selectedDistrictId = null;
          _selectedDistrictName = null;
          _blocks = [];
          _villages = [];
        } else {
          // try to resolve district name from id if available
          if ((_selectedDistrictName == null ||
                  _selectedDistrictName!.isEmpty) &&
              _selectedDistrictId != null) {
            final d = _districts.firstWhere(
              (e) => e['id'] == _selectedDistrictId,
              orElse: () => {},
            );
            if (d.isNotEmpty) _selectedDistrictName = d['name'];
          }
        }
      });
    }
  }

  Future<void> _loadBlocks(
    String districtId, {
    bool resetSelection = true,
  }) async {
    final blocks = await fetchLocations(type: 'block', parentId: districtId);
    if (mounted) {
      setState(() {
        _blocks = blocks;
        if (resetSelection) {
          _selectedBlockId = null;
          _selectedBlockName = null;
          _villages = [];
        } else {
          if ((_selectedBlockName == null || _selectedBlockName!.isEmpty) &&
              _selectedBlockId != null) {
            final b = _blocks.firstWhere(
              (e) => e['id'] == _selectedBlockId,
              orElse: () => {},
            );
            if (b.isNotEmpty) _selectedBlockName = b['name'];
          }
        }
      });
    }
  }

  Future<void> _loadVillages(
    String blockId, {
    bool resetSelection = true,
  }) async {
    final villages = await fetchLocations(type: 'village', parentId: blockId);
    if (mounted) {
      setState(() {
        _villages = villages;
        if (resetSelection) {
          _selectedVillageId = null;
          _selectedVillageName = null;
        } else {
          if ((_selectedVillageName == null || _selectedVillageName!.isEmpty) &&
              _selectedVillageId != null) {
            final v = _villages.firstWhere(
              (e) => e['id'] == _selectedVillageId,
              orElse: () => {},
            );
            if (v.isNotEmpty) _selectedVillageName = v['name'];
          }
        }
      });
    }
  }

  Widget _buildStateDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.circular(_inputBorderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStateName,
          isExpanded: true,
          hint: Text(
            'Select state',
            style: GoogleFonts.notoSans(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(12),
          items: _states
              .map(
                (s) => DropdownMenuItem<String>(
                  value: s['name'],
                  child: Text(
                    s['name'] as String,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: AppColors.maroon,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (name) {
            if (name != null) {
              final state = _states.firstWhere((s) => s['name'] == name);
              setState(() {
                _selectedStateId = state['id'];
                _selectedStateName = name;
              });
              _loadDistricts(_selectedStateId!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.circular(_inputBorderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDistrictName,
          isExpanded: true,
          hint: Text(
            _selectedStateName == null
                ? 'Select state first'
                : 'Select district',
            style: GoogleFonts.notoSans(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(12),
          disabledHint: Text(
            'Select state first',
            style: GoogleFonts.notoSans(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          items: _selectedStateName == null
              ? []
              : _districts
                    .map(
                      (d) => DropdownMenuItem<String>(
                        value: d['name'],
                        child: Text(
                          d['name'] as String,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: AppColors.maroon,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          onChanged: _selectedStateName == null
              ? null
              : (name) {
                  if (name != null) {
                    final district = _districts.firstWhere(
                      (d) => d['name'] == name,
                    );
                    setState(() {
                      _selectedDistrictId = district['id'];
                      _selectedDistrictName = name;
                    });
                    _loadBlocks(_selectedDistrictId!);
                  }
                },
        ),
      ),
    );
  }

  Widget _buildBlockDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.circular(_inputBorderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedBlockName,
          isExpanded: true,
          hint: Text(
            _selectedDistrictName == null
                ? 'Select district first'
                : 'Select block',
            style: GoogleFonts.notoSans(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(12),
          disabledHint: Text(
            'Select district first',
            style: GoogleFonts.notoSans(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          items: _selectedDistrictName == null
              ? []
              : _blocks
                    .map(
                      (b) => DropdownMenuItem<String>(
                        value: b['name'],
                        child: Text(
                          b['name'] as String,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: AppColors.maroon,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          onChanged: _selectedDistrictName == null
              ? null
              : (name) {
                  if (name != null) {
                    final block = _blocks.firstWhere((b) => b['name'] == name);
                    setState(() {
                      _selectedBlockId = block['id'];
                      _selectedBlockName = name;
                    });
                    _loadVillages(_selectedBlockId!);
                  }
                },
        ),
      ),
    );
  }

  Widget _buildVillageDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.circular(_inputBorderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVillageName,
          isExpanded: true,
          hint: Text(
            _selectedBlockName == null
                ? 'Select block first'
                : 'Select village',
            style: GoogleFonts.notoSans(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(12),
          disabledHint: Text(
            'Select block first',
            style: GoogleFonts.notoSans(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          items: _selectedBlockName == null
              ? []
              : _villages
                    .map(
                      (v) => DropdownMenuItem<String>(
                        value: v['name'],
                        child: Text(
                          v['name'] as String,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: AppColors.maroon,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          onChanged: _selectedBlockName == null
              ? null
              : (name) {
                  if (name != null) {
                    final village = _villages.firstWhere(
                      (v) => v['name'] == name,
                    );
                    setState(() {
                      _selectedVillageId = village['id'];
                      _selectedVillageName = name;
                    });
                  }
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
    if (_selectedVillageName == null || _selectedVillageName!.isEmpty) {
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

    final data = {
      'name': _nameController.text.trim(),
      'father_name': _fatherNameController.text.trim(),
      'address': _addressController.text.trim(),
      'state_id': _selectedStateId,
      'state': _selectedStateName,
      'district_id': _selectedDistrictId,
      'district': _selectedDistrictName,
      'block_id': _selectedBlockId,
      'block': _selectedBlockName,
      'village_id': _selectedVillageId,
      'village': _selectedVillageName,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    upsertUserProfile(data).then((ok) {
      Navigator.of(context).pop();
      if (ok) {
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
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'सेव करने में त्रुटि हुई',
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
