import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:game1/circle_rotator.dart';
import 'package:game1/color_switcher.dart';
import 'package:game1/ground.dart';
import 'package:game1/player.dart';
import 'package:game1/star.dart';

final screenSize = Vector2(1280, 720);
final worldSize = Vector2(12.8, 7.2);

class MyGame extends FlameGame
    with TapCallbacks, HasCollisionDetection, HasDecorator, HasTimeScale {
  late Player myPlayer;
  final List<Color> gameColors;
  final ValueNotifier<int> currScore = ValueNotifier(0);
  final ValueNotifier<int> bestScore = ValueNotifier(0);
  final List<PositionComponent> _gameComponents = [];

  MyGame(
      {this.gameColors = const [
        Colors.redAccent,
        Colors.blueAccent,
        Colors.greenAccent,
        Colors.yellowAccent
      ]})
      : super(camera: CameraComponent());

  @override
  Color backgroundColor() => Colors.black;

  @override
  void onLoad() {
    decorator = PaintDecorator.blur(0);
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('background.mp3');
    super.onLoad();
  }

  @override
  void onMount() {
    _initializeGame();
    debugMode = false;
    super.onMount();
  }

  @override
  void update(double dt) {
    final camY = camera.viewfinder.position.y;
    final playerY = myPlayer.position.y;
    if (playerY < camY) camera.viewfinder.position = Vector2(0, playerY);
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    myPlayer.jump();
    super.onTapDown(event);
  }

  void _addGameComponents(PositionComponent component) {
    _gameComponents.add(component);
    world.add(component);
  }

  void generateGameComponents(Vector2 generateFromPosition) {
    _addGameComponents(
        ColorSwitcher(position: generateFromPosition + Vector2(0, 180)));
    _addGameComponents(Circlerotator(
        position: generateFromPosition + Vector2.zero(),
        size: Vector2.all(200)));
    _addGameComponents(Star(position: generateFromPosition + Vector2.zero()));
    _addGameComponents(
        ColorSwitcher(position: generateFromPosition + Vector2(0, -180)));
    _addGameComponents(Circlerotator(
        position: generateFromPosition + Vector2(0, -330),
        size: Vector2.all(150)));
    _addGameComponents(Star(position: generateFromPosition + Vector2(0, -330)));
    _addGameComponents(
        ColorSwitcher(position: generateFromPosition + Vector2(0, -480)));
    _addGameComponents(Circlerotator(
      position: generateFromPosition + Vector2(0, -650),
      size: Vector2(180, 180),
    ));
    _addGameComponents(Circlerotator(
      position: generateFromPosition + Vector2(0, -650),
      size: Vector2(210, 210),
    ));
    _addGameComponents(Star(
      position: generateFromPosition + Vector2(0, -650),
    ));
  }

  void _initializeGame() {
    world.add(Ground(position: Vector2(0, 400)));
    world.add(myPlayer = Player(position: Vector2(0, 300)));
    camera.moveTo(Vector2(0, 0));
    generateGameComponents(Vector2(0, 20));
  }

  void gameOver() {
    for (var element in world.children) {
      element.removeFromParent();
    }
    resetScore();
    _initializeGame();
  }

  bool isGamePaused = false;

  void pauseGame() {
    FlameAudio.bgm.pause();
    (decorator as PaintDecorator).addBlur(10);
    timeScale = 0.0;
    isGamePaused = !isGamePaused;
  }

  void resumeGame() {
    FlameAudio.bgm.resume();
    (decorator as PaintDecorator).addBlur(0.0);
    timeScale = 1.0;
    isGamePaused = !isGamePaused;
  }

  void incrementScore() {
    currScore.value++;
    if (currScore.value > bestScore.value) bestScore.value = currScore.value;
  }

  void resetScore() {
    currScore.value = 0;
  }

  void checkToGenerateNextBatch(Star starComponent) {
    final allStarComponents = _gameComponents.whereType<Star>().toList();
    final length = allStarComponents.length;
    for (int i = 0; i < allStarComponents.length; i++) {
      if (starComponent == allStarComponents[i] && i >= length - 2) {
        // generate the next batch
        final lastStar = allStarComponents.last;
        generateGameComponents(lastStar.position - Vector2(0, 400));
        _tryToGarbageCollect(starComponent);
      }
    }
  }

  void _tryToGarbageCollect(Star starComponent) {
    for (int i = 0; i < _gameComponents.length; i++) {
      if (starComponent == _gameComponents[i] && i >= 15) {
        _removeComponentsFromGame(i - 7);
        break;
      }
    }
  }

  void _removeComponentsFromGame(int n) {
    for (int i = n - 1; i >= 0; i--) {
      _gameComponents[i].removeFromParent();
      _gameComponents.removeAt(i);
    }
  }
}
