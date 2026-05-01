import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// OpenRouter API key provider
final openRouterApiKeyProvider = Provider<String>((ref) => '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');

// Moderation levels
enum ModerationLevel { none, low, medium, high, critical }

class ModerationResult {
  final ModerationLevel level;
  final String reason;
  final double confidence;

  ModerationResult({
    required this.level,
    required this.reason,
    required this.confidence,
  });

  factory ModerationResult.clean() => ModerationResult(
        level: ModerationLevel.none,
        reason: 'clean',
        confidence: 1.0,
      );
}

// Brainrot/offensive patterns
class PatternDatabase {
  static final List<String> brainrotPatterns = [
    'free money', 'dm for', 'tag 3 friends', 'cursed if',
    'giveaway', 'confirm follow', 'vote for me',
    'link in bio', 'promote here', 'shocking video',
    'you wont believe', 'secret revealed',
    '#fyp', '#viral', '#trending', 'double your money',
    'crypto investment', 'send bitcoin', 'eth',
  ];

  static final List<String> offensivePatterns = [
    'kill yourself', 'kys', 'die', 'hate you',
    'nigger', 'faggot', 'retard', 'slur',
  ];

  static final List<String> misinfoPatterns = [
    'fake news', 'hoax', 'fake', 'conspiracy',
  ];
}

// OpenRouter-powered AI moderator
class ContentModerator {
  static const String _openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  // Using free Qwen model
  static const String _model = 'qwen/qwen2.5-0.5b-instruct';

  static ModerationResult moderateContent(String content) {
    final lowerContent = content.toLowerCase();
    int offenseCount = 0;
    List<String> reasons = [];

    // Check brainrot patterns
    for (final pattern in PatternDatabase.brainrotPatterns) {
      if (lowerContent.contains(pattern)) {
        offenseCount++;
        reasons.add('brainrot: $pattern');
      }
    }

    // Check offensive
    for (final pattern in PatternDatabase.offensivePatterns) {
      if (lowerContent.contains(pattern)) {
        offenseCount += 3;
        reasons.add('offensive: $pattern');
      }
    }

    // Check misinfo
    for (final pattern in PatternDatabase.misinfoPatterns) {
      if (lowerContent.contains(pattern)) {
        offenseCount += 2;
        reasons.add('misinfo: $pattern');
      }
    }

    // Determine level
    if (offenseCount >= 4) {
      return ModerationResult(
        level: ModerationLevel.critical,
        reason: reasons.join(', '),
        confidence: 0.95,
      );
    } else if (offenseCount >= 2) {
      return ModerationResult(
        level: ModerationLevel.high,
        reason: reasons.join(', '),
        confidence: 0.85,
      );
    } else if (offenseCount == 1) {
      return ModerationResult(
        level: ModerationLevel.medium,
        reason: reasons.first,
        confidence: 0.75,
      );
    }

    return ModerationResult.clean();
  }

  // AI-powered analysis using OpenRouter
  static Future<ModerationResult?> moderateWithAI(String content, String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse(_openRouterUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://chirper.app',
          'X-Title': 'Chirper',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '''You are a content moderator for a social media platform called Chirper.
Analyze the following post content and determine if it violates community guidelines.

Categories to check:
1. Spam/Engagement bait - asking for likes, follows, DMs
2. Hate speech - targeting groups
3. Misinformation - fake news, conspiracy theories  
4. Threats - violence, self-harm
5. Scams - money schemes, phishing

Respond ONLY with a JSON object:
{"level": "none|low|medium|high|critical", "reason": "brief explanation", "confidence": 0.0-1.0}

If clean: {"level": "none", "reason": "clean", "confidence": 1.0}'''
            },
            {
              'role': 'user', 
              'content': 'Post content: "$content"\n\nAnalyze this post.'
            }
          ],
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];
        
        // Parse JSON from response
        final parsed = jsonDecode(reply);
        
        return ModerationResult(
          level: _parseLevel(parsed['level'] ?? 'none'),
          reason: parsed['reason'] ?? 'unknown',
          confidence: (parsed['confidence'] ?? 0.5).toDouble(),
        );
      }
    } catch (e) {
      // Return null to fall back to pattern matching
    }
    return null;
  }

  static ModerationLevel _parseLevel(String level) {
    switch (level) {
      case 'critical': return ModerationLevel.critical;
      case 'high': return ModerationLevel.high;
      case 'medium': return ModerationLevel.medium;
      case 'low': return ModerationLevel.low;
      default: return ModerationLevel.none;
    }
  }

  // Main moderation with AI enhancement
  static Future<ModerationResult> moderatePost(String content, String apiKey) async {
    // First do quick pattern matching
    final quickResult = moderateContent(content);
    
    // If clearly offensive, return immediately
    if (quickResult.level.index >= ModerationLevel.high.index) {
      return quickResult;
    }
    
    // Try AI analysis for borderline cases
    if (quickResult.level == ModerationLevel.medium) {
      final aiResult = await moderateWithAI(content, apiKey);
      if (aiResult != null && aiResult.level.index > ModerationLevel.low.index) {
        return aiResult;
      }
    }
    
    return quickResult;
  }

  static Future<void> processPostForModeration(String postId, String apiKey) async {
    final supabase = Supabase.instance.client;
    final post = await supabase.from('posts').select().eq('id', postId).single();
    
    if (post == null) return;
    
    final result = await moderatePost(post['content'] as String, apiKey);
    
    if (result.level != ModerationLevel.none) {
      // Remove post
      await supabase.from('posts').delete().eq('id', postId);
      
      // Log moderation
      await _logModeration(post['user_id'], postId, result);
      
      // Add warning
      await _addWarning(post['user_id'], result);
    }
  }

  static Future<void> _logModeration(String userId, String postId, ModerationResult result) async {
    final supabase = Supabase.instance.client;
    
    await supabase.from('moderation_log').insert({
      'user_id': userId,
      'post_id': postId,
      'reason': result.reason,
      'severity': result.level.name,
    });
  }

  static Future<void> _addWarning(String userId, ModerationResult result) async {
    final supabase = Supabase.instance.client;
    
    // Get current warnings
    final profile = await supabase.from('profiles').select('warnings').eq('id', userId).single();
    int warningCount = (profile?['warnings'] ?? 0) + 1;
    
    // Update warnings
    await supabase.from('profiles').update({
      'warnings': warningCount,
      'strike_reason': result.reason,
    }).eq('id', userId);
    
    // Insert notification
    await supabase.from('notifications').insert({
      'user_id': userId,
      'sender_id': '00000000-0000-0000-0000-000000000000',
      'type': 'warning',
    });
    
    // Ban if 3 warnings
    if (warningCount >= 3) {
      await supabase.from('profiles').update({
        'banned': true,
        'ban_date': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    }
  }

  static Future<void> moderateRecentPosts(String apiKey) async {
    final supabase = Supabase.instance.client;
    final dayAgo = DateTime.now().subtract(const Duration(hours: 24));
    
    final posts = await supabase.from('posts')
        .select('id, user_id, content')
        .gte('created_at', dayAgo.toIso8601String())
        .eq('moderated', false);

    for (final post in posts) {
      await processPostForModeration(post['id'], apiKey);
    }
  }
}

// Riverpod providers
final openRouterApiKeyProvider = Provider<String>((ref) => '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');
final contentModeratorProvider = Provider((ref) => ContentModerator());

final moderateContentProvider = FutureProvider.family<ModerationResult, String>((ref, content) async {
  final apiKey = ref.watch(openRouterApiKeyProvider);
  return ContentModerator.moderatePost(content, apiKey);
});

final moderateAllPostsProvider = FutureProvider((ref) async {
  final apiKey = ref.watch(openRouterApiKeyProvider);
  return ContentModerator.moderateRecentPosts(apiKey);
});