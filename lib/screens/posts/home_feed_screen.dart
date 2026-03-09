import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import 'create_post_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/posts_service.dart';
import 'post_detail_screen.dart';

String _formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  try {
    final dt = DateTime.parse(dateStr).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 7) {
      return '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  } catch (_) {
    return dateStr;
  }
}

String _monthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

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
    await _futurePosts;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primarySaffron,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vishwakarma',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.whiteCard,
            ),
          ),
          Text(
            'Yuva Sangathan',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.whiteCard.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.whiteCard,
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.whiteCard.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: AppColors.whiteCard),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'home_feed_create_post_fab',
      onPressed: () async {
        final res = await Navigator.of(context).push<bool?>(
          MaterialPageRoute(builder: (context) => const CreatePostScreen()),
        );
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
  Map<String, String?> _userReactions = {}; // postId -> 'like'|'dislike'|null

  @override
  void initState() {
    super.initState();
    widget.futurePosts.then((list) => _initialize(list));
  }

  void _initialize(List<Map<String, dynamic>> list) {
    setState(() {
      _posts = list;
    });
    // optionally fetch user reactions for posts in batch - simple per-post fetch for now
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
    // optimistic update
    final idx = _posts.indexWhere((p) => p['id'] == postId);
    if (idx == -1) return;
    final post = Map<String, dynamic>.from(_posts[idx]);
    final current = _userReactions[postId];

    int likes = (post['likes'] as int?) ?? 0;
    int dislikes = (post['dislikes'] as int?) ?? 0;

    if (current == type) {
      // remove
      if (type == 'like') likes = (likes - 1).clamp(0, 999999);
      if (type == 'dislike') dislikes = (dislikes - 1).clamp(0, 999999);
      _userReactions[postId] = null;
    } else {
      // switch
      if (type == 'like') {
        likes = likes + 1;
        if (current == 'dislike') dislikes = (dislikes - 1).clamp(0, 999999);
      } else {
        dislikes = dislikes + 1;
        if (current == 'like') likes = (likes - 1).clamp(0, 999999);
      }
      _userReactions[postId] = type;
    }

    // update local post
    setState(() {
      _posts[idx] = {...post, 'likes': likes, 'dislikes': dislikes};
    });

    // call backend
    final res = await reactToPost(postId, type);
    if (res == null && current != null && current == type) {
      // success removal
      return;
    }
    // If API returned null but we optimistically set, it's ok; we won't rollback here.
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
            return Center(child: Text('Failed to load posts'));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) return Center(child: Text('No posts yet'));
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
        padding: const EdgeInsets.all(10),
        children: [
          if (pinned.isNotEmpty) ...[
            _PinnedSection(
              post: _Post.fromMap(pinned.first),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(post: pinned.first),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...regular.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PostCard.fromMap(
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
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PostDetailScreen(post: p)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinnedSection extends StatelessWidget {
  const _PinnedSection({required this.post, this.onTap});

  final _Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.goldAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.goldAccent.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin,
                    size: 18,
                    color: AppColors.primarySaffron,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pinned Announcement',
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
              padding: const EdgeInsets.all(10),
              child: _PostCard(post: post, isInsidePinned: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    this.isInsidePinned = false,
    this.userReaction,
    this.onReact,
    this.onOpenComments,
    this.onTap,
  });

  // convenience named constructor used when building from server map
  factory _PostCard.fromMap({
    required Map<String, dynamic> postMap,
    String? userReaction,
    required void Function(String postId, String type) onReact,
    required Future<void> Function(String postId) onOpenComments,
    bool isInsidePinned = false,
    VoidCallback? onTap,
  }) {
    final post = _Post.fromMap(postMap);
    return _PostCard(
      post: post,
      isInsidePinned: isInsidePinned,
      userReaction: userReaction,
      onReact: onReact,
      onOpenComments: onOpenComments,
      onTap: onTap,
    );
  }

  final _Post post;
  final bool isInsidePinned;
  final String? userReaction;
  final void Function(String postId, String type)? onReact;
  final Future<void> Function(String postId)? onOpenComments;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildContent(),
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              _PostImageSlider(imageUrls: post.imageUrls),
            ],
            const SizedBox(height: 12),
            _ReactionBar(
              post: post,
              userReaction: userReaction,
              onReact: onReact,
              onOpenComments: onOpenComments,
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.creamBackground,
          child: Text(
            post.authorName.characters.first.toUpperCase(),
            style: GoogleFonts.notoSans(
              fontWeight: FontWeight.w700,
              color: AppColors.maroon,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.maroon,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                post.designation ?? '',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 13,
                  color: AppColors.maroon.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(post.createdAt),
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: AppColors.maroon.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      post.content,
      style: GoogleFonts.notoSansDevanagari(
        fontSize: 14,
        height: 1.5,
        color: AppColors.maroon.withValues(alpha: 0.95),
      ),
    );
  }
}

class _PostImageSlider extends StatefulWidget {
  const _PostImageSlider({required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<_PostImageSlider> createState() => _PostImageSliderState();
}

class _PostImageSliderState extends State<_PostImageSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.imageUrls.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                final url = widget.imageUrls[index];
                return Container(
                  color: AppColors.creamBackground,
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stack) {
                        return Container(
                          color: AppColors.creamBackground,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image,
                            size: 56,
                            color: AppColors.primarySaffron.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imageUrls.length,
            (i) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _currentIndex
                    ? AppColors.primarySaffron
                    : AppColors.primarySaffron.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReactionBar extends StatelessWidget {
  const _ReactionBar({
    required this.post,
    this.userReaction,
    this.onReact,
    this.onOpenComments,
  });

  final _Post post;
  final String? userReaction;
  final void Function(String postId, String type)? onReact;
  final Future<void> Function(String postId)? onOpenComments;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionReactionButton(
          icon: Icons.thumb_up,
          labelHi: 'पसंद करें',
          count: post.likes,
          active: userReaction == 'like',
          onTap: () => onReact?.call(post.id, 'like'),
        ),
        _ActionReactionButton(
          icon: Icons.thumb_down,
          labelHi: 'नापसंद करें',
          count: post.dislikes,
          active: userReaction == 'dislike',
          onTap: () => onReact?.call(post.id, 'dislike'),
        ),
        _ActionReactionButton(
          icon: Icons.chat_bubble_outline,
          labelHi: 'टिप्पणी',
          count: post.comments,
          onTap: () async => await onOpenComments?.call(post.id),
        ),
      ],
    );
  }
}

class _ActionReactionButton extends StatelessWidget {
  const _ActionReactionButton({
    required this.icon,
    required this.labelHi,
    required this.count,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String labelHi;
  final int count;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: active
                    ? AppColors.primarySaffron
                    : AppColors.maroon.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.maroon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.icon,
    required this.labelHi,
    required this.count,
  });

  final IconData icon;
  final String labelHi;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Hook up reactions
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: AppColors.maroon.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.maroon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Post {
  _Post({
    required this.id,
    required this.authorName,
    this.designation,
    this.createdAt,
    required this.content,
    this.imageUrls = const [],
    this.likes = 0,
    this.dislikes = 0,
    this.comments = 0,
    this.isPinned = false,
  });

  final String id;
  final String authorName;
  final String? designation;
  final String? createdAt;
  final String content;
  final List<String> imageUrls;
  final int likes;
  final int dislikes;
  final int comments;
  final bool isPinned;

  factory _Post.fromMap(Map<String, dynamic> m) {
    final author = m['author'] as Map<String, dynamic>?;
    String authorName = 'Unknown';
    String? designation;
    if (author != null) {
      authorName =
          (author['name'] ??
                  author['full_name'] ??
                  author['display_name'] ??
                  'Unknown')
              as String;
      designation = author['designation'] as String?;
    }
    final createdAt = m['created_at']?.toString();
    final images =
        (m['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? [];
    return _Post(
      id: m['id'] as String,
      authorName: authorName,
      designation: designation,
      createdAt: createdAt,
      content: (m['content'] ?? '') as String,
      imageUrls: images,
      likes: (m['likes'] is int)
          ? m['likes'] as int
          : int.tryParse(m['likes']?.toString() ?? '0') ?? 0,
      dislikes: (m['dislikes'] is int)
          ? m['dislikes'] as int
          : int.tryParse(m['dislikes']?.toString() ?? '0') ?? 0,
      comments: (m['comments_count'] is int)
          ? m['comments_count'] as int
          : int.tryParse(m['comments_count']?.toString() ?? '0') ?? 0,
      isPinned: (m['is_pinned'] ?? false) as bool,
    );
  }
}

// demo posts removed; feed loads real posts from backend
