import '../supabase/supabase_config.dart';

class UserProfile {
  final String id;
  final String userId; // References auth.users.id
  final String username;
  final int age;
  final String collegeName;
  final String major;
  final String? minors;
  final String intendedJobDirection;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.userId,
    required this.username,
    required this.age,
    required this.collegeName,
    required this.major,
    this.minors,
    required this.intendedJobDirection,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      age: json['age'] as int,
      collegeName: json['college_name'] as String,
      major: json['major'] as String,
      minors: json['minors'] as String?,
      intendedJobDirection: json['intended_job_direction'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'age': age,
      'college_name': collegeName,
      'major': major,
      'minors': minors,
      'intended_job_direction': intendedJobDirection,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class UserService {
  final supabase = SupabaseConfig.client;

  /// Check if a user profile exists for the current authenticated user
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Create a new user profile
  Future<UserProfile> createUserProfile({
    required String username,
    required int age,
    required String collegeName,
    required String major,
    String? minors,
    required String intendedJobDirection,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      final response = await supabase
          .from('user_profiles')
          .insert({
            'user_id': user.id,
            'username': username,
            'age': age,
            'college_name': collegeName,
            'major': major,
            'minors': minors,
            'intended_job_direction': intendedJobDirection,
          })
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error creating user profile: $e');
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  /// Update an existing user profile
  Future<UserProfile> updateUserProfile({
    required String profileId,
    String? username,
    int? age,
    String? collegeName,
    String? major,
    String? minors,
    String? intendedJobDirection,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (username != null) updateData['username'] = username;
      if (age != null) updateData['age'] = age;
      if (collegeName != null) updateData['college_name'] = collegeName;
      if (major != null) updateData['major'] = major;
      if (minors != null) updateData['minors'] = minors;
      if (intendedJobDirection != null) updateData['intended_job_direction'] = intendedJobDirection;
      
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from('user_profiles')
          .update(updateData)
          .eq('id', profileId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Check if a username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } catch (e) {
      print('Error checking username availability: $e');
      return false;
    }
  }
}
