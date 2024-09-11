import 'package:flutter/material.dart';

class AvatarWithBorder extends StatelessWidget {
    final String imageUrl;
    final double borderWidth;
    final Color borderColor;
    final double radius;

    AvatarWithBorder({
        required this.imageUrl,
        this.borderWidth = 2.0,
        this.borderColor = Colors.blue,
        this.radius = 24.0,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: EdgeInsets.all(borderWidth),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                ),
            ),
            child: CircleAvatar(
                radius: radius,
                backgroundImage: NetworkImage(imageUrl),
            ),
        );
    }
}
