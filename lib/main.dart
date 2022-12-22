import 'package:dartsolitaire/dartsolitaire.dart' as soli;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lisotaire/board.dart';
import 'package:lisotaire/content.dart';
import 'package:flutter/services.dart';

void main() async {

  //debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);


  final container = ProviderContainer();
  await container.read(contentDataProvider.future);

  runApp(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: MyApp()
      )
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
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
                  child: Stack(
                      children: [
                        Board(size: screenSize, solitaire: soli.Solitaire.make)
                      ]
                  ))
            ]
        )
    );
  }
}
