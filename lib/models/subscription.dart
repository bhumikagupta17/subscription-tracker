import 'package:flutter/material.dart';

class Subscription{
  final String id;
  final String name;
  final String price;
  final String period;
  final DateTime startDate;
  final String category;

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.startDate,
    required this.period,
    this.category="Other",
  });

  DateTime get nextBillDate{
    DateTime now =DateTime.now();
    DateTime date=startDate;
    while(date.isBefore(now) || date.isAtSameMomentAs(now)){
      if(period=="Weekly"){
        date=date.add(const Duration(days: 7));
      }else if (period=="Monthly"){
        int newYear = date.year;
        int newMonth = date.month + 1;
        int lastDayOfNextMonth = DateTime(newYear, newMonth + 1, 0).day;
        int correctDay = (startDate.day > lastDayOfNextMonth) ? lastDayOfNextMonth : startDate.day;
        date = DateTime(newYear, newMonth, correctDay);
      }else if (period=="Yearly"){
        date=DateTime(date.year+1,date.month,date.day);
        if (startDate.month == 2 && startDate.day == 29 && date.month == 3) {
           date = DateTime(date.year, 2, 28);
        }
      }else{
        break;
      }
    }
    return date;
  }
  Map<String,dynamic> toMap(){
    return{
      'id': id,
      'name': name,
      'price': price,
      'startDate': startDate.toIso8601String(),
      'period': period,
      'category': category,
    };
  }
  factory Subscription.fromMap(Map<String,dynamic> map){
    return Subscription(id: map['id'], 
    name: map['name'], 
    price: map['price'], 
    startDate: DateTime.parse(map['startDate']), 
    period: map['period'],
    category: map['category']?? 'Other');
  }
}