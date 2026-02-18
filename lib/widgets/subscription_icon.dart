import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
class SubscriptionIcon extends StatelessWidget {
  final String name;
  final double size;

  const SubscriptionIcon({super.key,required this.name,required this.size});
  @override
  Widget build(BuildContext context) {
    final String cleanName= name.trim().toLowerCase().replaceAll(' ', '');
    final logoUrl= "https://logo.clearbit.com/$cleanName.com";

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.network(logoUrl,
        fit: BoxFit.cover,

        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress==null) return child;
          return Container(
            color: Colors.grey.shade100,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2,),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _fallback();
        },
        ),
      ),
    );
  }
  Widget _fallback(){
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColorForName(name),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase():"?",
          style: TextStyle(
            color: Colors.white,
            fontSize: size*0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  Color _getColorForName(String text){
    final colors=[Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pinkAccent];
    return colors[text.hashCode.abs()%colors.length];
  }
}