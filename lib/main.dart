import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game1/my_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  Flame.device.setPortrait();
  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MyGame _myGame;
  late int bestSaved = 0;
  late SharedPreferences prefs;

  void getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    bestSaved = prefs.getInt('best') ?? 0;
    _myGame.bestScore.value = bestSaved;
  }

  @override
  void initState() {
    _myGame = MyGame();
    getPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      )),
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: _myGame),
            if (!_myGame.isGamePaused)
              Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _myGame.pauseGame();
                            });
                          },
                          icon: const Icon(
                            Icons.pause_circle_outline_rounded,
                            size: 40,
                            color: Colors.white70,
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      ValueListenableBuilder(
                        valueListenable: _myGame.currScore,
                        builder: (context, value, child) => Text(
                          value.toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  )),
            Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: ValueListenableBuilder(
                    valueListenable: _myGame.bestScore,
                    builder: (context, value, child) {
                      if (value > bestSaved) {
                        prefs.setInt("best", value);
                      }
                      return Text(
                        "Best: $value",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                )),
            if (_myGame.isGamePaused)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Paused",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _myGame.resumeGame();
                          });
                        },
                        icon: const Icon(
                          Icons.play_circle_outline_rounded,
                          size: 80,
                          color: Colors.white,
                        ))
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
