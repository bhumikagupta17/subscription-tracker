import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController=TextEditingController();
  final TextEditingController _emailController=TextEditingController();
  final TextEditingController _phoneController=TextEditingController();
  
  void _submitProfile() async{
    if (_formKey.currentState!.validate()){
      final prefs= await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userEmail',_emailController.text);

      await prefs.setBool('hasSeenOnboard', true);
      if(mounted){
        Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context)=> const HomeScreen()),
      );
      }
      
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50,),
                const Text(
                  "Set Up Your Profile",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10,),
                const Text(
                  "Let's get to know you better.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ) , 
                const SizedBox(height: 50,),
                TextFormField(
                  controller: _nameController,
                  validator: (value) => value!.isEmpty? "Please enter your name":null,
                  decoration: _inputDecoration("Name", Icons.person_outline),
                ) ,
                const SizedBox(height: 20,),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => !value!.contains('@')? "Enter a valid email":null,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                ) ,
                const SizedBox(height: 20,),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.length<10? "Enter valid phone number":null,
                  decoration: _inputDecoration("Phone", Icons.phone_outlined),
                ) ,
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submitProfile,
                     child: Text("Get Started",
                     style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),)),
                ),
                const SizedBox(height: 40,)
                ],
            ),
          ),
        )
      ),
    );
  }
  InputDecoration _inputDecoration(String label, IconData icon){
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon,color: Colors.grey,),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
    );
  }
}