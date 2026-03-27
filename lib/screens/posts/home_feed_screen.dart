import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../services/posts_service.dart';
import '../../widgets/post_card.dart';
import '../members/user_profile_screen.dart';
import 'post_detail_screen.dart';
import 'create_post_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key, this.isAdmin = false});

  final bool isAdmin;

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  late Future<List<Map<String, dynamic>>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = fetchPostsDetailed();
  }

  Future<void> _refresh() async {
    setState(() {
      _futurePosts = fetchPostsDetailed();
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primarySaffron,
      elevation: 0,
      centerTitle: true,
      title: Column(
        children: [
          Text(
            'विश्वकर्मा युवा संगठन',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.whiteCard,
            ),
          ),
          Text(
            'Vishwakarma Yuva Sangathan',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: AppColors.whiteCard.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final res = await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CreatePostScreen()));
        if (res == true) {
          await _refresh();
        }
      },
      backgroundColor: AppColors.primarySaffron,
      foregroundColor: AppColors.whiteCard,
      icon: const Icon(Icons.edit),
      label: Text(
        'Create Post',
        style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: _buildAppBar(context),
      body: _HomeFeedBody(futurePosts: _futurePosts, onRefresh: _refresh),
      floatingActionButton: widget.isAdmin ? _buildFab(context) : null,
    );
  }
}

class _HomeFeedBody extends StatefulWidget {
  const _HomeFeedBody({required this.futurePosts, required this.onRefresh});

  final Future<List<Map<String, dynamic>>> futurePosts;
  final Future<void> Function() onRefresh;

  @override
  State<_HomeFeedBody> createState() => _HomeFeedBodyState();
}

class _HomeFeedBodyState extends State<_HomeFeedBody> {
  List<Map<String, dynamic>> _posts = [];
  final Map<String, String?> _userReactions =
      {}; // postId -> 'like'|'dislike'|null

  @override
  void initState() {
    super.initState();
    widget.futurePosts.then((list) => _initialize(list));
  }

  void _initialize(List<Map<String, dynamic>> list) {
    setState(() {
      _posts = list;
    });
    for (final p in list) {
      final pid = p['id'] as String;
      getUserReaction(pid).then((r) {
        if (mounted) setState(() => _userReactions[pid] = r);
      });
    }
  }

  Future<void> _handleRefresh() async {
    await widget.onRefresh();
    final fresh = await fetchPostsDetailed();
    setState(() {
      _posts = fresh;
    });
  }

  void _onReact(String postId, String type) async {
    final idx = _posts.indexWhere((p) => p['id'] == postId);
    if (idx == -1) return;
    final post = Map<String, dynamic>.from(_posts[idx]);
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
      _posts[idx] = {...post, 'likes': likes, 'dislikes': dislikes};
    });

    final res = await reactToPost(postId, type);
    if (res == null && current != null && current == type) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_posts.isEmpty) {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: widget.futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load posts'));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) return const Center(child: Text('No posts yet'));
          _initialize(list);
          return const SizedBox.shrink();
        },
      );
    }

    final pinned = _posts
        .where((p) => (p['is_pinned'] ?? false) == true)
        .toList();
    final regular = _posts
        .where((p) => (p['is_pinned'] ?? false) != true)
        .toList();

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          if (pinned.isNotEmpty) ...[
            _PinnedSection(
              postMap: pinned.first,
              userReaction: _userReactions[pinned.first['id'] as String],
              onReact: _onReact,
              onRefresh: _handleRefresh,
            ),
            const SizedBox(height: 12),
          ],
          ...regular.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PostCard.fromMap(
                postMap: p,
                userReaction: _userReactions[p['id'] as String],
                onReact: _onReact,
                onOpenComments: (postId) async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: p),
                    ),
                  );
                  await _handleRefresh();
                },
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: p),
                    ),
                  );
                  await _handleRefresh();
                },
                onAuthorTap: () {
                  final author = p['author'] as Map<String, dynamic>?;
                  if (author != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UserProfileScreen(user: author),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinnedSection extends StatelessWidget {
  const _PinnedSection({
    required this.postMap,
    this.userReaction,
    required this.onReact,
    required this.onRefresh,
  });

  final Map<String, dynamic> postMap;
  final String? userReaction;
  final void Function(String, String) onReact;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldAccent, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.goldAccent.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.push_pin, size: 18, color: AppColors.primarySaffron),
                const SizedBox(width: 8),
                Text(
                  'Pinned Announcement / पिन की घोषणा',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maroon,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: PostCard.fromMap(
              postMap: postMap,
              isInsidePinned: true,
              userReaction: userReaction,
              onReact: onReact,
              onOpenComments: (postId) async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: postMap),
                  ),
                );
                await onRefresh();
              },
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: postMap),
                  ),
                );
                await onRefresh();
              },
              onAuthorTap: () {
                final author = postMap['author'] as Map<String, dynamic>?;
                if (author != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(user: author),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
