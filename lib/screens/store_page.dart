import 'package:flutter/material.dart';

class StoreItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String icon;
  final String category;

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.category,
  });
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  String selectedCategory = 'All';
  int userCoins = 140; // This should come from user data in real app

  final List<StoreItem> storeItems = [
    // Power-ups
    StoreItem(
      id: '1',
      name: 'XP Booster',
      description: 'Double XP for next 3 actions',
      price: 50,
      icon: '⚡',
      category: 'Power-ups',
    ),
    StoreItem(
      id: '2',
      name: 'Coin Multiplier',
      description: 'Triple coins for next 5 actions',
      price: 75,
      icon: '💰',
      category: 'Power-ups',
    ),
    StoreItem(
      id: '3',
      name: 'Energy Drink',
      description: 'Instantly restore all energy',
      price: 30,
      icon: '🍹',
      category: 'Power-ups',
    ),
    
    // Accessories
    StoreItem(
      id: '4',
      name: 'Golden Crown',
      description: 'Majestic crown for your eagle',
      price: 200,
      icon: '👑',
      category: 'Accessories',
    ),
    StoreItem(
      id: '5',
      name: 'Pilot Goggles',
      description: 'Cool aviator goggles',
      price: 150,
      icon: '🥽',
      category: 'Accessories',
    ),
    StoreItem(
      id: '6',
      name: 'Rainbow Wings',
      description: 'Colorful wing upgrade',
      price: 300,
      icon: '🌈',
      category: 'Accessories',
    ),
    
    // Food
    StoreItem(
      id: '7',
      name: 'Premium Fish',
      description: 'Delicious salmon (+40 XP)',
      price: 25,
      icon: '🐟',
      category: 'Food',
    ),
    StoreItem(
      id: '8',
      name: 'Golden Seed',
      description: 'Special seed (+60 XP)',
      price: 40,
      icon: '🌰',
      category: 'Food',
    ),
    StoreItem(
      id: '9',
      name: 'Eagle Treat',
      description: 'Ultimate eagle snack (+100 XP)',
      price: 80,
      icon: '🥜',
      category: 'Food',
    ),
  ];

  final List<String> categories = ['All', 'Power-ups', 'Accessories', 'Food'];

  List<StoreItem> get filteredItems {
    if (selectedCategory == 'All') {
      return storeItems;
    }
    return storeItems.where((item) => item.category == selectedCategory).toList();
  }

  void _purchaseItem(StoreItem item) {
    if (userCoins >= item.price) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Purchase ${item.name}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.description),
              const SizedBox(height: 16),
              Text(
                'Cost: ${item.price} coins',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'You have: $userCoins coins',
                style: TextStyle(
                  color: userCoins >= item.price ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userCoins -= item.price;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Purchased ${item.name}! ${item.icon}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Purchase'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store 🛒'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$userCoins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    selectedColor: Colors.orange.shade100,
                    checkmarkColor: Colors.orange,
                  ),
                );
              },
            ),
          ),
          
          // Store Items
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items in this category',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final canAfford = userCoins >= item.price;
                      
                      return Card(
                        elevation: 4,
                        child: InkWell(
                          onTap: () => _purchaseItem(item),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.icon,
                                  style: const TextStyle(fontSize: 40),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: canAfford ? Colors.green : Colors.grey,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.monetization_on,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item.price}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
