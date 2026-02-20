import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../widgets/subscription_card.dart';
import 'profile_screen.dart';
import 'add_subscription_screen.dart';
import '../screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Subscription> subscriptions = [];

  double get totalMonthlySpend {
    return subscriptions.fold(0.0, (sum, item) {
      double priceValue = double.tryParse(item.price.toString()) ?? 0.0;
      if (item.period == 'Yearly') return sum + (priceValue / 12);
      if (item.period == 'Weekly') return sum + (priceValue * 4);
      return sum + priceValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0, 
        title: const Text(
          "My Subscriptions",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Monthly Spend",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${totalMonthlySpend.toStringAsFixed(0)}",
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ), 

            const SizedBox(height: 24),
            
            const Text(
              "Your Active Plans", 
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)
            ),
            
            const SizedBox(height: 16),

            Expanded(
              child: subscriptions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            "No subscriptions yet.\nTap the + button to add one!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                          )
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: subscriptions.length,
                      itemBuilder: (context, index) {
                        return SubscriptionCard(subscription: subscriptions[index]);
                      },
                    ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 28), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 28), label: "Profile"),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen(subscriptions: subscriptions)),
            );
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final newSubscription = await Navigator.push<Subscription>(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          if (newSubscription != null) {
            setState(() {
              subscriptions.add(newSubscription);
            });
          }
        },
      ),
    );
  }
}