import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String? backgroundImage;

  const AppBackground({
    super.key,
    required this.child,
    this.backgroundImage = "assets/images/bg1.jpg",
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Container(
          decoration: BoxDecoration(
            image: backgroundImage != null
                ? DecorationImage(
                    image: AssetImage(backgroundImage!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: backgroundImage == null ? Colors.blue : null,
          ),
        ),
        // Dark Overlay
        Container(
          color: Colors.black.withOpacity(0.3),
        ),
        // Content
        child,
      ],
    );
  }
}
