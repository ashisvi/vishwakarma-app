import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'supabase_service.dart';

const String kPostImageBucket = 'post-images';

/// Fetch posts with related data: images, author info, reaction counts and comment counts.
Future<List<Map<String, dynamic>>> fetchPostsDetailed({int limit = 50}) async {
  try {
    // 1) fetch posts
    final postsResp = await supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

    debugPrint(postsResp.toString());
    final posts = List<Map<String, dynamic>>.from(postsResp as List);

    if (posts.isEmpty) return [];

    final postIds = posts.map((p) => p['id'] as String).toList();

    // 2) fetch images for all posts
    final imagesResp = await supabase
        .from('post_images')
        .select()
        .inFilter('post_id', postIds)
        .order('order_index', ascending: true);
    final images = List<Map<String, dynamic>>.from(imagesResp as List);

    // group images by post_id
    final Map<String, List<String>> imagesMap = {};
    for (final img in images) {
      final pid = img['post_id'] as String;
      final url = img['image_url'] as String;
      imagesMap.putIfAbsent(pid, () => []).add(url);
    }

    // 3) fetch reaction aggregates grouped by post_id and type
    final reactionsResp = await supabase
        .from('post_reactions')
        .select()
        .inFilter('post_id', postIds);
    // Note: PostgREST grouping via Supabase may vary; if the above doesn't work on your DB,
    // fallback to fetching counts per post in batches. For now, attempt a grouped query.
    List<Map<String, dynamic>> reactions = [];
    try {
      reactions = List<Map<String, dynamic>>.from(reactionsResp as List);
    } catch (_) {
      reactions = [];
    }

    // 4) fetch comment counts grouped by post_id
    final commentsResp = await supabase
        .from('post_comments')
        .select('post_id')
        .inFilter('post_id', postIds);
    List<Map<String, dynamic>> commentsAgg = [];
    try {
      commentsAgg = List<Map<String, dynamic>>.from(commentsResp as List);
    } catch (_) {
      commentsAgg = [];
    }

    // 5) fetch authors
    final authorIds = posts
        .map((p) => p['created_by'] as String)
        .toSet()
        .toList();
    final authorsResp = await supabase
        .from('users')
        .select()
        .inFilter('id', authorIds);
    final authors = List<Map<String, dynamic>>.from(authorsResp as List);
    final Map<String, Map<String, dynamic>> authorMap = {
      for (final a in authors) a['id'] as String: a,
    };

    // 6) assemble final list
    final List<Map<String, dynamic>> out = [];
    for (final p in posts) {
      final id = p['id'] as String;
      final author = authorMap[p['created_by'] as String];
      // compute counts
      int likes = 0;
      int dislikes = 0;
      for (final r in reactions) {
        if ((r['post_id'] as String) == id) {
          final type = r['type'] as String?;
          if (type == 'like') likes++;
          if (type == 'dislike') dislikes++;
        }
      }
      int commentCount = 0;
      for (final c in commentsAgg) {
        if ((c['post_id'] as String) == id) commentCount++;
      }

      out.add({
        ...p,
        'author': author,
        'image_urls': imagesMap[id] ?? [],
        'likes': likes,
        'dislikes': dislikes,
        'comments_count': commentCount,
      });
    }

    return out;
  } catch (e) {
    debugPrint('fetchPostsDetailed error: $e');
    return [];
  }
}

/// Upload an image file to storage bucket and return a public URL (or null).
Future<String?> uploadPostImage(File file) async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final ts = DateTime.now().toUtc().millisecondsSinceEpoch;
    final ext = file.path.split('.').last;
    final path = 'posts/${user.id}_$ts.$ext';

    final storage = supabase.storage.from(kPostImageBucket);
    await storage.upload(path, file);

    final publicUrl = storage.getPublicUrl(path);
    return publicUrl;
  } catch (e) {
    debugPrint('uploadPostImage error: $e');
    return null;
  }
}

/// Create a post and associated images (if any). Returns created post map or null.
Future<Map<String, dynamic>?> createPostWithImages({
  required String content,
  List<File>? imageFiles,
}) async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // insert post
    final postPayload = {'content': content, 'created_by': user.id};
    final postRes = await supabase
        .from('posts')
        .insert(postPayload)
        .select()
        .maybeSingle();
    if (postRes == null) return null;
    final postId = postRes['id'] as String;

    // upload images and insert into post_images with order_index
    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (var i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final url = await uploadPostImage(file);
        if (url == null) continue;
        await supabase.from('post_images').insert({
          'post_id': postId,
          'image_url': url,
          'order_index': i,
        });
      }
    }

    // return assembled post
    final detailed = await fetchPostsDetailed(limit: 50);
    return detailed.firstWhere(
      (p) => p['id'] == postId,
      orElse: () => Map<String, dynamic>.from(postRes as Map),
    );
  } catch (e) {
    debugPrint('createPostWithImages error: $e');
    return null;
  }
}

/// Get current user's reaction type for a post ('like'|'dislike' or null)
Future<String?> getUserReaction(String postId) async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final resp = await supabase
        .from('post_reactions')
        .select()
        .eq('post_id', postId)
        .eq('user_id', user.id)
        .maybeSingle();
    if (resp == null) return null;
    return resp['type'] as String?;
  } catch (e) {
    debugPrint('getUserReaction error: $e');
    return null;
  }
}

/// React to a post. `type` should be 'like' or 'dislike'.
/// Returns the new reaction state: 'like', 'dislike' or null (if removed).
Future<String?> reactToPost(String postId, String type) async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final existing = await supabase
        .from('post_reactions')
        .select()
        .eq('post_id', postId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing == null) {
      // insert
      await supabase.from('post_reactions').insert({
        'post_id': postId,
        'user_id': user.id,
        'type': type,
      });
      return type;
    }

    final existingType = existing['type'] as String?;
    if (existingType == type) {
      // remove
      await supabase.from('post_reactions').delete().eq('id', existing['id']);
      return null;
    } else {
      // update
      await supabase
          .from('post_reactions')
          .update({'type': type})
          .eq('id', existing['id']);
      return type;
    }
  } catch (e) {
    debugPrint('reactToPost error: $e');
    return null;
  }
}

/// Fetch comments for a post ordered by `created_at` ascending.
Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
  try {
    final resp = await supabase
        .from('post_comments')
        .select('id, post_id, user_id, content, created_at, users(name)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    final list = List<Map<String, dynamic>>.from(resp as List);
    // normalize to include user_name for convenience
    return list
        .map(
          (m) => {
            ...m,
            'user_name': (m['users'] is Map)
                ? (m['users']['name'] ?? m['users']['full_name'])
                : null,
          },
        )
        .toList();
  } catch (e) {
    debugPrint('fetchComments error: $e');
    return [];
  }
}

/// Add a comment to a post.
Future<Map<String, dynamic>?> addComment(String postId, String content) async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final resp = await supabase
        .from('post_comments')
        .insert({'post_id': postId, 'user_id': user.id, 'content': content})
        .select()
        .maybeSingle();
    if (resp == null) return null;
    return Map<String, dynamic>.from(resp as Map);
  } catch (e) {
    debugPrint('addComment error: $e');
    return null;
  }
}
