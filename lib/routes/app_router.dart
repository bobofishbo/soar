import 'package:flutter/material.dart';
import '../screens/login_page.dart';
import '../screens/home_page.dart';
import '../screens/onboarding_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case '/store':
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Store')),
            body: const Center(child: Text('Store Page - Coming Soon!')),
          ),
        );
      case '/profile':
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: const Center(child: Text('Profile Page - Coming Soon!')),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('No route defined'))),
        );
    }
  }
}
