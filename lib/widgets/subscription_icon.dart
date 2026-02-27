import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
class SubscriptionIcon extends StatelessWidget {
  final String name;
  final double size;

  const SubscriptionIcon({super.key,required this.name,required this.size});
  @override
  Widget build(BuildContext context) {
    final String cleanName= name.trim().toLowerCase().replaceAll(' ', '');
    final logoUrl= "https://www.google.com/s2/favicons?domain=${cleanName}.com&sz=128";

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
    final color=Colors.grey.shade500;
    return color;
  }
}