import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:game1/circle_rotator.dart';
import 'package:game1/color_switcher.dart';
import 'package:game1/ground.dart';
import 'package:game1/my_game.dart';
import 'package:game1/star.dart';

class Player extends PositionComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  Player({this.playerRadius = 12, required super.position});

  final _velocity = Vector2.zero();
  final _gravity = 980.0;
  final _jumpSpeed = 350.0;

  final double playerRadius;

  // ignore: prefer_final_fields
  Color _color = Colors.white;

  @override
  void onLoad() {
    super.onLoad();
    add(CircleHitbox(
      radius: playerRadius,
      anchor: anchor,
      collisionType: CollisionType.active,
    ));
  }

  @override
  void onMount() {
    size = Vector2.all(playerRadius * 2);
    anchor = Anchor.center;
    super.onMount();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _velocity * dt;
    Ground ground = gameRef.findByKeyName(Ground.keyName)!;
    if ((position.y + size.y / 2) >
        ground.positionOfAnchor(Anchor.topCenter).y) {
      _velocity.setZero();
      position.y = ground.positionOfAnchor(Anchor.topCenter).y - (size.y / 2);
    }
    _velocity.y += _gravity * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(
        (size / 2).toOffset(), playerRadius, Paint()..color = _color);
  }

  void jump() {
    _velocity.y = -_jumpSpeed;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is ColorSwitcher) {
      other.removeFromParent();
      _changeColorRandomly();
    } else if (other is CircleArc) {
      if (_color != other.color) {
        gameRef.gameOver();
      }
    } else if (other is Star) {
      other.showCollectEffect();
      gameRef.incrementScore();
      gameRef.checkToGenerateNextBatch(other);
    }
  }

  void _changeColorRandomly() {
    _color = gameRef.gameColors.random();
  }
}
