import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lisotaire/anim.dart';

import 'package:lisotaire/spritewidget.dart';
import 'package:lisotaire/widgets2.dart';
import 'package:lisotaire/coordinates.dart';

late Content _content;
late Anim _anim;

class Card extends NodeWithSize {
  Card(): super(const Size(320, 180)) {
    userInteractionEnabled = true;
    _sprite = Sprite(texture: _anim.texture!);

    addChild(_sprite);
    this.position = Offset(100, 100);
  }

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerEventType.down) {
      _sprite.opacity = 0.5;
      this.position = Offset(150, 150);
      return true;
    } else if (event.type == PointerEventType.move) {
      this.position = event.boxPosition;
    }
    return false;
  }

  late Sprite _sprite;
}

void main() async {

  //debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  String json = await rootBundle.loadString('assets/out_0.json');

  ImageMap imageMap = ImageMap();

  await imageMap.load(<String>[
    'assets/out_0.png'
  ]);

  _content = Content(
    image: imageMap['assets/out_0.png']!,
    json: json
  );

  _anim = Anim('card', _content);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lisotaire',
      theme: ThemeData(
        canvasColor: Colors.white54,
        appBarTheme: const AppBarTheme(color: Colors.white30)
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
            children: <Widget>[
              FloatingActionButton(
                onPressed: () => {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)
                ),
                elevation: 1,
                backgroundColor: Colors.blueGrey,
                child: const Icon(Icons.menu),
              ),
              Expanded(
                child: CoordinateSystem(
                  systemSize: const Size(1920.0, 1080.0),
                  child: SpriteWidget(Card())
                )
              )
            ]
        )
    );
  }
}
