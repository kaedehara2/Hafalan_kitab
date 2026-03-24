import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://jpmeuarneniqepocbgcl.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpwbWV1YXJuZW5pcWVwb2NiZ2NsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxMTM2NzksImV4cCI6MjA2ODY4OTY3OX0.lCfaHZnqGlUxeFHBXU_oVvGDuu_xgNZuH-xIrSOXqHk';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  static SupabaseClient get client => Supabase.instance.client;
}