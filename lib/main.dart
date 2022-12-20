import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lisotaire/spritewidget.dart';
import 'package:lisotaire/widgets.dart';

late ImageMap  _imageMap;
late SpriteSheet _spriteSheetUI;

void main() async {

  _imageMap = ImageMap();
  String json = await rootBundle.loadString('assets/game_ui.json');
  _spriteSheetUI = SpriteSheet(
    image: _imageMap['assets/game_ui.png']!,
    json
  );

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
        appBarTheme: AppBarTheme(color: Colors.white30)
      ),
      home: const MyHomePage(title: 'lisotaire'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextureButton(
              texture: _spriteSheetUI['btn_powerup_0.png']!,
              width: 60.0,
              height: 60.0,
              label: 'hello',
              onPressed: () => {}
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
