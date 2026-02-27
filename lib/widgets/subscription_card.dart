import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'subscription_icon.dart';
import '../models/subscription.dart';
import 'package:intl/intl.dart';


class SubscriptionCard extends StatefulWidget {
  final Subscription subscription;
  const SubscriptionCard({super.key,required this.subscription});

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  Color backgroundColor = const Color(0xff2c2c2c);
  Color textColor = Colors.white;
  bool isLoadingColor =true;
  @override
  void initState(){
    super.initState();
    updatePalette();
  }
  Future<void> updatePalette() async{
    final String cleanName=widget.subscription.name.trim().toLowerCase().replaceAll(' ', '');
    final String logoUrl = "https://www.google.com/s2/favicons?domain=$cleanName.com&sz=128";
    try {
      final PaletteGenerator generator=await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(logoUrl),
        maximumColorCount: 20,
      );
      final extractedColor = generator.dominantColor?.color ??
    generator.vibrantColor?.color ??
    generator.darkMutedColor?.color ??
    const Color(0xff2c2c2c);
    
      if(extractedColor!=null && mounted){
        setState(() {
          backgroundColor=extractedColor;
          textColor=ThemeData.estimateBrightnessForColor(extractedColor)== Brightness.dark
          ?Colors.white: Colors.black;
          isLoadingColor=false;
        });
      }
    }catch(e){
      if(mounted) {
        setState(() {
        isLoadingColor=false;
      });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final String dateText = DateFormat('d MMM').format(
      widget.subscription.nextBillDate
    );

    final daysLeft= widget.subscription.nextBillDate.difference(DateTime.now()).inDays;
    final String daysLeftText=daysLeft==0? "Today":"$daysLeft days left";
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -30,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: textColor.withOpacity(0.05),
            ),
          ),
          Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              SubscriptionIcon(name: widget.subscription.name, size: 55),
              const SizedBox(width: 16,),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subscription.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "₹${widget.subscription.price} / ${widget.subscription.period}",
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  )
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: textColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "$daysLeft",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        "days",
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 14,
                      ),
                      )
                    ],
                  ),
                ),
            ],
          )
        )
        ],),
      );
  }
}