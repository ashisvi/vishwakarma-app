import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../services/posts_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key, required this.postId});

  final String postId;

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late Future<List<Map<String, dynamic>>> _futureComments;
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _futureComments = fetchComments(widget.postId);
  }

  Future<void> _reload() async {
    setState(() {
      _futureComments = fetchComments(widget.postId);
    });
    await _futureComments;
  }

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    final res = await addComment(widget.postId, text);
    setState(() => _sending = false);
    if (res != null) {
      _controller.clear();
      await _reload();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add comment')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primarySaffron,
        title: Text(
          'Comments',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureComments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError)
                  return Center(child: Text('Failed to load comments'));
                final items = snapshot.data ?? [];
                if (items.isEmpty)
                  return Center(child: Text('No comments yet'));
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final c = items[index];
                    final userId = c['user_id'] as String?;
                    final content = c['content'] as String? ?? '';
                    final time = c['created_at']?.toString() ?? '';
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (c['user_name'] ?? 'U')
                              .toString()
                              .characters
                              .first
                              .toUpperCase(),
                        ),
                      ),
                      title: Text(
                        c['user_name'] ?? 'User',
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(content, style: GoogleFonts.notoSans()),
                          const SizedBox(height: 6),
                          Text(
                            time,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(),
                  itemCount: items.length,
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sending ? null : _addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySaffron,
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
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
