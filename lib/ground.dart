import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Ground extends PositionComponent {
  static const String keyName = "gKey";
  Ground({required super.position})
      : super(
            size: Vector2(100, 100),
            anchor: Anchor.center,
            key: ComponentKey.named(keyName));

  late Sprite fingerSprite;
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    fingerSprite = await Sprite.load('finger.png');
  }

  @override
  void render(Canvas canvas) {
    fingerSprite.render(canvas,
        anchor: Anchor.center,
        size: Vector2(100, 100),
        position: Vector2(size.x / 2, size.y / 2));
  }
}
