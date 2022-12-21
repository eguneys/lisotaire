import 'package:flutter/material.dart';
import 'package:lisotaire/anim.dart';
import 'package:lisotaire/spritewidget.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() async {

  //debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);


  runApp(MaterialApp(
    home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => ContentData()
          )
        ],
        child: const MyApp()
    )));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final contentData = context.read<ContentData>();
    return  FutureBuilder<Content>(
            future: ContentData.data,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                contentData.setContent(snapshot.data!);
                return const MyHomePage();
              } else {
                return const Text('loading');
              }
            }
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
              const Expanded(
                child: AnimatedSprite(name: 'card')
              )
            ]
        )
    );
  }
}
