import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double progressPercentage;

  const ProgressIndicatorWidget({super.key, required this.progressPercentage});

  @override
  Widget build(BuildContext context) {
    const double progressIndicatorMargin = 32;
    double progressIndicatorWidth = MediaQuery.of(context).size.width - (2 * progressIndicatorMargin);
    const double progressIndicatorHeight = 16;
    const double progressIndicatorBorderWidth = 2;
    const double progressIndicatorBorderRadius = 24;

    double innerProgressIndicatorWidth = (progressIndicatorWidth - (2 * progressIndicatorBorderWidth)) * progressPercentage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: progressIndicatorMargin),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: progressIndicatorHeight,
            width: progressIndicatorWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(progressIndicatorBorderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(
            height: progressIndicatorHeight - (2 * progressIndicatorBorderWidth),
            width: innerProgressIndicatorWidth,
            margin: const EdgeInsets.all(progressIndicatorBorderWidth),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(progressIndicatorBorderRadius),
            ),
          ),
        ],
      ),
    );
  }
}
