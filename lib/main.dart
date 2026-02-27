import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboard') ?? false;
  runApp(MyApp(showHome: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showHome; 

  const MyApp({super.key, required this.showHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subscription Tracker',
      debugShowCheckedModeBanner: false,
      home: showHome ?  const HomeScreen() : const OnboardingScreen(),
    );
  }
}