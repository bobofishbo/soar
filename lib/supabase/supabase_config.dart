import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://kfoeehepyjbbvnsvvztl.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtmb2VlaGVweWpiYnZuc3Z2enRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3MzQ5NjcsImV4cCI6MjA3MzMxMDk2N30.xoZ0cl9m5a4oAKAn5P_X2yp6LBqfaICK4Pw_SIpw6GM';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
