import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  final bool isCompact;

  const PostCard({super.key, required this.post, this.isCompact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = post.user;
    final bgColor = AppTheme.backgroundColor(isDark);
    final cardBg = AppTheme.cardColor(isDark);
    final cardBorder = AppTheme.cardBorder(isDark);
    final textPrimary = AppTheme.textPrimary(isDark);
    final textSecondary = AppTheme.textSecondary(isDark);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/post/${post.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Squircle avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.violet50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: user?.avatarUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: user!.avatarUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                (user?.username ?? '?')[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.violet600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user?.fullName ?? user?.username ?? 'Unknown',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                  fontSize: 15,
                                ),
                              ),
                              // TODO: Add verified badge based on user data
                            ],
                          ),
                          Text(
                            '@${user?.username ?? 'unknown'}',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      timeago.format(post.createdAt),
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Content
                Text(
                  post.content,
                  style: TextStyle(
                    fontSize: 15,
                    color: textPrimary,
                    height: 1.65,
                  ),
                ),
                // Image
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                        height: 200,
                        color: AppTheme.stone50,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: post.commentsCount > 0 ? post.commentsCount.toString() : '',
                      color: textSecondary,
                      isDark: isDark,
                      onTap: () => context.push('/post/${post.id}'),
                    ),
                    ActionButton(
                      icon: Icons.repeat,
                      label: '0',
                      color: textSecondary,
                      isDark: isDark,
                      onTap: () {},
                    ),
                    LikeButton(
                      isLiked: post.isLiked ?? false,
                      count: post.likesCount > 0 ? post.likesCount.toString() : '',
                      isDark: isDark,
                      onTap: () => _toggleLike(context),
                    ),
                    ActionButton(
                      icon: Icons.share_outlined,
                      color: textSecondary,
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLike(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      if (post.isLiked == true) {
        await supabase.from('likes').delete().match({
          'user_id': userId,
          'post_id': post.id,
        });
      } else {
        await supabase.from('likes').insert({
          'user_id': userId,
          'post_id': post.id,
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}