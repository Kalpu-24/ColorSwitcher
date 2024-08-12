import 'dart:async';
import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:game1/my_game.dart';

class Circlerotator extends PositionComponent with HasGameRef<MyGame> {
  Circlerotator(
      {required super.position,
      required super.size,
      this.thickness = 8,
      this.rotationSpeed = 2})
      : assert(size!.x == size.y),
        super(anchor: Anchor.center);

  final double thickness;
  final double rotationSpeed;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    const circle = math.pi * 2;
    final sweep = circle / gameRef.gameColors.length;
    for (int i = 0; i < gameRef.gameColors.length; i++) {
      add(CircleArc(
          color: gameRef.gameColors[i],
          startAngle: i * sweep,
          sweepAngle: sweep));
    }

    add(RotateEffect.to(
        math.pi * 2, EffectController(speed: rotationSpeed, infinite: true)));
  }
}

class CircleArc extends PositionComponent with ParentIsA<Circlerotator> {
  final Color color;
  final double startAngle;
  final double sweepAngle;

  CircleArc(
      {required this.color, required this.startAngle, required this.sweepAngle})
      : super(anchor: Anchor.center);

  @override
  void onMount() {
    size = parent.size;
    position = size / 2;
    _addHitBoxes();
    super.onMount();
  }

  void _addHitBoxes() {
    final center = size / 2;
    const precision = 6;
    final segment = sweepAngle / (precision - 1);
    final radius = size.x / 2;
    List<Vector2> vertices = [];
    for (int i = 0; i < precision; i++) {
      final thisSegment = startAngle + segment * i;
      vertices.add(center +
          Vector2(math.cos(thisSegment), math.sin(thisSegment)) * radius);
    }
    for (int i = precision - 1; i > 0; i--) {
      final thisSegment = startAngle + segment * i;
      vertices.add(center +
          Vector2(math.cos(thisSegment), math.sin(thisSegment)) *
              (radius - parent.thickness));
    }
    add(PolygonHitbox(vertices, collisionType: CollisionType.passive));
  }

  @override
  void render(Canvas canvas) {
    canvas.drawArc(
        size.toRect().deflate(parent.thickness / 2),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = parent.thickness);
  }
}
