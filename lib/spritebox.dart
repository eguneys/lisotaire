import 'package:flutter/material.dart';

class SpriteBoxEvent {
  final Offset boxPosition;

  final PointerEventType type;

  final int pointer;

  SpriteBoxEvent(this.boxPosition, this.type, this.pointer);
}

enum PointerEventType {
  down,
  move,
  up,
  cancel
}

PointerEventType _eventToEventType(PointerEvent event) {
  if (event is PointerDownEvent) {
    return PointerEventType.down;
  } else if (event is PointerMoveEvent) {
    return PointerEventType.move;
  } else if (event is PointerUpEvent) {
    return PointerEventType.up;
  } else if (event is PointerCancelEvent) {
    return PointerEventType.cancel;
  } else {
    throw Exception('Illegal event type $event');
  }
}