import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_router.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/onboarding_page.dart';
import 'supabase/supabase_config.dart';
import 'services/user_service.dart';

Future<void> main() async {
  // Ensures Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase BEFORE runApp
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const AuthWrapper(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final UserService _userService = UserService();
  String? _lastSessionId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;
        final currentSessionId = session?.accessToken;
        
        // Check if session has changed
        if (_lastSessionId != currentSessionId) {
          _lastSessionId = currentSessionId;
          print('Session changed: ${currentSessionId != null ? 'logged in' : 'logged out'}');
        }
        
        if (session != null) {
          print('User is authenticated, checking profile...');
          // User is authenticated, check if they have completed onboarding
          return FutureBuilder<UserProfile?>(
            // Use session ID as key to force rebuild when session changes
            key: ValueKey(currentSessionId),
            future: _userService.getCurrentUserProfile(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (profileSnapshot.hasError) {
                print('Profile fetch error: ${profileSnapshot.error}');
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${profileSnapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Force rebuild
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final userProfile = profileSnapshot.data;
              if (userProfile == null) {
                print('No profile found, showing onboarding');
                // User is authenticated but hasn't completed onboarding
                return const OnboardingPage();
              } else {
                print('Profile found, showing home page');
                // User is authenticated and has completed onboarding
                return const HomePage();
              }
            },
          );
        } else {
          print('No session found, showing login page');
          // No session - user is not authenticated
          return const LoginPage();
        }
      },
    );
  }
}
