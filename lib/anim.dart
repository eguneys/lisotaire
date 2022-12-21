import 'package:flutter/material.dart';
import 'package:lisotaire/spritewidget.dart';
import 'package:lisotaire/widgets2.dart';
import 'package:provider/provider.dart';

class AnimatedSprite extends StatefulWidget {
  const AnimatedSprite({
    super.key,
    required this.name
  });

  final String name;

  @override
  State<AnimatedSprite> createState() =>
      _AnimatedSpriteState();
}

class _AnimatedSpriteState extends State<AnimatedSprite> with
TickerProviderStateMixin {

  late final SpriteHasAnimation? _sprite;

  String _animation = 'idle';
  get animation => _sprite?.animations[_animation];

  get frame => animation?.frames[_frame];

  int _frame = 0;
  int _frame_counter = 0;

  get texture => frame?.texture;

  @override
  initState() {
    super.initState();
    _sprite = context.read<ContentData>().content[widget.name];

  }

  @override
  Widget build(BuildContext context) {
    return TextureImage(texture: texture);
  }
}