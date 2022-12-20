part of spritewidget;

class SpriteWidget extends SingleChildRenderObjectWidget {
  final NodeWithSize rootNode;

  const SpriteWidget(
      this.rootNode, {
        Key? key
      }): super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) => SpriteBox(
    rootNode: rootNode
  );

  @override
  void updateRenderObject(BuildContext context, SpriteBox renderObject) {
    renderObject
    .rootNode = rootNode;
  }
}

class Sprite extends NodeWithSize with SpritePaint {
  SpriteTexture texture;

  final Paint _cachedPaint = Paint()
  ..filterQuality = FilterQuality.low
  ..isAntiAlias = false;

  Sprite({ required this.texture }): super(Size.zero) {
    size = texture.size;
    pivot = texture.pivot;
  }


  @override
  void paint(Canvas canvas) {
    applyTransformForPivot(canvas);

    double w = texture.size.width;
    double h = texture.size.height;

    if (w <= 0 || h <= 0) return;

    double scaleX = size.width / w;
    double scaleY = size.height / h;

    canvas.scale(scaleX, scaleY);

    _updatePaint(_cachedPaint);

    texture.drawTexture(canvas, Offset.zero, _cachedPaint);
  }
}

class SpriteBox extends RenderBox {
  SpriteBox({
    required NodeWithSize rootNode
}) {
    _rootNode = rootNode;
    _addSpriteBoxReference(_rootNode);
  }

  void _removeSpriteBoxReference(Node node) {
    node._spriteBox = null;
    for (Node child in node._children) {
      _removeSpriteBoxReference(child);
    }
  }

  void _addSpriteBoxReference(Node node) {
    node._spriteBox = this;
    for (Node child in node._children) {
      _addSpriteBoxReference(child);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scheduleTick();
  }

  @override
  void detach() {
    super.detach();
    _unscheduleTick();
  }

  Duration? _lastTimeStamp;
  double _frameRate = 0.0;

  double get frameRate => _frameRate;

  Matrix4? _transformMatrix;

  List<Node>? _eventTargets;

  Rect? get visibleArea {
    if (_visibleArea == null) _calcTransformMatrix();
    return _visibleArea;
  }

  Rect? _visibleArea;

  bool _initialized = false;

  NodeWithSize get rootNode => _rootNode;

  late NodeWithSize _rootNode;

  set rootNode(NodeWithSize value) {
    if (value == _rootNode) return;

    _removeSpriteBoxReference(_rootNode);

    _rootNode = value;

    _addSpriteBoxReference(_rootNode);
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    _invalidateTransformMatrix();
    _initialized = true;
  }

  void _registerNode(Node node) {
    _eventTargets = null;
  }

  void _deregisterNode(Node? node) {
    _eventTargets = null;
  }

  void _addEventTargets([Node? node]) {
    _eventTargets ??= <Node>[];
    node ??= _rootNode;

    List<Node> children = node.children;
    int i = 0;

    while (i < children.length) {
      Node child = children[i];
      if (child.zPosition >= 0.0) break;
      _addEventTargets(child);
      i++;
    }

    if (node.userInteractionEnabled) {
      _eventTargets!.add(node);
    }

    while (i < children.length) {
      Node child = children[i];
      _addEventTargets(child);
      i++;
    }
  }

  @override
  void handleEvent(PointerEvent event, _SpriteBoxHitTestEntry entry) {
    if (!attached) return;
    if (event is PointerDownEvent) {
      _addEventTargets();

      List<Node> nodeTargets = <Node>[];
      for (int i = _eventTargets!.length - 1; i >= 0; i--) {
        Node node = _eventTargets![i];

        if (node._handlingPointer == null) {
          Offset posInNodeSpace =
              node.convertPointToNodeSpace(entry.localPosition);
          if (node.isPointInside(posInNodeSpace)) {
            nodeTargets.add(node);
            node._handlingPointer = event.pointer;
          }
        }
      }
      entry.nodeTargets = nodeTargets;
    }

    List<Node> targets = entry.nodeTargets;
    for (Node node in targets) {
      if (event.pointer == node._handlingPointer) {
        bool consumedEvent = node.handleEvent(
            SpriteBoxEvent(globalToLocal(event.position),
              _eventToEventType(event),
              event.pointer
            ));
        if (consumedEvent) break;
      }
    }

    for (Node node in targets) {
      if (event is PointerUpEvent ||  event is PointerCancelEvent) {
        node._handlingPointer = null;
      }
    }
  }


  @override
  bool hitTest(HitTestResult result, { required Offset position}) {
    result.add(_SpriteBoxHitTestEntry(this, position));
    return true;
  }


  Matrix4 get transformMatrix {
    if (_transformMatrix == null) {
      _calcTransformMatrix();
    }
    return _transformMatrix!;
  }

  void _calcTransformMatrix() {
    _transformMatrix = Matrix4.identity();

    double scaleX = 1.0;
    double scaleY = 1.0;
    double offsetX = 0.0;
    double offsetY = 0.0;

    double systemWidth = rootNode.size.width;
    double systemHeight = rootNode.size.height;

    systemWidth = size.width;
    systemHeight = size.height;

    _visibleArea = Rect.fromLTRB(-offsetX / scaleX, - offsetY / scaleY,
    systemWidth + offsetX / scaleX, systemHeight + offsetY / scaleY);

    _transformMatrix!.translate(offsetX, offsetY);
    _transformMatrix!.scale(scaleX, scaleY);

    _callSpriteBoxPerformedLayout(rootNode);
  }

  void _invalidateTransformMatrix() {
    _visibleArea = null;
    _transformMatrix = null;
    _rootNode._invalidateToBoxTransformMatrix();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
     final Canvas canvas = context.canvas;

     canvas
     ..save()
     ..translate(offset.dx, offset.dy)
     ..transform(transformMatrix.storage);

     _rootNode._visit(canvas);
     canvas.restore();
  }


  late int _frameCallbackId;

  void _scheduleTick() {
    _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_tick);
  }

  void _unscheduleTick() {
    SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId);
  }

  void _tick(Duration timeStamp) {
    if (!attached) return;

    _lastTimeStamp ??= timeStamp;
    double delta = (timeStamp - _lastTimeStamp!).inMicroseconds.toDouble() /
    Duration.microsecondsPerSecond;
    _lastTimeStamp = timeStamp;

    _frameRate = 1.0/delta;

    if (_initialized) {
      _runActions(delta);
      _callUpdate(_rootNode, delta);
    }

    _scheduleTick();

    markNeedsPaint();
  }

  void _runActions(double dt) {

  }

  void _callUpdate(Node node, double dt) {
    node.update(dt);
    for (int i = node.children.length - 1; i >= 0; i--) {
      Node child = node.children[i];
      if (!child.paused) {
        _callUpdate(child, dt);
      }
    }
  }

  void _callSpriteBoxPerformedLayout(Node node) {
    node.spriteBoxPerformedLayout();
    for (Node child in node.children) {
      _callSpriteBoxPerformedLayout(child);
    }
  }

}


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

class _SpriteBoxHitTestEntry extends BoxHitTestEntry {
  List<Node> nodeTargets = [];
  _SpriteBoxHitTestEntry(RenderBox target, Offset localPosition)
  :super(target, localPosition);
}

abstract class SpritePaint {
  double opacity = 1.0;

  Color? colorOverlay;

  BlendMode blendMode = BlendMode.srcOver;

  void _updatePaint(Paint paint) {
    paint.color = Color.fromARGB((255.0 * opacity).toInt(), 255, 255, 255);
    if (colorOverlay != null && colorOverlay!.opacity > 0) {
      paint.colorFilter = ColorFilter.mode(colorOverlay!, BlendMode.srcATop);
    } else {
      paint.colorFilter = null;
    }
    paint.blendMode = blendMode;
  }
}