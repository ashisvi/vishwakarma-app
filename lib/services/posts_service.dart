import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

const String kPostImageBucket = 'post-images';

/// Fetch posts with related data: images, author info, reaction counts and comment counts.
Future<List<Map<String, dynamic>>> fetchPostsDetailed({int limit = 50, String? userId}) async {
  try {
    // 1) fetch posts
    dynamic query = supabase.from('posts').select();
        
    if (userId != null) {
      query = query.eq('created_by', userId);
    }

    final postsResp = await query.order('created_at', ascending: false).limit(limit);
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
          final type = r['reaction'] as String?;
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
    if (!await file.exists()) {
      debugPrint('uploadPostImage: file does not exist at path ${file.path}');
      return null;
    }

    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final ts = DateTime.now().toUtc().millisecondsSinceEpoch;
    final ext = file.path.split('.').last;
    final path = 'posts/${user.id}_$ts.$ext';

    final storage = supabase.storage.from(kPostImageBucket);
    final contentType = _inferImageContentType(ext);
    final options = FileOptions(contentType: contentType);

    try {
      await storage.upload(path, file, fileOptions: options);
    } on StorageException catch (e) {
      debugPrint(
        'uploadPostImage StorageException (upload): status=${e.statusCode}, message=${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint(
        'uploadPostImage unknown error on upload, trying uploadBinary: $e',
      );
      try {
        final bytes = await file.readAsBytes();
        await storage.uploadBinary(path, bytes, fileOptions: options);
      } on StorageException catch (e2) {
        debugPrint(
          'uploadPostImage StorageException (uploadBinary): status=${e2.statusCode}, message=${e2.message}',
        );
        return null;
      } catch (e2) {
        debugPrint('uploadPostImage final failure: $e2');
        return null;
      }
    }

    final publicUrl = storage.getPublicUrl(path);
    return publicUrl;
  } catch (e) {
    debugPrint('uploadPostImage outer error: $e');
    return null;
  }
}

String _inferImageContentType(String ext) {
  final lower = ext.toLowerCase();
  switch (lower) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'heic':
    case 'heif':
      return 'image/heic';
    default:
      return 'application/octet-stream';
  }
}

class CreatePostWithImagesResult {
  CreatePostWithImagesResult({
    required this.post,
    required this.uploadedCount,
    required this.failedCount,
    required this.errors,
  });

  final Map<String, dynamic>? post;
  final int uploadedCount;
  final int failedCount;
  final List<String> errors;

  bool get hasErrors => failedCount > 0 || errors.isNotEmpty;
}

/// Create a post and associated images (if any).
/// Returns a structured result including upload stats and errors, or null on total failure.
Future<CreatePostWithImagesResult?> createPostWithImages({
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

    int uploadedCount = 0;
    int failedCount = 0;
    final List<String> errors = [];

    // upload images and insert into post_images with order_index
    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (var i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final url = await uploadPostImage(file);
        if (url == null) {
          failedCount++;
          errors.add('Image $i failed to upload');
          continue;
        }
        try {
          await supabase.from('post_images').insert({
            'post_id': postId,
            'image_url': url,
            'order_index': i,
          });
          uploadedCount++;
        } catch (e) {
          failedCount++;
          errors.add('Image $i DB insert error: $e');
          debugPrint('createPostWithImages post_images insert error: $e');
        }
      }
    }

    // return assembled post
    final detailed = await fetchPostsDetailed(limit: 50);
    final post = detailed.firstWhere(
      (p) => p['id'] == postId,
      orElse: () => Map<String, dynamic>.from(postRes as Map),
    );

    return CreatePostWithImagesResult(
      post: post,
      uploadedCount: uploadedCount,
      failedCount: failedCount,
      errors: errors,
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
    return resp['reaction'] as String?;
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
        'reaction': type,
      });
      return type;
    }

    final existingType = existing['reaction'] as String?;
    if (existingType == type) {
      // remove
      await supabase.from('post_reactions').delete().eq('id', existing['id']);
      return null;
    } else {
      // update
      await supabase
          .from('post_reactions')
          .update({'reaction': type})
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
    if (user == null) {
      debugPrint('addComment: user is null');
      return null;
    }
    debugPrint(
      'addComment: attempting insert for postId=$postId, userId=${user.id}, content=$content',
    );
    final resp = await supabase
        .from('post_comments')
        .insert({'post_id': postId, 'user_id': user.id, 'content': content})
        .select()
        .maybeSingle();
    debugPrint('addComment: insert response: $resp');
    if (resp == null) {
      debugPrint('addComment: insert returned null');
      return null;
    }
    return Map<String, dynamic>.from(resp as Map);
  } catch (e) {
    debugPrint('addComment error: $e');
    return null;
  }
}
