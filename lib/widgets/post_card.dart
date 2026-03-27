import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.isInsidePinned = false,
    this.userReaction,
    this.onReact,
    this.onOpenComments,
    this.onTap,
    this.onAuthorTap,
  });

  factory PostCard.fromMap({
    required Map<String, dynamic> postMap,
    String? userReaction,
    required void Function(String postId, String type) onReact,
    required Future<void> Function(String postId) onOpenComments,
    bool isInsidePinned = false,
    VoidCallback? onTap,
    VoidCallback? onAuthorTap,
  }) {
    final post = Post.fromMap(postMap);
    return PostCard(
      post: post,
      isInsidePinned: isInsidePinned,
      userReaction: userReaction,
      onReact: onReact,
      onOpenComments: onOpenComments,
      onTap: onTap,
      onAuthorTap: onAuthorTap,
    );
  }

  final Post post;
  final bool isInsidePinned;
  final String? userReaction;
  final void Function(String postId, String type)? onReact;
  final Future<void> Function(String postId)? onOpenComments;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 6),
            _buildContent(),
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              PostImageSlider(imageUrls: post.imageUrls),
            ],
            const SizedBox(height: 8),
            ReactionBar(
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

  Widget _buildHeader(BuildContext context) {
    final designation = post.designation?.trim();
    final hasDesignation = designation != null && designation.isNotEmpty;
    final dateLabel = formatDate(post.createdAt);
    final metaStyle = GoogleFonts.notoSans(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.maroon.withValues(alpha: 0.62),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onAuthorTap,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.creamBackground,
            child: Text(
              post.authorName.characters.first.toUpperCase(),
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.w700,
                color: AppColors.maroon,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onAuthorTap,
                child: Text(
                  post.authorName,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.maroon,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              if (hasDesignation || dateLabel.isNotEmpty)
                Text.rich(
                  TextSpan(
                    children: [
                      if (hasDesignation)
                        TextSpan(
                          text: designation,
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.maroon.withValues(alpha: 0.82),
                          ),
                        ),
                      if (hasDesignation && dateLabel.isNotEmpty)
                        TextSpan(
                          text: ' · ',
                          style: metaStyle,
                        ),
                      if (dateLabel.isNotEmpty)
                        TextSpan(
                          text: dateLabel,
                          style: metaStyle,
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        height: 1.4,
        color: AppColors.maroon.withValues(alpha: 0.95),
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class PostImageSlider extends StatefulWidget {
  const PostImageSlider({super.key, required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<PostImageSlider> createState() => _PostImageSliderState();
}

class _PostImageSliderState extends State<PostImageSlider> {
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
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.imageUrls.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                final url = widget.imageUrls[index];
                return Container(
                   color: AppColors.creamBackground,
                  alignment: Alignment.center,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stack) => Container(
                      color: AppColors.creamBackground,
                      alignment: Alignment.center,
                      child: Icon(Icons.broken_image, size: 56, color: AppColors.primarySaffron.withValues(alpha: 0.7)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.imageUrls.length,
              (i) => Container(
                width: 10,
                height: 10,
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
      ],
    );
  }
}

class ReactionBar extends StatelessWidget {
  const ReactionBar({
    super.key,
    required this.post,
    this.userReaction,
    this.onReact,
    this.onOpenComments,
  });

  final Post post;
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
          count: post.likes,
          active: userReaction == 'like',
          iconColor: AppColors.primarySaffron,
          onTap: () => onReact?.call(post.id, 'like'),
        ),
        _ActionReactionButton(
          icon: Icons.thumb_down,
          count: post.dislikes,
          active: userReaction == 'dislike',
          iconColor: AppColors.dislikeGrey,
          onTap: () => onReact?.call(post.id, 'dislike'),
        ),
        _ActionReactionButton(
          icon: Icons.chat_bubble_outline,
          count: post.comments,
          iconColor: AppColors.maroon.withValues(alpha: 0.75),
          onTap: () => onOpenComments?.call(post.id),
        ),
      ],
    );
  }
}

class _ActionReactionButton extends StatelessWidget {
  const _ActionReactionButton({
    required this.icon,
    required this.count,
    this.active = false,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final int count;
  final bool active;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? iconColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: active ? iconColor : iconColor.withValues(alpha: 0.65),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
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

class Post {
  Post({
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
    this.authorId,
    this.authorData,
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
  final String? authorId;
  final Map<String, dynamic>? authorData;

  factory Post.fromMap(Map<String, dynamic> m) {
    final author = m['author'] as Map<String, dynamic>?;
    String authorName = 'Unknown';
    String? designation;
    String? authorId;
    if (author != null) {
      authorName = (author['name'] ?? author['full_name'] ?? author['display_name'] ?? 'Unknown').toString();
      designation = author['designation'] as String?;
      authorId = author['id'] as String?;
    }
    final createdAt = m['created_at']?.toString();
    final images = (m['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? [];
    return Post(
      id: m['id'] as String,
      authorName: authorName,
      designation: designation,
      createdAt: createdAt,
      content: (m['content'] ?? '') as String,
      imageUrls: images,
      likes: (m['likes'] is int) ? m['likes'] as int : int.tryParse(m['likes']?.toString() ?? '0') ?? 0,
      dislikes: (m['dislikes'] is int) ? m['dislikes'] as int : int.tryParse(m['dislikes']?.toString() ?? '0') ?? 0,
      comments: (m['comments_count'] is int) ? m['comments_count'] as int : int.tryParse(m['comments_count']?.toString() ?? '0') ?? 0,
      isPinned: (m['is_pinned'] ?? false) as bool,
      authorId: authorId,
      authorData: author,
    );
  }
}
