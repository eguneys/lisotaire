import 'package:dartsolitaire/dartsolitaire.dart' as soli;
import 'package:flutter/material.dart';
import 'package:lisotaire/card.dart';
import 'package:lisotaire/positioned.dart';

typedef Cards = Map<Offset, soli.Card>;


Cards readSolitaire(soli.Solitaire solitaire) {
  final Cards cards = {};

  const tableuX = 310.0;
  const tableuY = 40.0;
  const tableuW = 180.0;

  double column = tableuX;
  for (soli.Tableu tableu in solitaire.tableus) {
    double row = tableuY;
    for (soli.Card card in tableu.fronts.cards) {
      cards[Offset(column, row)] = card;
    }
    column+= tableuW;
  }

  return cards;
}


class Board extends StatefulWidget {


  const Board({
    super.key,
    required this.size,
    required this.solitaire
  });

  final Size size;
  Size get tileSize => Size(size.width / 1920, size.height / 1080);

  Size get cardSize => Size(tileSize.width * 200, tileSize.height * 200);

  final soli.Solitaire solitaire;

  @override
  State<StatefulWidget> createState() { return _BoardState(); }
}

class _BoardState extends State<Board> {
  Cards cards = {};

  @override
  Widget build(BuildContext context) {
    final board = Stack(
      children: [
        for (final entry in cards.entries)
          PositionedCard(
            tileSize: widget.tileSize,
            size: widget.cardSize,
            coord: entry.key,
            child: CardWidget(card: entry.value, size: widget.cardSize)
          )
      ]
    );

    return AspectRatio(
      aspectRatio: 16/9,
      child: Stack(
        children: [
          board
        ]
      )
    );
  }


  @override
  initState() {
    super.initState();
    cards = readSolitaire(widget.solitaire);
  }



  @override

  void didUpdateWidget(Board oldBoard) {
    super.didUpdateWidget(oldBoard);
    final newCards = readSolitaire(widget.solitaire);

    cards = newCards;
  }
}