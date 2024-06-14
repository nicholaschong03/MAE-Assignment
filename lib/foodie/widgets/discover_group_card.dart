import 'package:flutter/material.dart';
import 'package:jom_eat_project/models/outing_group_model.dart';
import '../widgets/image_display_widget.dart';

class DiscoverGroupCard extends StatelessWidget {
  const DiscoverGroupCard({
    super.key,
    required this.group,
    required this.cardWidth,
    required this.cardHeight,
    required this.cardHorizontalMargin,
    required this.cardBorderRadius,
    required this.imageAspectRatio,
  });

  final OutingGroupModel group;
  final double cardWidth;
  final double cardHeight;
  final double cardHorizontalMargin;
  final double cardBorderRadius;
  final double imageAspectRatio;

  @override
  Widget build(BuildContext context) {
    double imageWidth = cardWidth;
    double imageHeight = imageWidth / imageAspectRatio;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: cardHorizontalMargin),
      width: cardWidth,
      height: cardHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              AspectRatio(
                aspectRatio: imageAspectRatio,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.all(Radius.circular(cardBorderRadius)),
                  child: ImageDisplayWidget(
                    pixelRatio: MediaQuery.of(context).devicePixelRatio,
                    imageUrl: group.image,
                    width: imageWidth,
                    height: imageHeight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            group.restaurant!.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                group.cuisineType,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${group.day} |${group.startTime} - ${group.endTime}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 243, 132, 42),
                ),
          ),
        ],
      ),
    );
  }
}
