import 'package:flutter/material.dart';
import 'package:jom_eat_project/foodie/screens/outing_profile_screen.dart';
import 'package:jom_eat_project/models/outing_group_model.dart';
import '../widgets/image_display_widget.dart';

class PopularOutingCard extends StatelessWidget {
  const PopularOutingCard({
    super.key,
    required this.outing,
    required this.cardWidth,
    required this.cardHeight,
  });

  final OutingGroupModel outing;
  final double cardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    const double cardBorderRadius = 16;
    const double horizontalMargin = 8;
    const double verticalMargin = 8;
    double imageHeight = cardHeight - (2 * verticalMargin);
    double imageWidth = imageHeight;
    double postDetailWidth = cardWidth - (2 * horizontalMargin) - imageWidth;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OutingProfileScreen(
              outingId: outing.id,
              userId: outing.createdByUser.id, // Replace with appropriate userId
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: horizontalMargin,
          vertical: verticalMargin,
        ),
        width: cardWidth,
        height: cardHeight,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(cardBorderRadius)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(cardBorderRadius)),
              child: ImageDisplayWidget(
                width: imageWidth,
                height: imageHeight,
                pixelRatio: 1,
                imageUrl: outing.image,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 12, right: 12),
              width: postDetailWidth,
              height: cardHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ImageDisplayWidget(
                          width: 24,
                          height: 24,
                          pixelRatio: 1,
                          imageUrl: outing.createdByUser.profileImage,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        outing.createdByUser.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    outing.description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
