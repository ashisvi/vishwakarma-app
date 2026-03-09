import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../services/posts_service.dart';

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

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primarySaffron,
        title: Text(
          'Post Details',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author info
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primarySaffron
                                  .withValues(alpha: 0.2),
                              child: Text(
                                (author?['name'] ?? 'U')
                                    .toString()
                                    .characters
                                    .first
                                    .toUpperCase(),
                                style: TextStyle(color: AppColors.maroon),
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
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.maroon,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(createdAt),
                                    style: GoogleFonts.notoSans(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Content
                        Text(
                          content,
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 16,
                            color: AppColors.maroon,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Images
                        if (imageUrls.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: PageView.builder(
                                itemCount: imageUrls.length,
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
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
                        const SizedBox(height: 16),
                        // Reactions
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.thumb_up,
                                color: _userReaction == 'like'
                                    ? AppColors.primarySaffron
                                    : Colors.grey,
                              ),
                              onPressed: () => _react('like'),
                            ),
                            Text(
                              '$_likes',
                              style: GoogleFonts.notoSans(
                                color: AppColors.maroon,
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: Icon(
                                Icons.thumb_down,
                                color: _userReaction == 'dislike'
                                    ? AppColors.primarySaffron
                                    : Colors.grey,
                              ),
                              onPressed: () => _react('dislike'),
                            ),
                            Text(
                              '$_dislikes',
                              style: GoogleFonts.notoSans(
                                color: AppColors.maroon,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Comments Section
                  Text(
                    'Comments',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.maroon,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _futureComments,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Failed to load comments',
                            style: GoogleFonts.notoSans(color: Colors.grey),
                          ),
                        );
                      }
                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return Center(
                          child: Text(
                            'No comments yet',
                            style: GoogleFonts.notoSans(color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final userName = comment['user_name'] ?? 'User';
                          final content = comment['content'] as String? ?? '';
                          final time = comment['created_at']?.toString() ?? '';
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.whiteCard,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primarySaffron
                                      .withValues(alpha: 0.2),
                                  child: Text(
                                    userName
                                        .toString()
                                        .characters
                                        .first
                                        .toUpperCase(),
                                    style: TextStyle(color: AppColors.maroon),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: GoogleFonts.notoSans(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.maroon,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        content,
                                        style: GoogleFonts.notoSansDevanagari(
                                          fontSize: 14,
                                          color: AppColors.maroon,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatDate(time),
                                        style: GoogleFonts.notoSans(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Comment Input
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: AppColors.whiteCard,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.creamBackground,
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendingComment ? null : _addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySaffron,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 13,
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
        ],
      ),
    );
  }
}
