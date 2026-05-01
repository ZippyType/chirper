import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return null;
  final response = await supabase.from('profiles').select().eq('id', userId).single();
  if (response.isNotEmpty) return AppUser.fromJson(response);
  return null;
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppTheme.textPrimary(isDark);
    final textSecondary = AppTheme.textSecondary(isDark);
    final cardBg = AppTheme.cardColor(isDark);
    final cardBorder = AppTheme.cardBorder(isDark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => _showSettings(context, ref)),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) return const Center(child: Text('Not logged in'));
          return SingleChildScrollView(
            child: Column(children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.violet600, AppTheme.violet800], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder, width: 3)),
                        child: user.avatarUrl != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(13), child: CachedNetworkImage(imageUrl: user.avatarUrl!, fit: BoxFit.cover))
                            : Center(child: Text(user.username[0].toUpperCase(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.violet600))),
                      ),
                    ),
                    Row(children: [
                      OutlinedButton(onPressed: () => _editProfile(context, ref, user), child: const Text('Edit Profile')),
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context)),
                    ]),
                  ]),
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(user.fullName ?? user.username, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary)),
                        const VerifiedBadge(size: 18),
                      ]),
                      Text('@${user.username}', style: TextStyle(color: textSecondary)),
                      if (user.bio != null) ...[const SizedBox(height: 12), Text(user.bio!, style: TextStyle(fontSize: 15, color: textPrimary))],
                      if (user.website != null) ...[const SizedBox(height: 12), Row(children: [Icon(Icons.link, size: 16, color: AppTheme.violet600), const SizedBox(width: 4), Text(user.website!, style: TextStyle(color: AppTheme.violet600))])],
                    ]),
                  ),
                ]),
              ),
              Divider(color: cardBorder),
              ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), trailing: const Icon(Icons.chevron_right), onTap: () => _showSettings(context, ref)),
              ListTile(leading: const Icon(Icons.help_outline), title: const Text('Help & Support'), trailing: const Icon(Icons.chevron_right), onTap: () => _showHelp(context)),
              ListTile(leading: const Icon(Icons.info_outline), title: const Text('About'), trailing: const Icon(Icons.chevron_right), onTap: () => _showAbout(context)),
            ]),
          );
        },
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).state = value ? AppThemeMode.dark : AppThemeMode.light;
                Navigator.pop(context);
              },
            ),
          ),
        ]),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const Text('Help & Support', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(controller: scrollController, children: [
                _HelpItem(icon: Icons.person_add, title: 'How do I follow someone?', content: 'Go to their profile and tap the Follow button.'),
                _HelpItem(icon: Icons.chat_bubble, title: 'How do I comment on a post?', content: 'Tap the comment icon on any post.'),
                _HelpItem(icon: Icons.favorite, title: 'How do I like a post?', content: 'Tap the heart icon on any post.'),
                _HelpItem(icon: Icons.image, title: 'How do I add an image?', content: 'When creating a post, tap the image icon.'),
                const Divider(),
                const Text('Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ListTile(leading: const Icon(Icons.email), title: const Text('Email support'), subtitle: const Text('support@chirper.app')),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(context: context, applicationName: 'Chirper', applicationVersion: '1.0.0', applicationIcon: const AppLogo(size: 48), children: [const Text('A modern social platform.')]);
  }

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) context.go('/login');
  }

  Future<void> _editProfile(BuildContext context, WidgetRef ref, AppUser user) async {
    final usernameC = TextEditingController(text: user.username);
    final fullNameC = TextEditingController(text: user.fullName ?? '');
    final bioC = TextEditingController(text: user.bio ?? '');
    final websiteC = TextEditingController(text: user.website ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(controller: usernameC, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 12),
            TextField(controller: fullNameC, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(controller: bioC, maxLines: 3, decoration: const InputDecoration(labelText: 'Bio')),
            const SizedBox(height: 12),
            TextField(controller: websiteC, decoration: const InputDecoration(labelText: 'Website')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final supabase = Supabase.instance.client;
                await supabase.from('profiles').update({
                  'username': usernameC.text.trim(), 'full_name': fullNameC.text.trim(),
                  'bio': bioC.text.trim(), 'website': websiteC.text.trim(),
                }).eq('id', user.id);
                ref.invalidate(currentUserProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon; final String title; final String content;
  const _HelpItem({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 12), child: ExpansionTile(leading: Icon(icon), title: Text(title), children: [Padding(padding: const EdgeInsets.all(16), child: Text(content))]));
  }
}