import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart'; 
import 'onboarding_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  final List<Subscription> subscriptions;
  const ProfileScreen({super.key, this.subscriptions = const []});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "Loading...";
  String userEmail = "Loading...";

  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Guest User';
      userEmail = prefs.getString('userEmail') ?? "No Email provided";
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = value;
    });
    await prefs.setBool('notificationsEnabled', value); 
  }

  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(text: userName);
    TextEditingController emailController = TextEditingController(text: userEmail);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name", prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('userName', nameController.text);
                await prefs.setString('userEmail', emailController.text);
                loadProfileData(); 
                if (mounted) Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _logOut() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out?"),
        content: const Text("This will remove your profile data from this device."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Log Out", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); 
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      }
    }
  }

  double _calculateMonthlySpend() {
    return widget.subscriptions.fold<double>(0.0, (double sum, item) {
      double priceValue = double.tryParse(item.price.toString()) ?? 0.0;
      if (item.period == 'Yearly') return sum + (priceValue / 12);
      if (item.period == 'Weekly') return sum + (priceValue * 4);
      return sum + priceValue; 
    });
  }

  @override
  Widget build(BuildContext context) {
    int activeSubsCount = widget.subscriptions.length;
    double monthlySpend = _calculateMonthlySpend();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(userEmail, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: _buildStatCard("Active Subs", "$activeSubsCount", Icons.subscriptions)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard("Monthly Spend", "₹${monthlySpend.toStringAsFixed(0)}", Icons.account_balance_wallet)),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.edit, "Edit Profile", true, onTap: _showEditProfileDialog),
                  const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFEEEEEE)),
                  
                  // Notifications Toggle
                  _buildToggleTile(
                    Icons.notifications_active_outlined, 
                    "Allow Notifications", 
                    _notificationsEnabled, 
                    _toggleNotifications
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFEEEEEE)),
                  const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFEEEEEE)),
                  
                  // Logout
                  _buildListTile(Icons.logout, "Log Out", false, isDestructive: true, onTap: _logOut),
                ],
              ),
            ),
            const SizedBox(height: 100), 
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor:  Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black, 
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 28),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, bool showArrow, {bool isDestructive = false, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.grey.shade100, shape: BoxShape.circle),
        child: Icon(icon, color: isDestructive ? Colors.red : Colors.black, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : Colors.black)),
      trailing: showArrow ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey) : null,
      onTap: onTap,
    );
  }

  Widget _buildToggleTile(IconData icon, String title, bool currentValue, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
      value: currentValue,
      activeColor: Colors.black, 
      onChanged: onChanged,
    );
  }
}