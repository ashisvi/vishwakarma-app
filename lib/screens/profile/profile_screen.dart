import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import 'edit_profile_screen.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  // Resolved display names for location fields. We prefer explicit names
  // (e.g., `village`) if present on the profile; otherwise we'll resolve
  // names from the corresponding *_id fields using `fetchLocationById`.
  String _displayVillage = '';
  String _displayBlock = '';
  String _displayDistrict = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final p = await fetchUserProfile();
    _profile = p;
    await _resolveLocationNames();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _resolveLocationNames() async {
    if (_profile == null) {
      if (mounted) {
        setState(() {
          _displayVillage = '';
          _displayBlock = '';
          _displayDistrict = '';
        });
      }
      return;
    }

    // Village
    String village = (_profile?['village'] ?? '') as String;
    if ((village).isEmpty && _profile?['village_id'] != null) {
      final loc = await fetchLocationById(_profile!['village_id']);
      village = loc?['name'] ?? '';
    }

    // Block
    String block = (_profile?['block'] ?? '') as String;
    if ((block).isEmpty && _profile?['block_id'] != null) {
      final loc = await fetchLocationById(_profile!['block_id']);
      block = loc?['name'] ?? '';
    }

    // District
    String district = (_profile?['district'] ?? '') as String;
    if ((district).isEmpty && _profile?['district_id'] != null) {
      final loc = await fetchLocationById(_profile!['district_id']);
      district = loc?['name'] ?? '';
    }

    if (mounted) {
      setState(() {
        _displayVillage = village;
        _displayBlock = block;
        _displayDistrict = district;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primarySaffron,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.w600,
            color: AppColors.whiteCard,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _ProfileCollapsingHeaderDelegate(
                    profile: _profile ?? <String, dynamic>{},
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildDetailsCard(),
                        const SizedBox(height: 24),
                        _buildActions(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDetailsCard() {
    final phone = _profile?['phone'] ?? '';
    final village = _displayVillage.isNotEmpty
        ? _displayVillage
        : (_profile?['village'] ?? '');
    final block = _displayBlock.isNotEmpty
        ? _displayBlock
        : (_profile?['block'] ?? '');
    final district = _displayDistrict.isNotEmpty
        ? _displayDistrict
        : (_profile?['district'] ?? '');
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.maroon,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'विवरण',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                color: AppColors.maroon.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.phone,
              labelEn: 'Phone',
              labelHi: 'मोबाइल',
              value: phone,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              icon: Icons.home_outlined,
              labelEn: 'Address',
              labelHi: 'पता',
              value: _profile?['address_line'] ?? '',
            ),
            const Divider(height: 16),
            _buildInfoRow(
              icon: Icons.home_outlined,
              labelEn: 'Village',
              labelHi: 'गाँव',
              value: village,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              icon: Icons.map_outlined,
              labelEn: 'Block',
              labelHi: 'ब्लॉक',
              value: block,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              icon: Icons.location_city_outlined,
              labelEn: 'District',
              labelHi: 'जिला',
              value: district,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String labelEn,
    required String labelHi,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primarySaffron),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: AppColors.maroon.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _PrimaryActionButton(
          icon: Icons.edit_outlined,
          labelEn: 'Edit Profile',
          labelHi: 'प्रोफ़ाइल संपादित करें',
          onTap: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      initialName: _profile?['name'] ?? '',
                      initialFatherName: _profile?['father_name'] ?? '',
                      initialAddress: _profile?['address_line'] ?? '',
                      initialStateId: _profile?['state_id'],
                      initialStateName: _profile?['state'],
                      initialDistrictId: _profile?['district_id'],
                      initialDistrictName: _profile?['district'],
                      initialBlockId: _profile?['block_id'],
                      initialBlockName: _profile?['block'],
                      initialVillageId: _profile?['village_id'],
                      initialVillage: _profile?['village'],
                    ),
                  ),
                )
                .then((r) {
                  if (r == true) _loadProfile();
                });
          },
        ),
        const SizedBox(height: 12),
        if (_profile?['role'] == 'admin' || _profile?['role'] == 'committee') ...[
          _SecondaryActionButton(
            icon: Icons.admin_panel_settings_outlined,
            labelEn: 'Admin Panel',
            labelHi: 'व्यवस्थापक पैनल',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
        // TODO: Implement language change functionality
        // _SecondaryActionButton(
        //   icon: Icons.language,
        //   labelEn: 'Change Language',
        //   labelHi: 'भाषा बदलें',
        //   onTap: () {
        //     // TODO: Navigate to language selection
        //   },
        // ),
        const SizedBox(height: 12),
        _SecondaryActionButton(
          icon: Icons.logout,
          labelEn: 'Logout',
          labelHi: 'लॉगआउट',
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
            signOut().then((_) {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            });
          },
        ),
      ],
    );
  }
}

/// Pinned header: order — avatar → name → father's name → designation → status.
/// On scroll, avatar / designation / status move away; name + father's name stay visible.
class _ProfileCollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ProfileCollapsingHeaderDelegate({required this.profile});

  final Map<String, dynamic> profile;

  /// Tight fit for avatar + text + chips so there isn’t empty space below.
  static const double _expandedExtent = 296;
  static const double _collapsedExtent = 88;

  @override
  double get maxExtent => _expandedExtent;

  @override
  double get minExtent => _collapsedExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final t = range > 0 ? (shrinkOffset / range).clamp(0.0, 1.0) : 1.0;
    final eased = Curves.easeOut.transform(t);

    final name = profile['name']?.toString() ?? '—';
    final father = profile['father_name']?.toString() ?? '';
    final designation = profile['designation']?.toString() ?? '';
    final isVerified = profile['is_verified'] == true;
    final photoUrl = profile['avatar_url'] as String?;

    final avatarDiameter = lerpDouble(100, 0, eased)!.clamp(0.0, 100.0);
    final showAvatar = avatarDiameter > 8;
    final chipOpacity = t < 0.55 ? (1.0 - t / 0.55).clamp(0.0, 1.0) : 0.0;
    final showChips = chipOpacity > 0.05;
    final collapsedLayout = eased > 0.82;

    final topPad = lerpDouble(12, 0, eased)!;
    final gapAfterAvatar = lerpDouble(10, 0, eased)!;
    final gapBeforeChips = lerpDouble(10, 0, eased)!;
    final bottomPad = lerpDouble(0, 4, eased)!;

    return Material(
      color: AppColors.primarySaffron,
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: collapsedLayout
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!collapsedLayout) SizedBox(height: topPad),
              // 1. Profile icon
              if (showAvatar)
                Opacity(
                  opacity: (1.0 - eased * 1.12).clamp(0.0, 1.0),
                  child: Container(
                    width: avatarDiameter,
                    height: avatarDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.whiteCard.withValues(alpha: 0.15),
                      border: Border.all(color: AppColors.whiteCard, width: 3),
                    ),
                    child: ClipOval(
                      child: photoUrl != null && photoUrl.isNotEmpty
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                size: avatarDiameter * 0.55,
                                color: AppColors.whiteCard,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: avatarDiameter * 0.55,
                              color: AppColors.whiteCard,
                            ),
                    ),
                  ),
                ),
              if (showAvatar && !collapsedLayout)
                SizedBox(height: gapAfterAvatar),
              // 2. Name
              Text(
                name,
                style: GoogleFonts.notoSans(
                  fontSize: lerpDouble(21, 19, eased),
                  fontWeight: FontWeight.w700,
                  color: AppColors.whiteCard,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // 3. Father's name
              if (father.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  'पिता का नाम: $father',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: lerpDouble(15, 14, eased),
                    color: AppColors.whiteCard.withValues(alpha: 0.92),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // 4. Designation — 5. Status (after designation)
              if (showChips) ...[
                SizedBox(height: gapBeforeChips),
                Opacity(
                  opacity: chipOpacity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (designation.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.whiteCard,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user,
                                size: 16,
                                color: AppColors.primarySaffron,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                designation,
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.maroon,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? AppColors.authorizedGreen.withValues(
                                  alpha: 0.12,
                                )
                              : AppColors.maroon.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isVerified
                                ? AppColors.authorizedGreen.withValues(
                                    alpha: 0.35,
                                  )
                                : AppColors.maroon.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVerified ? Icons.verified : Icons.pending,
                              size: 16,
                              color: isVerified
                                  ? AppColors.authorizedGreen
                                  : AppColors.creamBackground,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isVerified
                                  ? 'Authorized / अधिकृत'
                                  : 'Pending / प्रतीक्षमाण',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isVerified
                                    ? AppColors.authorizedGreen
                                    : AppColors.creamBackground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!collapsedLayout) SizedBox(height: bottomPad),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ProfileCollapsingHeaderDelegate oldDelegate) {
    return oldDelegate.profile != profile;
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.labelEn,
    required this.labelHi,
    required this.onTap,
  });

  final IconData icon;
  final String labelEn;
  final String labelHi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              labelEn,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              labelHi,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primarySaffron,
          foregroundColor: AppColors.whiteCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.labelEn,
    required this.labelHi,
    required this.onTap,
  });

  final IconData icon;
  final String labelEn;
  final String labelHi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: AppColors.primarySaffron),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              labelEn,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.maroon,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              labelHi,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.maroon,
              ),
            ),
          ],
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primarySaffron),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: AppColors.maroon,
        ),
      ),
    );
  }
}

class _TextActionButton extends StatelessWidget {
  const _TextActionButton({
    required this.icon,
    required this.labelEn,
    required this.labelHi,
    required this.onTap,
  });

  final IconData icon;
  final String labelEn;
  final String labelHi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.maroon),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelEn,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.maroon,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            labelHi,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.maroon,
            ),
          ),
        ],
      ),
    );
  }
}
