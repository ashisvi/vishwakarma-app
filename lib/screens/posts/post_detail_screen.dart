import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../services/supabase_service.dart';
import '../../services/posts_service.dart';
import '../../utils/date_utils.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post});

  final Map<String, dynamic> post;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  String? _userReaction;
  int _likes = 0;
  int _dislikes = 0;
  late Future<List<Map<String, dynamic>>> _futureComments;
  final _commentController = TextEditingController();
  bool _sendingComment = false;

  @override
  void initState() {
    super.initState();
    _loadReaction();
    _likes = widget.post['likes'] ?? 0;
    _dislikes = widget.post['dislikes'] ?? 0;
    _futureComments = fetchComments(widget.post['id']);
  }

  Future<void> _loadReaction() async {
    final reaction = await getUserReaction(widget.post['id']);
    if (mounted) setState(() => _userReaction = reaction);
  }

  Future<void> _react(String type) async {
    final previousReaction = _userReaction;
    final newReaction = await reactToPost(widget.post['id'], type);
    setState(() {
      _userReaction = newReaction;
      if (newReaction == null) {
        // Undid the reaction
        if (previousReaction == 'like') _likes--;
        if (previousReaction == 'dislike') _dislikes--;
      } else if (newReaction == type) {
        // Set new reaction
        if (type == 'like') {
          _likes++;
          if (previousReaction == 'dislike') _dislikes--;
        } else if (type == 'dislike') {
          _dislikes++;
          if (previousReaction == 'like') _likes--;
        }
      }
    });
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sendingComment = true);
    final res = await addComment(widget.post['id'], text);
    setState(() => _sendingComment = false);
    if (res != null) {
      _commentController.clear();
      setState(() {
        _futureComments = fetchComments(widget.post['id']);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add comment')));
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final author = post['author'] as Map<String, dynamic>?;
    final imageUrls = post['image_urls'] as List<String>? ?? [];
    final content = post['content'] as String? ?? '';
    final createdAt = post['created_at']?.toString() ?? '';
    final currentUserId = supabase.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: buildAppHeader(
        titleEn: 'Post Details',
        titleHi: 'पोस्ट विवरण',
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureComments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load comments',
                      style: GoogleFonts.notoSans(
                        color: AppColors.subtitleGrey,
                      ),
                    ),
                  );
                }

                final comments = snapshot.data ?? [];

                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  children: [
                    // Post Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteCard,
                        borderRadius: BorderRadius.circular(AppColors.radiusCard),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author info
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primarySaffron
                                    .withValues(alpha: 0.18),
                                child: Text(
                                  (author?['name'] ?? 'U')
                                      .toString()
                                      .trim()
                                      .characters
                                      .first
                                      .toUpperCase(),
                                  style: GoogleFonts.notoSans(
                                    color: AppColors.maroon,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      author?['name'] ?? 'User',
                                      style: GoogleFonts.notoSans(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.maroon,
                                      ),
                                    ),
                                    Text(
                                      formatDate(createdAt),
                                      style: GoogleFonts.notoSans(
                                        fontSize: 12,
                                        color: AppColors.maroon.withValues(
                                          alpha: 0.55,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Content
                          Text(
                            content,
                            style: GoogleFonts.notoSansDevanagari(
                              fontSize: 16,
                              height: 1.4,
                              color: AppColors.maroon,
                            ),
                          ),
                          if (imageUrls.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 160,
                                child: PageView.builder(
                                  itemCount: imageUrls.length,
                                  itemBuilder: (context, index) {
                                    return Image.network(
                                      imageUrls[index],
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (context, error, stack) {
                                        return Container(
                                          color: AppColors.creamBackground,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 56,
                                            color: AppColors.primarySaffron
                                                .withValues(alpha: 0.7),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          // Reactions (bigger tap targets)
                          Row(
                            children: [
                              Expanded(
                                child: _PostReactionButton(
                                  icon: Icons.thumb_up,
                                  count: _likes,
                                  active: _userReaction == 'like',
                                  iconColor: AppColors.primarySaffron,
                                  onPressed: () => _react('like'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PostReactionButton(
                                  icon: Icons.thumb_down,
                                  count: _dislikes,
                                  active: _userReaction == 'dislike',
                                  iconColor: AppColors.dislikeGrey,
                                  onPressed: () => _react('dislike'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Comments Section
                    Text(
                      'Comments',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.maroon,
                      ),
                    ),
                    Text(
                      'टिप्पणियाँ',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.maroon.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (comments.isEmpty)
                      Text(
                        'No comments yet / अभी कोई टिप्पणी नहीं',
                        style: GoogleFonts.notoSans(
                          color: AppColors.subtitleGrey,
                        ),
                      )
                    else
                      ...List.generate(comments.length, (i) {
                        final comment = comments[i];
                        final isOwn = currentUserId != null &&
                            comment['user_id']?.toString() == currentUserId;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: i == comments.length - 1 ? 0 : 12,
                          ),
                          child: _CommentCard(
                            isOwn: isOwn,
                            userName: comment['user_name']?.toString() ?? 'User',
                            content: comment['content'] as String? ?? '',
                            createdAt: comment['created_at']?.toString() ?? '',
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
          ),
          // Comment Input
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.whiteCard,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 56,
                child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment / टिप्पणी लिखें...',
                         hintStyle: GoogleFonts.notoSans(fontSize: 14, color: AppColors.subtitleGrey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.creamBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendingComment ? null : _addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySaffron,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    child: _sendingComment
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 24),
                  ),
                ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostReactionButton extends StatelessWidget {
  const _PostReactionButton({
    required this.icon,
    required this.count,
    required this.active,
    required this.onPressed,
    required this.iconColor,
  });

  final IconData icon;
  final int count;
  final bool active;
  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: active ? iconColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: iconColor.withValues(alpha: active ? 0.35 : 0.14),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.maroon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({
    required this.isOwn,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  final bool isOwn;
  final String userName;
  final String content;
  final String createdAt;

  @override
  Widget build(BuildContext context) {
    final initial = userName.trim().characters.isNotEmpty
        ? userName.trim().characters.first.toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOwn
            ? AppColors.primarySaffron.withValues(alpha: 0.08)
            : AppColors.whiteCard,
        borderRadius: BorderRadius.circular(12),
        border: isOwn
            ? Border.all(
                color: AppColors.primarySaffron.withValues(alpha: 0.35),
                width: 1.5,
              )
            : Border.all(
                color: AppColors.subtitleGrey.withValues(alpha: 0.25),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isOwn
                ? AppColors.primarySaffron.withValues(alpha: 0.25)
                : AppColors.primarySaffron.withValues(alpha: 0.18),
            child: Text(
              initial,
              style: GoogleFonts.notoSans(
                color: AppColors.maroon,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.notoSans(
                    fontWeight: FontWeight.w800,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 14,
                    height: 1.35,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatDate(createdAt),
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppColors.maroon.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
