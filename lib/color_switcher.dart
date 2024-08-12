import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:game1/my_game.dart';

class ColorSwitcher extends PositionComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  ColorSwitcher({
    required super.position,
    this.radius = 8,
  }) : super(anchor: Anchor.center, size: Vector2.all(radius * 2));

  final double radius;

  @override
  void onLoad() {
    super.onLoad();
    add(CircleHitbox(
        position: size / 2,
        radius: radius,
        anchor: anchor,
        collisionType: CollisionType.passive));
  }

  @override
  void render(Canvas canvas) {
    final len = gameRef.gameColors.length;
    final sweep = (math.pi * 2) / len;
    for (int i = 0; i < len; i++) {
      canvas.drawArc(size.toRect(), i * sweep, sweep, true,
          Paint()..color = gameRef.gameColors[i]);
    }
  }
}
