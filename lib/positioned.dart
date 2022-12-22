import 'package:flutter/material.dart';

class PositionedCard extends StatelessWidget {
  const PositionedCard({
    super.key,
    required this.child,
    required this.size,
    required this.tileSize,
    required this.coord
  });
  
  final Widget child;
  final Size size;
  final Size tileSize;
  final Offset coord;

  @override
  Widget build(BuildContext context) {
    var offset = Offset(coord.dx * tileSize.width, coord.dy * tileSize.height);
    return Positioned(
      width: size.width,
      height: size.height,
      left: offset.dx,
      top: offset.dy,
      child: child,
    );
  }
}