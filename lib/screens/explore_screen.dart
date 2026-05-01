import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

final exploreUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  final supabase = Supabase.instance.client;
  final currentUserId = supabase.auth.currentUser?.id;

  var query = supabase.from('profiles').select();
  if (currentUserId != null) query = query.not('id', 'eq', currentUserId);

  final response = await query.order('created_at', ascending: false).limit(20);
  return response.map((json) => AppUser.fromJson(json)).toList();
});

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(exploreUsersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppTheme.textPrimary(isDark);
    final textSecondary = AppTheme.textSecondary(isDark);
    final cardBg = AppTheme.cardColor(isDark);
    final cardBorder = AppTheme.cardBorder(isDark);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: InputBorder.none,
              filled: true,
              fillColor: cardBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onSubmitted: (value) => ref.invalidate(exploreUsersProvider),
          ),
        ),
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.explore_outlined, size: 64, color: textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder, width: 0.5),
                ),
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.violet50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: user.avatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(imageUrl: user.avatarUrl!, fit: BoxFit.cover),
                          )
                        : Center(
                            child: Text(
                              user.username[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.violet600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  title: Text(user.fullName ?? user.username, style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                  subtitle: Text('@${user.username}', style: TextStyle(color: textSecondary)),
                  trailing: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Follow'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}