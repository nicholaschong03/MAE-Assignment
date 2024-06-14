// badge_widget.dart
import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool darkMode;

  const BadgeWidget({
    required this.title,
    required this.imageUrl,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 96,
          width: 96,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(48),
          ),
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: darkMode
                    ? Colors.white
                    : Theme.of(context).textTheme.titleMedium?.color,
              ),
        ),
        
      ],
    );
  }
}
