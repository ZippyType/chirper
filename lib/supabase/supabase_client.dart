import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://bzqnxbqxhmdlhavntgah.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_wRlyD_DBAO3vL8HSHRb9uQ_eSu7GXrT';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

void showSupabaseError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}