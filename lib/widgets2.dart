import 'package:flutter/material.dart';
import 'package:lisotaire/content.dart';

class TextureImage extends StatelessWidget {
  const TextureImage({
    Key? key,
    required this.texture,
    double? width,
    double? height
  }): _width = width, _height = height, super(key: key);

  final SpriteTexture texture;
  final double? _width;
  final double? _height;

  Size get textureSize => Size(texture.width, texture.height);
  double get aspectRatio => textureSize.aspectRatio;

  Size get size {
    if (_width == null) {
      if (_height == null) {
        return textureSize;
      } else {
        return Size(_height! * aspectRatio, _height!);
      }
    } else {
      return Size(_width!, _width! / aspectRatio);
    }
  }

  double get scaleX => size.width / textureSize.width;
  double get scaleY => size.height / textureSize.height;

  double get width => size.width;
  double get height => size.height;

  @override build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: TextureImagePainter(texture, scaleX, scaleY)
      )
    );
  }
}


class TextureImagePainter extends CustomPainter {
  TextureImagePainter(this.texture, this.scaleX, this.scaleY);

  final SpriteTexture texture;
  final double scaleX;
  final double scaleY;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scaleX, scaleY);
    texture.drawTexture(canvas, Offset.zero, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(TextureImagePainter oldDelegate) {
    return oldDelegate.texture != texture;
  }
}