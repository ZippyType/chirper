import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

final postCommentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('comments').select(
    'id, post_id, user_id, content, created_at, user:profiles(id, username, full_name, avatar_url)'
  ).eq('post_id', postId).order('created_at', ascending: false);
  return response.map((json) => Comment.fromJson(json)).toList();
});

final postDetailProvider = FutureProvider.family<Post?, String>((ref, postId) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('posts').select(
    'id, user_id, content, image_url, likes_count, comments_count, created_at, user:profiles(id, username, full_name, avatar_url)'
  ).eq('id', postId).single();
  if (response.isNotEmpty) return Post.fromJson(response);
  return null;
});

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postDetailAsync = ref.watch(postDetailProvider(widget.postId));
    final commentsAsync = ref.watch(postCommentsProvider(widget.postId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppTheme.textPrimary(isDark);
    final textSecondary = AppTheme.textSecondary(isDark);
    final cardBg = AppTheme.cardColor(isDark);
    final cardBorder = AppTheme.cardBorder(isDark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: postDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (post) {
          if (post == null) return const Center(child: Text('Post not found'));
          final user = post.user;

          return Column(children: [
            Expanded(
              child: ListView(children: [
                // Post content
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      _buildAvatar(user?.avatarUrl, user?.username),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user?.fullName ?? user?.username ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                        Text('@${user?.username ?? 'unknown'}', style: TextStyle(color: textSecondary)),
                      ]),
                    ]),
                    const SizedBox(height: 12),
                    Text(post.content, style: TextStyle(fontSize: 18, color: textPrimary)),
                    if (post.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: post.imageUrl!, width: double.infinity)),
                    ],
                    const SizedBox(height: 12),
                    Text(timeago.format(post.createdAt), style: TextStyle(color: textSecondary)),
                  ]),
                ),
                Divider(color: cardBorder),
                Padding(padding: const EdgeInsets.all(16), child: Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary))),
                commentsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (comments) {
                    if (comments.isEmpty) {
                      return Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('No comments yet. Be the first!', style: TextStyle(color: textSecondary))));
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: cardBorder),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final cUser = comment.user;
                        return _buildCommentCard(comment, cUser, isDark, textPrimary, textSecondary);
                      },
                    );
                  },
                ),
              ]),
            ),
            // Comment input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardBg, border: Border(top: BorderSide(color: cardBorder))),
              child: Row(children: [
                Expanded(child: TextField(controller: _commentController, decoration: InputDecoration(hintText: 'Add a comment...', border: InputBorder.none, fillColor: isDark ? AppTheme.darkCard : AppTheme.stone50, filled: true))),
                IconButton(icon: const Icon(Icons.send), onPressed: () => _addComment(context)),
              ]),
            ),
          ]);
        },
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, String? username) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(color: AppTheme.violet50, borderRadius: BorderRadius.circular(12)),
      child: avatarUrl != null
          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: avatarUrl, fit: BoxFit.cover))
          : Center(child: Text((username ?? '?')[0].toUpperCase(), style: const TextStyle(color: AppTheme.violet600, fontWeight: FontWeight.w600))),
    );
  }

  Widget _buildCommentCard(Comment comment, AppUser? cUser, bool isDark, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildAvatar(cUser?.avatarUrl, cUser?.username),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(cUser?.fullName ?? cUser?.username ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
            const SizedBox(width: 4),
            Text('@${cUser?.username ?? 'unknown'}', style: TextStyle(color: textSecondary)),
            const SizedBox(width: 4),
            Text('- ${timeago.format(comment.createdAt)}', style: TextStyle(color: textSecondary, fontSize: 12)),
          ]),
          const SizedBox(height: 4),
          Text(comment.content),
        ])),
      ]),
    );
  }

  Future<void> _addComment(BuildContext context) async {
    if (_commentController.text.trim().isEmpty) return;
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;
      await supabase.from('comments').insert({'user_id': userId, 'post_id': widget.postId, 'content': _commentController.text.trim()});
      _commentController.clear();
      ref.invalidate(postCommentsProvider(widget.postId));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}