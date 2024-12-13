import 'package:flutter/material.dart';

class ImagenConTexto extends StatelessWidget {
  final String imageUrl;
  final String texto;
  final double? imageHeight;
  final double? imageWidth;

  const ImagenConTexto({
    Key? key,
    required this.imageUrl,
    required this.texto,
    this.imageHeight,
    this.imageWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220, // Increase the height to ensure both image and text are visible
      child: Column(
        children: [
          Image.network(
            imageUrl,
            height: imageHeight ?? 150, // Set a default height for the image
            width: imageWidth,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}