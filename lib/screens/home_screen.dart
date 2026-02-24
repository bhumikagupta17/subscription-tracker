import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../widgets/subscription_card.dart';
import 'profile_screen.dart';
import 'add_subscription_screen.dart';
import '../screens/profile_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Subscription> subscriptions = [];
  @override
  void initState(){
    super.initState();
    loadSubscriptions();
  }
  int calculateDaysLeft(Subscription sub){
    final now=DateTime.now();
    final today=DateTime(now.year,now.month,now.day);
    final start=DateTime(sub.startDate.year,sub.startDate.month,sub.startDate.day);

    if(start.isAfter(today)){
      return start.difference(today).inDays;
    }

    if(sub.period=="Weekly"){
      int daysPassed=today.difference(start).inDays;
      int remainder=daysPassed%7;
      if(remainder==0) return 0;
      return 7-remainder;
    }
    
    if(sub.period=="Yearly"){
      DateTime nextDate=DateTime(today.year,start.month,start.day);
      if(nextDate.isBefore(today)){
        nextDate=DateTime(today.year+1,start.month,start.day);
      }
      return nextDate.difference(today).inDays;
    }

    // Monthly
    DateTime nextDate=DateTime(today.year,today.month,start.day);
    if(nextDate.isBefore(today)){
      nextDate=DateTime(today.year,today.month+1,start.day);
    }
    return nextDate.difference(today).inDays;
  }
  void sortSubscription(){
    setState(() {
      subscriptions.sort((a,b){
        int daysA=calculateDaysLeft(a);
        int daysB=calculateDaysLeft(b);
        return daysA.compareTo(daysB);
      });
    });
  }
  double get totalMonthlySpend {
    return subscriptions.fold(0.0, (sum, item) {
      double priceValue = double.tryParse(item.price.toString()) ?? 0.0;
      if (item.period == 'Yearly') return sum + (priceValue / 12);
      if (item.period == 'Weekly') return sum + (priceValue * 4);
      return sum + priceValue;
    });
  }
  Future<void> saveSubscription() async{
    final prefs =await SharedPreferences.getInstance();
    final String encodedData= json.encode(subscriptions.map((sub)=> sub.toMap()).toList());
    await prefs.setString('subscriptions_key',encodedData);
  }
  Future<void> loadSubscriptions() async{
    final prefs= await SharedPreferences.getInstance();
    final String? savedData=prefs.getString('subscriptions_key');

    if(savedData!=null){
      final List<dynamic> decodedData= json.decode(savedData);
      setState(() {
        subscriptions=decodedData.map((item)=> Subscription.fromMap(item))
        .toList();
      });
      sortSubscription();
    }
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
                        final sub = subscriptions[index]; 
                        
                        return Dismissible(
                          key: Key(sub.id), 
                          direction: DismissDirection.endToStart, 
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(Icons.delete_sweep, color: Colors.white, size: 32),
                          ),
                          
                          onDismissed: (direction) {

                            final deletedSub = sub;
                            final deletedIndex = index;

                            setState(() {
                              subscriptions.removeAt(index);
                            });
                            
                            saveSubscription(); 

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${deletedSub.name} deleted"),
                                backgroundColor: Colors.black87,
                                duration: const Duration(seconds: 3), 
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  textColor: Colors.greenAccent, 
                                  onPressed: () {
                                    setState(() {
                                      subscriptions.insert(deletedIndex, deletedSub);
                                    });
                                    saveSubscription(); 
                                  },
                                ),
                              ),
                            );
                          },
                          child: SubscriptionCard(subscription: sub),
                        );
                      },
                    )
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
            MaterialPageRoute(builder: (context) => const AddSubscriptionScreen()),
          );
          if (newSubscription != null) {
            setState(() {
              subscriptions.add(newSubscription);
            });
            saveSubscription();
            sortSubscription();
          }
        },
      ),
    );
  }
}