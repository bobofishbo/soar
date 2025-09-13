import 'package:flutter/material.dart';
import '../services/user_service.dart';

enum JobDirection {
  softwareEngineer('Software Engineer'),
  dataScientist('Data Scientist'),
  productManager('Product Manager'),
  designer('Designer'),
  consultant('Consultant'),
  entrepreneur('Entrepreneur'),
  researcher('Researcher'),
  finance('Finance'),
  marketing('Marketing'),
  other('Other');

  const JobDirection(this.displayName);
  final String displayName;
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _minorsController = TextEditingController();
  
  JobDirection? _selectedJobDirection;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _collegeController.dispose();
    _majorController.dispose();
    _minorsController.dispose();
    super.dispose();
  }

  Future<void> _submitOnboarding() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if username is available
      final isAvailable = await _userService.isUsernameAvailable(_usernameController.text.trim());
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username is already taken. Please choose another one.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create user profile
      await _userService.createUserProfile(
        username: _usernameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        collegeName: _collegeController.text.trim(),
        major: _majorController.text.trim(),
        minors: _minorsController.text.trim().isEmpty ? null : _minorsController.text.trim(),
        intendedJobDirection: _selectedJobDirection!.name,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home page
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Prevent going back
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Card(
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add,
                        size: 48,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome to Soar! 🚀',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Let\'s set up your profile to personalize your experience',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username *',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Choose a unique username',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Age field
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age *',
                  prefixIcon: const Icon(Icons.cake),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Age is required';
                  }
                  final age = int.tryParse(value.trim());
                  if (age == null || age < 13 || age > 100) {
                    return 'Please enter a valid age (13-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // College field
              TextFormField(
                controller: _collegeController,
                decoration: InputDecoration(
                  labelText: 'College/University *',
                  prefixIcon: const Icon(Icons.school),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'College/University is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Major field
              TextFormField(
                controller: _majorController,
                decoration: InputDecoration(
                  labelText: 'Major *',
                  prefixIcon: const Icon(Icons.book),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Major is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Minors field (optional)
              TextFormField(
                controller: _minorsController,
                decoration: InputDecoration(
                  labelText: 'Minors (Optional)',
                  prefixIcon: const Icon(Icons.library_books),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Separate multiple minors with commas',
                ),
              ),
              const SizedBox(height: 16),

              // Job Direction dropdown
              DropdownButtonFormField<JobDirection>(
                value: _selectedJobDirection,
                decoration: InputDecoration(
                  labelText: 'Intended Career Direction *',
                  prefixIcon: const Icon(Icons.work),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                validator: (value) {
                  if (value == null) {
                    return 'Please select your intended career direction';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Complete Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Required fields note
              const Text(
                '* Required fields',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
