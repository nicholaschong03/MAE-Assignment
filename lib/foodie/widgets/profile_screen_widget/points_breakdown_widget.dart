import 'package:flutter/material.dart';

class PointsBreakdownWidget extends StatelessWidget {
  final bool darkMode;
  final int points;
  final int engagementScore;

  const PointsBreakdownWidget(
      {super.key,
      required this.darkMode,
      required this.points,
      required this.engagementScore});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Points Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: darkMode ? Colors.white : null,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _sourceOfPointList(
                  //     point: 275,
                  //     title: 'Profile Activities',
                  //     darkMode: darkMode,
                  //     context: context),
                  // _sourceOfPointList(
                  //     point: 290,
                  //     title: 'Content Creation',
                  //     darkMode: darkMode,
                  //     context: context),
                  _sourceOfPointList(
                      point: engagementScore,
                      title: 'Engagement',
                      darkMode: darkMode,
                      context: context),
                  _sourceOfPointList(
                      point: points,
                      title: 'Outing Participation',
                      darkMode: darkMode,
                      context: context),
                  // _sourceOfPointList(
                  //     point: 45,
                  //     title: 'Special Events',
                  //     darkMode: darkMode,
                  //     context: context),
                ],
              ),
            ),
            Divider(
              color: Colors.white.withOpacity(0.2),
              height: 1.5,
              thickness: 1.5,
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed('/how-to-earn-points'),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'How to earn points',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: darkMode
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: darkMode
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceOfPointList({
    required BuildContext context,
    required int point,
    required String title,
    required bool darkMode,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: darkMode
                          ? Colors.white
                          : Theme.of(context).textTheme.titleMedium?.color,
                    ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                point.toString(),
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: darkMode
                          ? Colors.white
                          : Theme.of(context).textTheme.titleMedium?.color,
                    ),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
