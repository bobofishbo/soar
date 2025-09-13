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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.hasData ? snapshot.data!.session : null;
        
        if (session != null) {
          // User is authenticated, check if they have completed onboarding
          return FutureBuilder<UserProfile?>(
            future: UserService().getCurrentUserProfile(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (profileSnapshot.hasError) {
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
                            // Force rebuild by creating a new AuthWrapper
                            Navigator.pushReplacementNamed(context, '/');
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
                // User is authenticated but hasn't completed onboarding
                return const OnboardingPage();
              } else {
                // User is authenticated and has completed onboarding
                return const HomePage();
              }
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
