
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/widgets.dart';

class TextureImage extends StatelessWidget {
  const TextureImage({
    Key? key,
    required this.texture,
    this.width = 128.0,
    this.height = 128.0,
  }) : super(key: key);

  final SpriteTexture texture;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: TextureImagePainter(texture, width, height),
      ),
    );
  }
}

class TextureImagePainter extends CustomPainter {
  TextureImagePainter(this.texture, this.width, this.height);

  final SpriteTexture texture;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / texture.size.width,
      size.height / texture.size.height,
    );
    texture.drawTexture(canvas, Offset.zero, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(TextureImagePainter oldDelegate) {
    return oldDelegate.texture != texture ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}

class TextureButton extends StatefulWidget {
  const TextureButton(
      {Key? key,
        required this.onPressed,
        required this.texture,
        this.textureDown,
        this.width = 128.0,
        this.height = 128.0,
        this.label,
        this.textStyle,
        this.textAlign = TextAlign.center,
        this.labelOffset = Offset.zero})
      : super(key: key);

  final VoidCallback onPressed;
  final SpriteTexture texture;
  final SpriteTexture? textureDown;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final String? label;
  final double width;
  final double height;
  final Offset labelOffset;

  @override
  TextureButtonState createState() => TextureButtonState();
}

class TextureButtonState extends State<TextureButton> {
  bool _highlight = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: SizedBox(
            width: widget.width,
            height: widget.height,
            child:
            CustomPaint(painter: TextureButtonPainter(widget, _highlight))),
        onTapDown: (_) {
          setState(() {
            _highlight = true;
          });
        },
        onTap: () {
          setState(() {
            _highlight = false;
          });
          widget.onPressed();
        },
        onTapCancel: () {
          setState(() {
            _highlight = false;
          });
        });
  }
}

class TextureButtonPainter extends CustomPainter {
  TextureButtonPainter(this.config, this.highlight);

  final TextureButton config;
  final bool highlight;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (highlight) {
      // Draw down state
      if (config.textureDown != null) {
        canvas.scale(
          size.width / config.textureDown!.size.width,
          size.height / config.textureDown!.size.height,
        );
        config.textureDown!.drawTexture(canvas, Offset.zero, Paint());
      } else {
        canvas.scale(
          size.width / config.texture.size.width,
          size.height / config.texture.size.height,
        );
        config.texture.drawTexture(
          canvas,
          Offset.zero,
          Paint()
            ..colorFilter = const ColorFilter.mode(
              Color(0x66000000),
              BlendMode.srcATop,
            ),
        );
      }
    } else {
      // Draw up state
      canvas.scale(size.width / config.texture.size.width,
          size.height / config.texture.size.height);
      config.texture.drawTexture(canvas, Offset.zero, Paint());
    }
    canvas.restore();

    if (config.label != null) {
      TextStyle style;
      if (config.textStyle == null) {
        style = const TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700);
      } else {
        style = config.textStyle!;
      }

      TextSpan textSpan = TextSpan(style: style, text: config.label);
      TextPainter painter = TextPainter(
        text: textSpan,
        textAlign: config.textAlign,
        textDirection: TextDirection.ltr,
      );

      painter.layout(minWidth: size.width, maxWidth: size.width);
      painter.paint(
          canvas,
          Offset(0.0, size.height / 2.0 - painter.height / 2.0) +
              config.labelOffset);
    }
  }

  @override
  bool shouldRepaint(TextureButtonPainter oldDelegate) {
    return oldDelegate.highlight != highlight ||
        oldDelegate.config.texture != config.texture ||
        oldDelegate.config.textureDown != config.textureDown ||
        oldDelegate.config.textStyle != config.textStyle ||
        oldDelegate.config.label != config.label ||
        oldDelegate.config.width != config.width ||
        oldDelegate.config.height != config.height;
  }
}

class AppFrame extends StatelessWidget {
  const AppFrame({Key? key, required this.child}) : super(key: key);

  final Widget child;

  static const _minRatio = 1.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final ratio = constraints.maxHeight / constraints.maxWidth;

      if (ratio > _minRatio) {
        return child;
      } else {
        final width = constraints.maxHeight / _minRatio;
        final horizontalInset = (constraints.maxWidth - width) / 2;

        return Stack(
          children: [
            Container(
              color: const Color(0xFF222244),
            ),
            Positioned(
              child: ClipRect(
                child: child,
              ),
              top: 0,
              bottom: 0,
              left: horizontalInset,
              right: horizontalInset,
            ),
          ],
        );
      }
    });
  }
}