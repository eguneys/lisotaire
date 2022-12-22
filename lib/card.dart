import 'package:dartsolitaire/dartsolitaire.dart' as soli;
import 'package:flutter/material.dart';
import 'package:lisotaire/anim.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.card,
    required this.size
  });


  final soli.Card card;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Stack(
    children: [
    Positioned(
    child: AnimatedSprite(name: 'card', width: size.width)
  )
  ]
  );
  }
}