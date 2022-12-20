import 'package:lisotaire/spritewidget.dart';

class Anim {
  Anim(this.name, this.content);

  SpriteHasAnimation? get sprite => content[name];

  String _animation = 'idle';
  Animation? get animation => sprite?[_animation];

  int _frame_counter = 0;
  int _frame = 0;
  Frame? get frame => animation?.frames[_frame];

  SpriteTexture? get texture => frame?.texture;
  num? get duration => frame?.duration;

  final String name;
  final Content content;
}