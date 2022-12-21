part of spritewidget;

class NodeWithSize extends Node {
  Size size;

  late Offset pivot;

  NodeWithSize(this.size) {
    pivot = Offset.zero;
  }

  void applyTransformForPivot(Canvas canvas) {
    if (pivot.dx != 0 || pivot.dy != 0) {
      double pivotInPointsX = size.width * pivot.dx;
      double pivotInPointsY = size.height * pivot.dy;
      canvas.translate(-pivotInPointsX, -pivotInPointsY);
    }
  }


  @override
  bool isPointInside(Offset point) {
    double minX = -size.width * pivot.dx;
    double minY = -size.height * pivot.dy;
    double maxX = minX + size.width;
    double maxY = minY + size.height;
    return (point.dx >= minX &&
        point.dx < maxX &&
        point.dy >= minY &&
        point.dy < maxY);
  }
}


class Node {
  Node();

  Matrix4? _spriteBoxTransformMatrix;
  Node? _parent;

  Offset _position = Offset.zero;
  double _rotation = 0.0;

  Matrix4? _transformMatrix = Matrix4.identity();
  Matrix4? _transformMatrixInverse;
  Matrix4? _transformMatrixNodeToBox;
  Matrix4? _transformMatrixBoxToNode;


  double _scaleX = 1.0;
  double _scaleY = 1.0;

  bool visible = true;

  double _zPosition = 0.0;
  late int _addedOrder;

  int _childrenLastAddedOrder = 0;
  bool _childrenNeedSorting = false;


  bool paused = false;
  bool _userInteractionEnabled = false;

  int? _handlingPointer;

  List<Node> _children = <Node>[];

  Node? get parent => _parent;

  double get rotation => _rotation;

  set rotation(double rotation) {
    _rotation = rotation;
    invalidateTransformMatrix();
  }

  Offset get position => _position;

  set position(Offset position) {
    _position = position;
    invalidateTransformMatrix();
  }


  double get zPosition => _zPosition;

  set zPosition(double zPosition) {
    _zPosition = zPosition;
    if (_parent != null) {
      _parent!._childrenNeedSorting = true;
    }
  }

  double get scale {
    assert(_scaleX == _scaleY);
    return _scaleX;
  }

  set scale(double scale) {
    _scaleX = _scaleY = scale;
    invalidateTransformMatrix();
  }

  double get scaleX => _scaleX;

  set scaleX(double scaleX) {
    _scaleX = scaleX;
    invalidateTransformMatrix();
  }

  double get scaleY => _scaleY;

  set scaleY(double scaleY) {
    _scaleY = scaleY;
    invalidateTransformMatrix();
  }


  List<Node> get children {
    _sortChildren();
    return _children;
  }

  void addChild(Node child) {
    assert(child._parent == null);
    _childrenNeedSorting = true;
    _children.add(child);
    child._parent = this;
    _childrenLastAddedOrder += 1;
    child._addedOrder = _childrenLastAddedOrder;
  }

  void removeChild(Node child) {
    if (_children.remove(child)) {
      child._parent = null;
    }
  }

  void removeFromParent() {
    assert(_parent != null);
    _parent!.removeChild(this);
  }

  void removeAllChildren() {
    for (Node child in _children) {
      child._parent = null;
    }
    _children = <Node>[];
    _childrenNeedSorting = false;
  }

  void _sortChildren() {
    if (_childrenNeedSorting) {
      _children.sort((Node a, Node b) {
        if (a._zPosition == b._zPosition) {
          return a._addedOrder - b._addedOrder;
        } else if (a._zPosition > b._zPosition) {
          return 1;
        } else {
          return -1;
        }
      });
      _childrenNeedSorting = false;
    }
  }


  Matrix4 get transformMatrix {
    _transformMatrix ??= computeTransformMatrix();
    return _transformMatrix!;
  }

  Matrix4 computeTransformMatrix() {
    double cx, sx, cy, sy;

    if (_rotation == 0.0) {
      cx = 1.0;
      sx = 0.0;
      cy = 1.0;
      sy = 0.0;
    } else {
      double radiansX = _rotation;
      double radiansY = _rotation;

      cx = math.cos(radiansX);
      sx = math.sin(radiansX);
      cy = math.cos(radiansY);
      sy = math.sin(radiansY);
    }

    Matrix4 matrix = Matrix4(
      cy * _scaleX,
      sy * _scaleX,
      0.0,
      0.0,
      -sx * _scaleY,
      cx * _scaleY,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      _position.dx,
      _position.dy,
      0.0,
      1.0);

      return matrix;
  }

  void invalidateTransformMatrix() {
    _transformMatrix = null;
    _transformMatrixInverse = null;
    _invalidateToBoxTransformMatrix();
  }

  void _invalidateToBoxTransformMatrix() {
    _transformMatrixNodeToBox = null;
    _transformMatrixBoxToNode = null;

    for (Node child in children) {
      child._invalidateToBoxTransformMatrix();
    }
  }

  Matrix4 _nodeToBoxMatrix() {
    if (_transformMatrixNodeToBox != null) {
      return _transformMatrixNodeToBox!;
    }

    if (_parent == null) {
      assert(_spriteBoxTransformMatrix != null);
      _transformMatrixNodeToBox = _spriteBoxTransformMatrix!.clone()
      ..multiply(transformMatrix);
    } else {
      _transformMatrixNodeToBox = _parent!._nodeToBoxMatrix().clone()
          ..multiply(transformMatrix);
    }
    return _transformMatrixNodeToBox!;
  }

  Matrix4 _boxToNodeMatrix() {
    if (_transformMatrixBoxToNode != null) {
      return _transformMatrixBoxToNode!;
    }

    _transformMatrixBoxToNode = Matrix4.copy(_nodeToBoxMatrix());
    _transformMatrixBoxToNode!.invert();
    return _transformMatrixBoxToNode!;
  }

  Matrix4 get inverseTransformMatrix {
    if (_transformMatrixInverse == null) {
      _transformMatrixInverse = Matrix4.copy(transformMatrix);
      _transformMatrixInverse!.invert();
    }
    return _transformMatrixInverse!;
  }

  Offset convertPointToNodeSpace(Offset boxPoint) {
    Vector4 v = _boxToNodeMatrix()
    .transform(Vector4(boxPoint.dx, boxPoint.dy, 0.0, 1.0));

    return Offset(v[0], v[1]);
  }

  Offset convertPointToBoxSpace(Offset nodePoint) {
    Vector4 v = _nodeToBoxMatrix()
    .transform(Vector4(nodePoint.dx, nodePoint.dy, 0.0, 1.0));
    return Offset(v[0], v[1]);
  }

  Offset convertPointFromNode(Offset point, Node node) {
    Offset boxPoint = node.convertPointToBoxSpace(point);
    Offset localPoint = convertPointToNodeSpace(boxPoint);

    return localPoint;
  }

  bool isPointInside(Offset point) {
    return false;
  }

  void _visit(Canvas canvas) {
    if (!visible) return;
    _prePaint(canvas);
    _visitChildren(canvas);
    _postPaint(canvas);
  }

  @mustCallSuper
  void _prePaint(Canvas canvas) {
    canvas
    ..save()
    ..transform(transformMatrix.storage);
  }

  void paint(Canvas canvas) {}

  void _visitChildren(Canvas canvas) {
    _sortChildren();

    int i = 0;

    while (i < _children.length) {
      Node child = _children[i];
      if (child.zPosition >= 0.0) break;
      child._visit(canvas);
      i++;
    }

    paint(canvas);

    while (i < _children.length) {
      Node child = _children[i];
      child._visit(canvas);
      i++;
    }
  }

  void _postPaint(Canvas canvas) {
    canvas.restore();
  }

  void update(double dt) {}

  void spriteBoxPerformedLayout() {}

  bool get userInteractionEnabled => _userInteractionEnabled;

  set userInteractionEnabled(bool userInteractionEnabled) {
    _userInteractionEnabled = userInteractionEnabled;
  }

  bool handleEvent(SpriteBoxEvent event) {
    return false;
  }
}