import 'package:flutter/material.dart';

class ImageDisplayWidget extends StatelessWidget {
  const ImageDisplayWidget({
    super.key,
    required this.pixelRatio,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  final double pixelRatio;
  final String? imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    int adjustedWidth = (width * pixelRatio).toInt();
    int adjustedHeight = (height * pixelRatio).toInt();

    return imageUrl != null && imageUrl!.isNotEmpty
        ? Image.network(
            imageUrl!,
            width: width,
            height: height,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildPlaceholder(context);
            },
            errorBuilder: (context, error, stackTrace) =>
                _buildPlaceholder(context),
          )
        : _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      width: width,
      height: height,
      child: Icon(
        Icons.image,
        color: Colors.grey,
        size: width / 2,
      ),
    );
  }
}
