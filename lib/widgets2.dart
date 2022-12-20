import 'package:flutter/material.dart';
import 'package:lisotaire/spritewidget.dart';

class TextureImage extends StatelessWidget {
  const TextureImage({ Key? key, required this.texture, this.scale = const Size(1, 1)}):
      super(key: key);

  final SpriteTexture texture;
  final Size scale;

  double get width => texture.width * scale.width;
  double get height => texture.height * scale.height;

  @override build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: TextureImagePainter(texture, scale)
      )
    );
  }
}


class TextureImagePainter extends CustomPainter {
  TextureImagePainter(this.texture, this.scale);

  final SpriteTexture texture;
  final Size scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale.width, scale.height);
    texture.drawTexture(canvas, Offset.zero, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(TextureImagePainter oldDelegate) {
    return oldDelegate.texture != texture ||
        oldDelegate.scale != scale;
  }
}