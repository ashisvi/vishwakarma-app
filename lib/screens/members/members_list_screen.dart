import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import 'user_profile_screen.dart';

class MembersListScreen extends StatefulWidget {
  const MembersListScreen({super.key});

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allMembers = [];
  List<Map<String, dynamic>> _filteredMembers = [];
  final TextEditingController _searchController = TextEditingController();

  // ─── Filter state ───
  final Set<String> _allDistricts = {};
  final Set<String> _allRoles = {};
  String? _selectedDistrict;
  String? _selectedBlock;
  String? _selectedVillage;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    final members = await fetchVerifiedMembers();
    if (mounted) {
      _allDistricts.clear();
      _allRoles.clear();
      for (final m in members) {
        final d = m['district'] as String? ?? '';
        final r = m['designation'] as String? ?? '';
        if (d.isNotEmpty) _allDistricts.add(d);
        if (r.isNotEmpty) _allRoles.add(r);
      }
      setState(() {
        _allMembers = members;
        _isLoading = false;
      });
      _applyFilters();
    }
  }

  /// Get blocks available for the selected district
  Set<String> get _availableBlocks {
    if (_selectedDistrict == null) return {};
    final blocks = <String>{};
    for (final m in _allMembers) {
      final d = (m['district'] as String?)?.toLowerCase() ?? '';
      final b = m['block'] as String? ?? '';
      if (d == _selectedDistrict!.toLowerCase() && b.isNotEmpty) {
        blocks.add(b);
      }
    }
    return blocks;
  }

  /// Get villages available for the selected block
  Set<String> get _availableVillages {
    if (_selectedBlock == null) return {};
    final villages = <String>{};
    for (final m in _allMembers) {
      final b = (m['block'] as String?)?.toLowerCase() ?? '';
      final v = m['village'] as String? ?? '';
      if (b == _selectedBlock!.toLowerCase() && v.isNotEmpty) {
        villages.add(v);
      }
    }
    return villages;
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers = _allMembers.where((m) {
        final name = (m['name'] as String?)?.toLowerCase() ?? '';
        final village = (m['village'] as String?)?.toLowerCase() ?? '';
        final district = (m['district'] as String?)?.toLowerCase() ?? '';
        final block = (m['block'] as String?)?.toLowerCase() ?? '';
        final fatherName = (m['father_name'] as String?)?.toLowerCase() ?? '';

        // Text search
        if (query.isNotEmpty &&
            !name.contains(query) &&
            !village.contains(query) &&
            !district.contains(query) &&
            !block.contains(query) &&
            !fatherName.contains(query)) {
          return false;
        }

        // District filter
        if (_selectedDistrict != null && district != _selectedDistrict!.toLowerCase()) {
          return false;
        }

        // Block filter
        if (_selectedBlock != null && block != _selectedBlock!.toLowerCase()) {
          return false;
        }

        // Village filter
        if (_selectedVillage != null && village != _selectedVillage!.toLowerCase()) {
          return false;
        }

        // Role filter
        if (_selectedRole != null) {
          final role = (m['designation'] as String?)?.toLowerCase() ?? '';
          if (role != _selectedRole!.toLowerCase()) return false;
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedDistrict = null;
      _selectedBlock = null;
      _selectedVillage = null;
      _selectedRole = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  bool get _hasActiveFilters =>
      _selectedDistrict != null ||
      _selectedBlock != null ||
      _selectedVillage != null ||
      _selectedRole != null ||
      _searchController.text.isNotEmpty;

  void _showFilterMenu(String title, List<String> items, ValueChanged<String> onPick) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.maroon,
                  ),
                ),
              ),
              const Divider(height: 1),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: AppColors.creamBackground),
                  itemBuilder: (ctx, i) {
                    return ListTile(
                      title: Text(
                        items[i],
                        style: GoogleFonts.notoSansDevanagari(fontSize: 15, color: AppColors.maroon),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        onPick(items[i]);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final blocks = _availableBlocks.toList()..sort();
    final villages = _availableVillages.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: buildAppHeader(
        titleEn: 'Member Directory',
        titleHi: 'सदस्य निर्देशिका',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // ─── Search bar ───
          Container(
            color: AppColors.primarySaffron,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, village, district...',
                hintStyle: GoogleFonts.notoSans(color: AppColors.subtitleGrey, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: AppColors.primarySaffron),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: AppColors.subtitleGrey,
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.whiteCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // ─── Filter chips ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: _selectedDistrict ?? 'District / जिला',
                    isActive: _selectedDistrict != null,
                    icon: Icons.location_city_outlined,
                    onTap: () {
                      final items = _allDistricts.toList()..sort();
                      if (items.isEmpty) return;
                      _showFilterMenu('Select District / जिला चुनें', items, (val) {
                        setState(() {
                          _selectedDistrict = val;
                          _selectedBlock = null;
                          _selectedVillage = null;
                        });
                        _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  if (_selectedDistrict != null && blocks.isNotEmpty) ...[
                    _buildFilterChip(
                      label: _selectedBlock ?? 'Block / ब्लॉक',
                      isActive: _selectedBlock != null,
                      icon: Icons.map_outlined,
                      onTap: () {
                        _showFilterMenu('Select Block / ब्लॉक चुनें', blocks, (val) {
                          setState(() {
                            _selectedBlock = val;
                            _selectedVillage = null;
                          });
                          _applyFilters();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (_selectedBlock != null && villages.isNotEmpty) ...[
                    _buildFilterChip(
                      label: _selectedVillage ?? 'Village / गाँव',
                      isActive: _selectedVillage != null,
                      icon: Icons.home_outlined,
                      onTap: () {
                        _showFilterMenu('Select Village / गाँव चुनें', villages, (val) {
                          setState(() => _selectedVillage = val);
                          _applyFilters();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  _buildFilterChip(
                    label: _selectedRole ?? 'Role / भूमिका',
                    isActive: _selectedRole != null,
                    icon: Icons.badge_outlined,
                    onTap: () {
                      final items = _allRoles.toList()..sort();
                      if (items.isEmpty) return;
                      _showFilterMenu('Select Role / भूमिका चुनें', items, (val) {
                        setState(() => _selectedRole = val);
                        _applyFilters();
                      });
                    },
                  ),
                  if (_hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    ActionChip(
                      label: Text('Clear', style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.maroon)),
                      avatar: Icon(Icons.clear_all, size: 16, color: AppColors.maroon),
                      backgroundColor: AppColors.whiteCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: AppColors.maroon.withValues(alpha: 0.3)),
                      ),
                      onPressed: _clearFilters,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // ─── Count ───
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Row(
                children: [
                  Text(
                    '${_filteredMembers.length} member${_filteredMembers.length == 1 ? '' : 's'} found',
                    style: GoogleFonts.notoSans(fontSize: 13, color: AppColors.subtitleGrey),
                  ),
                ],
              ),
            ),
          // ─── List ───
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primarySaffron))
                : _filteredMembers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.primarySaffron,
                        onRefresh: _loadMembers,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                          itemCount: _filteredMembers.length,
                          itemBuilder: (context, index) {
                            return _buildMemberCard(_filteredMembers[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primarySaffron.withValues(alpha: 0.15)
              : AppColors.whiteCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.primarySaffron
                : AppColors.subtitleGrey.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? AppColors.primarySaffron : AppColors.subtitleGrey),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primarySaffron : AppColors.maroon,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: isActive ? AppColors.primarySaffron : AppColors.subtitleGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_rounded, size: 64, color: AppColors.subtitleGrey),
          const SizedBox(height: 16),
          Text(
            'No members found',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              color: AppColors.subtitleGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search.',
            style: GoogleFonts.notoSans(color: AppColors.subtitleGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final name = member['name'] as String? ?? 'Unknown';
    // final fatherName = member['father_name'] as String? ?? '';
    final designation = member['designation'] as String?;
    final village = member['village'] as String? ?? '';
    final block = member['block'] as String? ?? '';
    final district = member['district'] as String? ?? '';
    final addressLine = member['address_line'] as String? ?? '';

    List<String> locParts = [];
    if (addressLine.isNotEmpty) locParts.add(addressLine);
    if (village.isNotEmpty) locParts.add(village);
    if (block.isNotEmpty) locParts.add(block);
    if (district.isNotEmpty) locParts.add(district);
    final locationText = locParts.join(', ');

    String roleDisplay = designation != null && designation.trim().isNotEmpty
        ? designation
        : '';
    Color roleColor = AppColors.maroon;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusCard)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserProfileScreen(user: member)),
          );
        },
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primarySaffron.withValues(alpha: 0.1),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: GoogleFonts.notoSans(
                    color: AppColors.primarySaffron,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.maroon,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Father's name removed as per request
                    if (locationText.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 13, color: AppColors.subtitleGrey),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              locationText,
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 12,
                                color: AppColors.subtitleGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (roleDisplay.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          roleDisplay,
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: AppColors.subtitleGrey, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
