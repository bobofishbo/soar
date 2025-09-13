import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../screens/onboarding_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;

  // Controllers for editing
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _minorsController = TextEditingController();
  JobDirection? _selectedJobDirection;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _collegeController.dispose();
    _majorController.dispose();
    _minorsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _userService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
          if (profile != null) {
            _populateControllers();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _populateControllers() {
    if (_userProfile != null) {
      _usernameController.text = _userProfile!.username;
      _ageController.text = _userProfile!.age.toString();
      _collegeController.text = _userProfile!.collegeName;
      _majorController.text = _userProfile!.major;
      _minorsController.text = _userProfile!.minors ?? '';
      
      // Find the matching JobDirection
      _selectedJobDirection = JobDirection.values.firstWhere(
        (direction) => direction.name == _userProfile!.intendedJobDirection,
        orElse: () => JobDirection.other,
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_userProfile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProfile = await _userService.updateUserProfile(
        profileId: _userProfile!.id,
        username: _usernameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        collegeName: _collegeController.text.trim(),
        major: _majorController.text.trim(),
        minors: _minorsController.text.trim().isEmpty ? null : _minorsController.text.trim(),
        intendedJobDirection: _selectedJobDirection!.name,
      );

      setState(() {
        _userProfile = updatedProfile;
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      try {
        await _authService.signOut();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _isEditing
          ? TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          : Card(
              child: ListTile(
                title: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                subtitle: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('No profile found'),
              Text('Please complete your onboarding first'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
            ),
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        _userProfile!.username.isNotEmpty 
                            ? _userProfile!.username[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userProfile!.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Member since ${_userProfile!.createdAt.year}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Profile Information
            _buildProfileField(
              label: 'Username',
              value: _userProfile!.username,
              controller: _usernameController,
            ),
            _buildProfileField(
              label: 'Age',
              value: _userProfile!.age.toString(),
              controller: _ageController,
              keyboardType: TextInputType.number,
            ),
            _buildProfileField(
              label: 'College/University',
              value: _userProfile!.collegeName,
              controller: _collegeController,
            ),
            _buildProfileField(
              label: 'Major',
              value: _userProfile!.major,
              controller: _majorController,
            ),
            _buildProfileField(
              label: 'Minors',
              value: _userProfile!.minors ?? 'None',
              controller: _minorsController,
            ),

            // Career Direction
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _isEditing
                  ? DropdownButtonFormField<JobDirection>(
                      value: _selectedJobDirection,
                      decoration: InputDecoration(
                        labelText: 'Career Direction',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: JobDirection.values.map((direction) {
                        return DropdownMenuItem(
                          value: direction,
                          child: Text(direction.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedJobDirection = value;
                        });
                      },
                    )
                  : Card(
                      child: ListTile(
                        title: const Text(
                          'Career Direction',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                          JobDirection.values
                              .firstWhere((d) => d.name == _userProfile!.intendedJobDirection)
                              .displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (_isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _populateControllers(); // Reset to original values
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
