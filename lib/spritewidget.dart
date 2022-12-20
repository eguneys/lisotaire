library spritewidget;
import 'dart:async';
import 'dart:convert';

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';


class Content {

  Content({ required ui.Image image, required String json })
  :_image = image {
    JsonDecoder decoder = const JsonDecoder();
    Map<dynamic, dynamic> file = decoder.convert(json);

    List<dynamic> sprites = file['sprites'];

    for (var spriteInfo in sprites) {
      String name = spriteInfo['name'];
      List<dynamic> packs = spriteInfo['packs'];
      List<dynamic> tags = spriteInfo['tags'];

      Offset origin = Offset.zero;

      List<Animation> animations = [];

      for (var tag in tags) {
        List<Frame> frames = [];

        for (int i = tag.from; i <= tag.to; i++) {
          var _ = packs[i];
          double duration = _.meta.duration / 1000;
          Rect frameRect = Rect.fromLTWH(_.frame.x, _.frame.y, _.frame.w, _.frame.h);
          Rect packedRect = Rect.fromLTWH(_.packed.x, _.packed.y, _.packed.w, _.packed.h);

          Frame frame = Frame(SpriteTexture._fromFrame(_image, frameRect, packedRect, origin), duration);

          frames.add(frame);
        }

        Animation anim = Animation(tag.name, frames);
        animations.add(anim);
      }

      Sprite sprite = Sprite(name, origin, animations);

      _sprites[name] = sprite;
    }
  }

  final ui.Image _image;

  final _sprites = <String, Sprite>{};
}


class Frame {
  Frame(this.texture, this.duration);
  final SpriteTexture texture;
  final num duration;
}

class Animation {
  Animation(this.name, this.frames);

  final String name;
  final List<Frame> frames;
}

class Sprite {
  final String name;
  final Offset origin;
  final Map<String, Animation> animations;

  Sprite(this.name, this.origin, List<Animation> animationList) :
        animations = {
          for(Animation animation in animationList)
            animation.name: animation
        };
}


class SpriteTexture {
  SpriteTexture(this.image) :
  frame = Rect.fromLTRB(0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
  packed = Rect.fromLTRB(0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
  pivot = const Offset(0.5, 0.5);

  SpriteTexture._fromFrame(this.image, this.frame, this.packed, this.pivot);

  final ui.Image image;
  final Rect frame;
  final Rect packed;
  Offset pivot;


  void drawTexture(Canvas canvas, Offset position, Paint paint) {
    double x = position.dx;
    double y = position.dy;

    Rect srcRect = Rect.fromLTWH(packed.left + frame.left, packed.top + frame.top, packed.width, packed.height);
    Rect dstRect = Rect.fromLTWH(x, y, frame.width, frame.height);
    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

}


class ImageMap {
  ImageMap({ AssetBundle? bundle }): _bundle = bundle ?? rootBundle;


  final AssetBundle _bundle;
  final _images = <String, ui.Image>{};


  Future<List<ui.Image>> load (List<String> urls) {
    return Future.wait(urls.map(loadImage));
  }


  Future<ui.Image> loadImage(String url) async {
    ImageStream stream =
        AssetImage(url, bundle: _bundle).resolve(ImageConfiguration.empty);
    Completer<ui.Image> completer = Completer<ui.Image>();
    late ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo frame, bool synchronousCall) {
      final ui.Image image = frame.image;
      _images[url] = image;
      completer.complete(image);
      stream.removeListener(listener);
    });
    stream.addListener(listener);
    return completer.future;
  }

  ui.Image? getImage(String url) => _images[url];

  ui.Image? operator [](String url) => _images[url];
}