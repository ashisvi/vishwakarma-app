import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../services/posts_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/post_card.dart';
import '../posts/post_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoadingPosts = true;
  List<Map<String, dynamic>> _userPosts = [];
  final Map<String, String?> _userReactions = {};

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    final posts = await fetchPostsDetailed(userId: widget.user['id'] as String);
    if (mounted) {
      setState(() {
        _userPosts = posts;
        _isLoadingPosts = false;
      });
      for (final p in posts) {
        getUserReaction(p['id']).then((r) {
          if (mounted) setState(() => _userReactions[p['id']] = r);
        });
      }
    }
  }

  void _onReact(String postId, String type) async {
    final idx = _userPosts.indexWhere((p) => p['id'] == postId);
    if (idx == -1) return;
    final post = Map<String, dynamic>.from(_userPosts[idx]);
    final current = _userReactions[postId];

    int likes = (post['likes'] as int?) ?? 0;
    int dislikes = (post['dislikes'] as int?) ?? 0;

    if (current == type) {
      if (type == 'like') likes = (likes - 1).clamp(0, 999999);
      if (type == 'dislike') dislikes = (dislikes - 1).clamp(0, 999999);
      _userReactions[postId] = null;
    } else {
      if (type == 'like') {
        likes = likes + 1;
        if (current == 'dislike') dislikes = (dislikes - 1).clamp(0, 999999);
      } else {
        dislikes = dislikes + 1;
        if (current == 'like') likes = (likes - 1).clamp(0, 999999);
      }
      _userReactions[postId] = type;
    }

    setState(() {
      _userPosts[idx] = {...post, 'likes': likes, 'dislikes': dislikes};
    });

    await reactToPost(postId, type);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user['name'] as String? ?? 'Unknown';

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: buildAppHeader(titleEn: name, titleHi: 'सदस्य प्रोफ़ाइल'),
      body: RefreshIndicator(
        onRefresh: _loadUserPosts,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildProfileHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              sliver: SliverToBoxAdapter(child: _buildDetailsCard()),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Posts',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.maroon,
                      ),
                    ),
                    Text(
                      'हाल की पोस्ट',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.maroon.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildPostsList(),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ─── Saffron header with avatar, name, father's name, and tag chips ───
  Widget _buildProfileHeader() {
    final name = widget.user['name'] as String? ?? 'Unknown';
    final fatherName = widget.user['father_name'] as String? ?? '';
    final designation = widget.user['designation'] as String?;
    final photoUrl = widget.user['avatar_url'] as String?;

    String roleDisplay = designation != null && designation.trim().isNotEmpty
        ? designation
        : '';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.primarySaffron),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      child: Column(
        children: [
          // ─ Avatar ─
          Container(
            width: 96,
            height: 96,
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
                      errorBuilder: (_, _, _) => Icon(
                        Icons.person,
                        size: 52,
                        color: AppColors.whiteCard,
                      ),
                    )
                  : Icon(Icons.person, size: 52, color: AppColors.whiteCard),
            ),
          ),
          const SizedBox(height: 12),
          // ─ Name ─
          Text(
            name,
            style: GoogleFonts.notoSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.whiteCard,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // ─ Father's name ─
          if (fatherName.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              'पिता का नाम: $fatherName',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 14,
                color: AppColors.whiteCard.withValues(alpha: 0.92),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          // ─ Tag chips ─
          if (roleDisplay.isNotEmpty)
            _buildChip(
              Icons.verified_user,
              roleDisplay,
              AppColors.whiteCard,
              AppColors.maroon,
              false,
            ),
        ],
      ),
    );
  }

  Widget _buildChip(
    IconData icon,
    String text,
    Color bgColor,
    Color textColor,
    bool hasBorder,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: hasBorder
            ? Border.all(color: textColor.withValues(alpha: 0.35))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Details card ─── matching profile_screen's icon+label+value pattern
  Widget _buildDetailsCard() {
    final fatherName = widget.user['father_name'] as String? ?? '';
    final education = widget.user['education'] as String? ?? '';
    final profession = widget.user['profession'] as String? ?? '';
    final phone = widget.user['phone'] as String? ?? '';
    final addressLine = widget.user['address_line'] as String? ?? '';

    final village = widget.user['village'] as String? ?? '';
    final block = widget.user['block'] as String? ?? '';
    final district = widget.user['district'] as String? ?? '';
    final state = widget.user['state'] as String? ?? '';

    // Build info entries, skip empty ones
    final entries = <_InfoEntry>[];
    if (phone.isNotEmpty) {
      entries.add(_InfoEntry(Icons.phone_outlined, 'Phone / फोन', phone));
    }
    if (addressLine.isNotEmpty) {
      entries.add(
        _InfoEntry(Icons.home_work_outlined, 'Address / पता', addressLine),
      );
    }
    if (education.isNotEmpty) {
      entries.add(
        _InfoEntry(Icons.school_outlined, 'Education / शिक्षा', education),
      );
    }
    if (profession.isNotEmpty) {
      entries.add(
        _InfoEntry(Icons.work_outline, 'Profession / व्यवसाय', profession),
      );
    }
    if (village.isNotEmpty) {
      entries.add(_InfoEntry(Icons.home_outlined, 'Village / गाँव', village));
    }
    if (block.isNotEmpty) {
      entries.add(_InfoEntry(Icons.map_outlined, 'Block / ब्लॉक', block));
    }
    if (district.isNotEmpty) {
      entries.add(
        _InfoEntry(Icons.location_city_outlined, 'District / जिला', district),
      );
    }
    if (state.isNotEmpty) {
      entries.add(_InfoEntry(Icons.flag_outlined, 'State / राज्य', state));
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Details',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.maroon,
                ),
              ),
              Text(
                ' / विवरण',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 14,
                  color: AppColors.maroon.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < entries.length; i++) ...[
            _buildInfoRow(entries[i].icon, entries[i].label, entries[i].value),
            if (i < entries.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  height: 1,
                  color: AppColors.creamBackground,
                  thickness: 1.5,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.creamBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primarySaffron),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  color: AppColors.subtitleGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.maroon,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostsList() {
    if (_isLoadingPosts) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primarySaffron),
          ),
        ),
      );
    }

    if (_userPosts.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.whiteCard,
            borderRadius: BorderRadius.circular(AppColors.radiusCardLarge),
          ),
          child: Column(
            children: [
              Icon(
                Icons.post_add_rounded,
                size: 64,
                color: AppColors.primarySaffron.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'No posts yet / कोई पोस्ट नहीं',
                style: GoogleFonts.notoSans(
                  color: AppColors.subtitleGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final post = _userPosts[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: PostCard.fromMap(
            postMap: post,
            userReaction: _userReactions[post['id']],
            onReact: _onReact,
            onOpenComments: (postId) async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
              );
              _loadUserPosts();
            },
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
              );
              _loadUserPosts();
            },
          ),
        );
      }, childCount: _userPosts.length),
    );
  }
}

class _InfoEntry {
  const _InfoEntry(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}
