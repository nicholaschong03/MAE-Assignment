import 'package:flutter/material.dart';
import 'package:jom_eat_project/models/promotion_model.dart';
import '../widgets/image_display_widget.dart';

// class PromotionCard extends StatelessWidget {
//   const PromotionCard({super.key, required this.promotion});

//   final PromotionModel promotion;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         leading: Image.network(promotion.image),
//         title: Text(promotion.title),
//         subtitle: Text(promotion.description),
//       ),
//     );
//   }
// }

class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
    required this.promotion,
    required this.cardWidth,
    required this.cardHeight,
    required this.cardHorizontalMargin,
    required this.cardBorderRadius,
    required this.imageAspectRatio,
  });

  final PromotionModel promotion;
  final double cardWidth;
  final double cardHeight;
  final double cardHorizontalMargin;
  final double cardBorderRadius;
  final double imageAspectRatio;

  @override
  Widget build(BuildContext context) {
    double couponWidth = cardWidth;
    double couponHeight = couponWidth / imageAspectRatio;


    return Container(
      margin: EdgeInsets.symmetric(horizontal: cardHorizontalMargin),
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:  ImageDisplayWidget(
                  pixelRatio: 1,
                  imageUrl: promotion.restaurantLogo,
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                promotion.restaurantName, // business.businessName,
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
            promotion.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color.fromARGB(255, 243, 132, 42),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Text(
            'Expires',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            formatDate(promotion.validUntil),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color.fromARGB(255, 243, 132, 42),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

String formatDate(DateTime date){
  return "${date.day}/${date.month}/${date.year}";
}