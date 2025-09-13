import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int careerXP = 120;
  int coins = 140;

  void _feedEagle() {
    setState(() {
      careerXP += 20;
      coins += 10;
    });
  }

  void _flyEagle() {
    setState(() {
      careerXP += 40;
      coins += 5;
    });
  }

  Future<void> _signOut() async {
    // Show confirmation dialog
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

    if (shouldSignOut != true) return;

    try {
      print('Attempting to sign out...');
      await _authService.signOut();
      print('Sign out successful');
      
      // Small delay to ensure the auth state change is processed
      await Future.delayed(const Duration(milliseconds: 100));
      
      // The AuthWrapper should automatically handle navigation
      // but we can also manually check if we're still on this page
      if (mounted) {
        print('Still mounted after sign out, checking auth state...');
      }
    } catch (e) {
      print('Sign out error: $e');
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

  String getEagleAsset() {
    if (careerXP >= 200) return 'assets/adulteagle.jpg';
    if (careerXP >= 100) return 'assets/middleeagle.jpg';
    return 'assets/babyeagle.jpg';
  }

  @override
  Widget build(BuildContext context) {
    double progress = careerXP / 200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hatch 🐣'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 🦅 Eagle Avatar
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(getEagleAsset()),
            ),
          ),
          const SizedBox(height: 12),

          // 📊 Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                Text(
                  "Career XP: $careerXP / 200",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.orangeAccent,
                  minHeight: 10,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 🍽️ Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _feedEagle,
                icon: const Icon(Icons.restaurant),
                label: const Text("Feed"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _flyEagle,
                icon: const Icon(Icons.flight_takeoff),
                label: const Text("Fly"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 🪶 Tip
          const Text(
            '"Tip: Log a small project to earn feathers!"',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),

          const Spacer(),

          // 💰 Coin count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber),
              const SizedBox(width: 5),
              Text("Coins: $coins"),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),

      // 🔽 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Store"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/store');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
