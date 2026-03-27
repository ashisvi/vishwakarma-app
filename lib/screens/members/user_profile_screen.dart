import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
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
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primarySaffron,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.whiteCard),
        title: Column(
          children: [
            Text(
              name,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteCard,
              ),
            ),
            Text(
              'User Profile / उपयोगकर्ता प्रोफ़ाइल',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 12,
                color: AppColors.whiteCard.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserPosts,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildProfileHeader()),
            SliverToBoxAdapter(child: _buildDetailsSection()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
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

  Widget _buildProfileHeader() {
    final name = widget.user['name'] as String? ?? 'Unknown';
    final designation = widget.user['designation'] as String?;

    String roleDisplay = designation != null && designation.trim().isNotEmpty 
        ? designation 
        : 'Member';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primarySaffron, width: 2),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primarySaffron.withValues(alpha: 0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: GoogleFonts.notoSans(
                  color: AppColors.primarySaffron,
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.maroon,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primarySaffron.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primarySaffron.withValues(alpha: 0.3)),
            ),
            child: Text(
              roleDisplay,
              style: GoogleFonts.notoSansDevanagari(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.maroon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    final fatherName = widget.user['father_name'] as String? ?? '';
    final education = widget.user['education'] as String? ?? '';
    final profession = widget.user['profession'] as String? ?? '';
    final phone = widget.user['phone'] as String? ?? '';
    
    final village = widget.user['village'] as String? ?? '';
    final block = widget.user['block'] as String? ?? '';
    final district = widget.user['district'] as String? ?? '';
    final state = widget.user['state'] as String? ?? '';
    
    List<String> locParts = [];
    if (village.isNotEmpty) locParts.add(village);
    if (block.isNotEmpty) locParts.add(block);
    if (district.isNotEmpty) locParts.add(district);
    if (state.isNotEmpty) locParts.add(state);
    final location = locParts.join(', ');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.person_outline, "Father's Name / पिता का नाम", fatherName),
          if (education.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
            _buildInfoRow(Icons.school_outlined, "Education / शिक्षा", education),
          ],
          if (profession.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
            _buildInfoRow(Icons.work_outline, "Profession / व्यवसाय", profession),
          ],
          if (phone.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
            _buildInfoRow(Icons.phone_outlined, "Phone / फोन", phone, isPhone: true),
          ],
          if (location.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
            _buildInfoRow(Icons.location_on_outlined, "Address / पता", location),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isPhone = false}) {
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
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.notoSans(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
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
          child: Center(child: CircularProgressIndicator(color: AppColors.primarySaffron)),
        ),
      );
    }

    if (_userPosts.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.whiteCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(Icons.post_add_rounded, size: 64, color: AppColors.primarySaffron.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text(
                'No posts yet / कोई पोस्ट नहीं',
                style: GoogleFonts.notoSans(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final post = _userPosts[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
        },
        childCount: _userPosts.length,
      ),
    );
  }
}
