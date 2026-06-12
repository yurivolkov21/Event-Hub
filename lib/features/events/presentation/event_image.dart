import 'package:flutter/material.dart';

class EventImage extends StatelessWidget {
  const EventImage({required this.imageUrl, this.height = 180, super.key});

  final String? imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final url = imageUrl;

    if (url == null || url.isEmpty) {
      return Container(
        height: height,
        color: colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(Icons.event, size: 40, color: colorScheme.onSurfaceVariant),
      );
    }

    return Image.network(
      url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          color: colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }
}
