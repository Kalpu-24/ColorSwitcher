import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

late Sprite _sprite;

class Star extends PositionComponent with CollisionCallbacks {
  Star({required super.position})
      : super(anchor: Anchor.center, size: Vector2.all(28));

  @override
  Future onLoad() async {
    await super.onLoad();
    _sprite = await Sprite.load("star.png");
    add(RectangleHitbox(
        position: size / 2,
        anchor: anchor,
        size: size,
        collisionType: CollisionType.passive));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _sprite.render(canvas, position: size / 2, size: size, anchor: anchor);
  }

  void showCollectEffect() {
    final rnd = Random();
    Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 80;
    FlameAudio.play('collect.wav');
    parent!.add(ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
            count: 30,
            lifespan: 1,
            generator: (i) {
              return AcceleratedParticle(
                  speed: randomVector2(),
                  acceleration: randomVector2(),
                  child: RotatingParticle(
                      to: rnd.nextDouble() * pi * 2,
                      child: ComputedParticle(
                        renderer: (c, particle) {
                          _sprite.render(c,
                              size: (size / 2) * (1 - particle.progress),
                              anchor: Anchor.center,
                              overridePaint: Paint()
                                ..color = Colors.white
                                    .withOpacity(1 - particle.progress));
                        },
                      )));
            })));
    removeFromParent();
  }
}
