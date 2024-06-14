import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final Color borderColor;

  const ProfilePictureWidget({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 2),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
              )
            : Icon(
                Icons.person,
                size: width,
                color: Colors.grey,
              ),
      ),
    );
  }
}
