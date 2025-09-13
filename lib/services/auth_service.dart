import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';

class AuthService {
  final supabase = SupabaseConfig.client;

  Future<AuthResponse> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<AuthResponse> signUp(String email, String password) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signOut() async {
    try {
      print('AuthService: Starting sign out...');
      await supabase.auth.signOut(scope: SignOutScope.global);
      print('AuthService: Sign out completed');
    } catch (e) {
      print('AuthService: Sign out error: $e');
      rethrow;
    }
  }

  Session? get currentSession => supabase.auth.currentSession;
  
  User? get currentUser => supabase.auth.currentUser;
  
  bool get isSignedIn => currentSession != null;
}
