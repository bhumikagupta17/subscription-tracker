import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final formKey= GlobalKey<FormState>();

  final nameController= TextEditingController();
  final priceController = TextEditingController();

  String selectedPeriod= 'Monthly';
  DateTime selectedDate= DateTime.now();
  void presentDatePicker() async{
    final pickedDate= await showDatePicker(context: context,
     firstDate: DateTime(2020), lastDate: DateTime(2045),
     builder: (context, child) {
       return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ), 
        child: child!,
        );
     },
     );
     if(pickedDate!=null){
      setState(() {
        selectedDate=pickedDate;
      });
     }
  }

  void saveSubscription(){
    if(formKey.currentState!.validate()){
      final newSub= Subscription(
        id: DateTime.now().toString(), 
        name: nameController.text.trim(), 
        price: priceController.text, 
        startDate: selectedDate, period: selectedPeriod);
        Navigator.pop(context,newSub);
    }
  }
  @override
  Widget build(BuildContext context) {
return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("New Subscription", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Makes the back arrow black
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. App Name Input
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'App Name (e.g., Netflix)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.apps),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a name';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 2. Price Input
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Price (₹)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a price';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. Billing Cycle Dropdown
              DropdownButtonFormField<String>(
                value: selectedPeriod,
                decoration: InputDecoration(
                  labelText: 'Billing Cycle',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.autorenew),
                ),
                items: ['Weekly', 'Monthly', 'Yearly']
                    .map((period) => DropdownMenuItem(value: period, child: Text(period)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPeriod = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // 4. Date Picker Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "First Bill: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    TextButton.icon(
                      onPressed: presentDatePicker,
                      icon: const Icon(Icons.calendar_today, color: Colors.black),
                      label: const Text("Change", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              // 5. Save Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: saveSubscription,
                  child: const Text("Save Subscription", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
