import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lisotaire/content.dart';
import 'package:lisotaire/widgets2.dart';

class AnimatedSprite extends ConsumerStatefulWidget {
  const AnimatedSprite({
    super.key,
    required this.name,
    this.width,
    this.height
  });

  final String name;
  final double? width;
  final double? height;

  @override
  ConsumerState<AnimatedSprite> createState() => _AnimatedSpriteState();
}

class _AnimatedSpriteState extends ConsumerState<AnimatedSprite> with
TickerProviderStateMixin {

  SpriteHasAnimation? _sprite;

  String _animation = 'idle';
  get animation => _sprite?.animations[_animation];

  get frame => animation?.frames[_frame];

  int _frame = 0;
  int _frame_counter = 0;

  get texture => frame?.texture;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    final content = ref.watch(contentDataProvider);
    content.when(
        data: (Content data) {
          _sprite = data[widget.name];
        },
        loading: () {},
        error: (Object error, StackTrace? stackTrace) {
        }
    );

  }

  @override
  Widget build(BuildContext context) {
    return TextureImage(texture: texture, width: widget.width, height: widget.height);
  }
}