import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/user.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';

final notificationsProvider = FutureProvider<List<NotificationItem>>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  final response = await supabase.from('notifications').select(
    'id, type, read, created_at, sender_id, sender:profiles!sender_id(id, username, full_name, avatar_url), post:posts(id, content)'
  ).eq('user_id', userId).order('created_at', ascending: false).limit(50);

  return response.map((json) => NotificationItem.fromJson(json)).toList();
});

class NotificationItem {
  final String id;
  final String type;
  final bool read;
  final DateTime createdAt;
  final AppUser? sender;
  final Post? post;

  NotificationItem({required this.id, required this.type, required this.read, required this.createdAt, this.sender, this.post});

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      type: json['type'] as String,
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      sender: json['sender'] != null ? AppUser.fromJson(json['sender'] as Map<String, dynamic>) : null,
      post: json['post'] != null ? Post.fromJson(json['post'] as Map<String, dynamic>) : null,
    );
  }

  String get message {
    switch (type) {
      case 'like': return 'liked your post';
      case 'comment': return 'commented on your post';
      case 'follow': return 'started following you';
      default: return 'interacted with you';
    }
  }

  IconData get icon {
    switch (type) {
      case 'like': return Icons.favorite;
      case 'comment': return Icons.chat_bubble;
      case 'follow': return Icons.person_add;
      default: return Icons.notifications;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'like': return AppTheme.coral600;
      case 'comment': return AppTheme.violet600;
      case 'follow': return AppTheme.moss600;
      default: return AppTheme.stone500;
    }
  }
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppTheme.textPrimary(isDark);
    final textSecondary = AppTheme.textSecondary(isDark);
    final cardBg = AppTheme.cardColor(isDark);
    final cardBorder = AppTheme.cardBorder(isDark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(notificationsProvider)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notificationsProvider),
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 64, color: textSecondary),
                    const SizedBox(height: 16),
                    Text('No notifications yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary)),
                    const SizedBox(height: 8),
                    Text("You'll see likes, comments, and follows here", style: TextStyle(color: textSecondary)),
                  ],
                ),
              );
            }
            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: cardBorder),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.violet50,
                        backgroundImage: notification.sender?.avatarUrl != null
                            ? CachedNetworkImageProvider(notification.sender!.avatarUrl!)
                            : null,
                        child: notification.sender?.avatarUrl == null
                            ? Text((notification.sender?.username ?? '?')[0].toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.violet600))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@${notification.sender?.username ?? 'unknown'} ${notification.message}',
                                style: TextStyle(fontWeight: FontWeight.w500, color: textPrimary)),
                            const SizedBox(height: 4),
                            Text(timeago.format(notification.createdAt), style: TextStyle(color: textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(notification.icon, color: notification.iconColor, size: 20),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}