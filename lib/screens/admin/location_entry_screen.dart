import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';

class LocationEntryScreen extends StatefulWidget {
  const LocationEntryScreen({super.key});

  @override
  State<LocationEntryScreen> createState() => _LocationEntryScreenState();
}

class _LocationEntryScreenState extends State<LocationEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedType = 'state';
  bool _isLoading = false;

  // For parent selection
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _blocks = [];

  String? _selectedStateId;
  String? _selectedDistrictId;
  String? _selectedBlockId;

  // Dropdown options
  final List<String> _locationTypes = ['state', 'district', 'block', 'village'];
  
  String _getDisplayType(String type) {
    switch (type) {
      case 'state': return 'State';
      case 'district': return 'District';
      case 'block': return 'Block / Tehsil';
      case 'village': return 'Village / City';
      default: return type;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    final data = await fetchLocations(type: 'state');
    if (mounted) {
      setState(() {
        _states = data;
      });
    }
  }

  Future<void> _loadDistricts(String stateId) async {
    final data = await fetchLocations(type: 'district', parentId: stateId);
    if (mounted) {
      setState(() {
        _districts = data;
        _selectedDistrictId = null;
        _blocks = [];
        _selectedBlockId = null;
      });
    }
  }

  Future<void> _loadBlocks(String districtId) async {
    final data = await fetchLocations(type: 'block', parentId: districtId);
    if (mounted) {
      setState(() {
        _blocks = data;
        _selectedBlockId = null;
      });
    }
  }

  void _onTypeChanged(String? newType) {
    if (newType == null) return;
    setState(() {
      _selectedType = newType;
      // Reset selections based on level
      if (newType == 'state') {
        _selectedStateId = null;
        _selectedDistrictId = null;
        _selectedBlockId = null;
      } else if (newType == 'district') {
        _selectedDistrictId = null;
        _selectedBlockId = null;
      } else if (newType == 'block') {
        _selectedBlockId = null;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate if parent is selected based on type
    String? parentId;
    if (_selectedType == 'district') {
      if (_selectedStateId == null) return _showError('Please select a state');
      parentId = _selectedStateId;
    } else if (_selectedType == 'block') {
      if (_selectedDistrictId == null) return _showError('Please select a district');
      parentId = _selectedDistrictId;
    } else if (_selectedType == 'village') {
      if (_selectedBlockId == null) return _showError('Please select a block');
      parentId = _selectedBlockId;
    }

    setState(() => _isLoading = true);
    final name = _nameController.text.trim();
    
    final success = await insertLocation(
      name: name,
      type: _selectedType,
      parentId: parentId,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location added successfully!'), backgroundColor: Colors.green),
        );
        _nameController.clear();
        // If it was a parent type, reload that tier's children so it's available next time
        if (_selectedType == 'state') {
          _loadStates();
        } else if (_selectedType == 'district' && _selectedStateId != null) _loadDistricts(_selectedStateId!);
        else if (_selectedType == 'block' && _selectedDistrictId != null) _loadBlocks(_selectedDistrictId!);
      } else {
        _showError('Failed to add location. Please try again.');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDistrictOrBelow = ['district', 'block', 'village'].contains(_selectedType);
    final isBlockOrBelow = ['block', 'village'].contains(_selectedType);
    final isVillage = _selectedType == 'village';

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primarySaffron,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.whiteCard),
        title: Column(
          children: [
            Text(
              'Location Entry',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteCard,
              ),
            ),
            Text(
              'स्थान जोड़ें',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 13,
                color: AppColors.whiteCard.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primarySaffron))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add New Location',
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.maroon,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expand the database of locations available during user registration and profile editing.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),

                    // Location Type
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Location Type to Add',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppColors.whiteCard,
                      ),
                      items: _locationTypes.map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(_getDisplayType(t)),
                      )).toList(),
                      onChanged: _onTypeChanged,
                    ),
                    const SizedBox(height: 20),

                    // Hierarchy Selections dynamically shown based on target type
                    if (isDistrictOrBelow) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _selectedStateId,
                        decoration: InputDecoration(
                          labelText: 'Select State',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.whiteCard,
                        ),
                        items: _states.map((s) => DropdownMenuItem<String>(
                          value: s['id'].toString(),
                          child: Text(s['name']),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedStateId = val;
                          });
                          if (val != null) _loadDistricts(val);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (isBlockOrBelow) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDistrictId,
                        decoration: InputDecoration(
                          labelText: 'Select District',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.whiteCard,
                        ),
                        items: _districts.map((d) => DropdownMenuItem<String>(
                          value: d['id'].toString(),
                          child: Text(d['name']),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDistrictId = val;
                          });
                          if (val != null) _loadBlocks(val);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (isVillage) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _selectedBlockId,
                        decoration: InputDecoration(
                          labelText: 'Select Block / Tehsil',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.whiteCard,
                        ),
                        items: _blocks.map((b) => DropdownMenuItem<String>(
                          value: b['id'].toString(),
                          child: Text(b['name']),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedBlockId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Target Name
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: '${_getDisplayType(_selectedType)} Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppColors.whiteCard,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 48),

                    // Submit
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.add_location_alt),
                        label: Text(
                          'Save Location',
                          style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.maroon,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
