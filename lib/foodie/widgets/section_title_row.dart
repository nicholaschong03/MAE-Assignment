import 'package:flutter/material.dart';

class SectionTitleRow extends StatelessWidget {
  final String title;

  const SectionTitleRow({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0, // Replace with your desired padding value
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Container(),
          ),
          // If you want to add more content in the future, you can do so here
        ],
      ),
    );
  }
}
