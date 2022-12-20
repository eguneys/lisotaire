import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' show pi;
import 'package:vector_math/vector_math_64.dart';

class CoordinateSystem extends SingleChildRenderObjectWidget {
  const CoordinateSystem({
    Key? key,
    required this.systemSize,
    required Widget child,
    }) : super(key: key, child: child);

  final Size systemSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCoordinateSystem(
      systemSize: systemSize
    );
  }

  @override
  void updateRenderObject(
      BuildContext context,
      RenderCoordinateSystem renderObject) {
   renderObject.systemSize = systemSize;
  }
}

class RenderCoordinateSystem extends RenderProxyBox {
  RenderCoordinateSystem({
    required Size systemSize,
    RenderBox? child
}) : super(child) {
    _systemSize = systemSize;
  }

  Size get systemSize => _systemSize;
  late Size _systemSize;
  set systemSize(Size systemSize) {
    if (_systemSize == systemSize) return;
    _systemSize = systemSize;
    markNeedsPaint();
  }

  Matrix4 get _effectiveTransform {
    double scaleX = 1.0;
    double scaleY = 1.0;

    scaleY = size.height / systemSize.height;
    scaleX = scaleY;
    Matrix4 transformMatrix = Matrix4.identity();
    transformMatrix.scale(scaleX, scaleY);
    return transformMatrix;
  }

  @override
  bool hitTest(HitTestResult result, { required Offset position }) {
    Matrix4 inverse = Matrix4.zero();

    inverse.copyInverse(_effectiveTransform);
    Vector3 position3 = Vector3(position.dx, position.dy, 0.0);
    Vector3 transformed3 = inverse.transform3(position3);
    Offset transformed = Offset(transformed3.x, transformed3.y);
    return super.hitTest(result as BoxHitTestResult, position: transformed);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      Matrix4 transform = _effectiveTransform;
      Offset? childOffset = MatrixUtils.getAsTranslation(transform);
      if (childOffset == null) {
        context.pushTransform(needsCompositing, offset, transform, super.paint);
      } else {
        super.paint(context, offset + childOffset);
      }
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    transform.multiply(_effectiveTransform);
    super.applyPaintTransform(child, transform);
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  // Perform layout
  @override
  void performLayout() {
    double xScale = _effectiveTransform[0];
    double yScale = _effectiveTransform[5];

    if (child != null) {
      child!.layout(BoxConstraints.tightFor(
          width: size.width / xScale, height: size.height / yScale));
    }
  }
}