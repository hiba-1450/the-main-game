// ignore_for_file: unused_element, deprecated_member_use, camel_case_types, avoid_print

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:ordered_set/read_only_ordered_set.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> markLevelAsCompleted(String levelId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('level_$levelId', true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyMenuPage(),
    );
  }
}

class MyMenuPage extends StatefulWidget {
  const MyMenuPage({super.key});
  @override
  State<MyMenuPage> createState() => _MyMenuPageState();
}

class _MyMenuPageState extends State<MyMenuPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  @override
  void initState() {
    super.initState();
    // Force landscape for Escape game only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 5, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Reset to allow all orientations when leaving Escape game
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/main.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.only(top: constraints.maxHeight * 0.4),
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LevelsPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth * 0.1,
                            vertical: constraints.maxHeight * 0.05,
                          ),
                          backgroundColor: Colors.black.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side:
                                const BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                        child: Text(
                          'PLAY',
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.9),
                                blurRadius: _glowAnimation.value,
                              ),
                              Shadow(
                                color: Colors.white.withOpacity(0.7),
                                blurRadius: _glowAnimation.value / 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LevelsPage extends StatefulWidget {
  const LevelsPage({super.key});

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  List<bool> levelCompletionStatus = List.filled(6, false); // Assuming 6 levels
  Future<bool> isLevelCompleted(String levelId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('level_$levelId') ?? false;
  }

  @override
  void initState() {
    super.initState();
    _loadCompletionStatus();
  }

  Future<void> _loadCompletionStatus() async {
    List<bool> status = [];
    for (int i = 1; i <= 6; i++) {
      bool completed = await isLevelCompleted(i.toString());
      status.add(completed);
    }
    setState(() {
      levelCompletionStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final List<Map<String, double>> buttonPositions = [
            {'left': 0.125, 'top': 0.55},
            {'left': 0.3, 'top': 0.68},
            {'left': 0.4375, 'top': 0.52},
            {'left': 0.625, 'top': 0.65},
            {'left': 0.7125, 'top': 0.52},
            {'left': 0.825, 'top': 0.72},
          ];

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/levels.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              for (int i = 0; i < buttonPositions.length; i++)
                Positioned(
                  left: width * buttonPositions[i]['left']!,
                  top: height * buttonPositions[i]['top']!,
                  child: GestureDetector(
                    onTap: () {
                      if (i == 0 || levelCompletionStatus[i - 1]) {
                        // Level 1 always open, others require previous to be complete
                        if (i == 0) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LevelOneScreen()));
                        } else if (i == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LevelTwoScreen()),
                          );
                        } else if (i == 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LevelThreeScreen()),
                          );
                        } else if (i == 3) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LevelFourScreen()),
                          );
                        } else if (i == 4) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LevelFiveScreen()),
                          );
                        } else if (i == 5) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LevelSixScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Level ${i + 1} is not implemented yet.')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Level ${i + 1} is locked.')),
                        );
                      }
                    },
                    child: Container(
                      width: width * 0.08,
                      height: height * 0.15,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: levelCompletionStatus[i]
                              ? Colors.greenAccent
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Level ${i + 1}',
                          style: TextStyle(
                            color: levelCompletionStatus[i]
                                ? Colors.greenAccent
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class LevelOneScreen extends StatefulWidget {
  const LevelOneScreen({super.key});

  @override
  State<LevelOneScreen> createState() => _LevelOneScreenState();
}

class _LevelOneScreenState extends State<LevelOneScreen> {
  final CharacterDisplayGame game = CharacterDisplayGame();

  @override
  void initState() {
    super.initState();
    game.onLevelComplete = () {
      setState(() {}); // To show the win overlay
    };
    game.onPlayerDied = () {
      setState(() {}); // Show lose overlay
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),

          // 🔴 Lose overlay
          if (game.showLoseOverlay)
            GestureDetector(
              onTap: () {
                setState(() {
                  game.overlays.clear();
                  game.restart();
                });
              },
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const Text(
                  'You Died! Tap to Retry',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),

          // 🟢 Win overlay
          if (game.showWinOverlay)
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Back to level selection
              },
              child: Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: const Text(
                  'Level Complete!\nTap to Continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, color: Colors.greenAccent),
                ),
              ),
            ),

          // Control Buttons (same as before)
          Positioned(
            left: 20,
            bottom: 30,
            child: Row(
              children: [
                GestureDetector(
                  onTapDown: (_) => game.moveLeft = true,
                  onTapUp: (_) => game.moveLeft = false,
                  onTapCancel: () => game.moveLeft = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_left,
                        color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTapDown: (_) => game.moveRight = true,
                  onTapUp: (_) => game.moveRight = false,
                  onTapCancel: () => game.moveRight = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_right,
                        color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),

          // Jump Button
          Positioned(
            right: 20,
            bottom: 30,
            child: GestureDetector(
              onTapDown: (_) => game.isJumping = true,
              onTapUp: (_) => game.isJumping = false,
              onTapCancel: () => game.isJumping = false,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward,
                    color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterDisplayGame extends FlameGame {
  late SpriteAnimationComponent character;
  late SpriteAnimationComponent spikeTrap;
  late SpriteAnimation doorAnimation;

  late SpriteComponent door;
  bool moveLeft = false;
  bool moveRight = false;
  bool isJumping = false;
  bool isDead = false;
  bool facingRight = true;
  double moveSpeed = 200;

  double verticalSpeed = 0.0;
  final double gravity = 500;
  final double jumpForce = -500;
  bool isOnGround = true;
  bool doorTriggered = false;
  bool trapVisible = false;
  bool doorOpened = false;
  bool levelComplete = false;
  bool showLoseOverlay = false;
  bool showWinOverlay = false;

  Function()?
      onLevelComplete; // <-- Add this to call back to Flutter when level completes
  Function()? onPlayerDied;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await images.loadAll([
      'background.png',
      'Character.png',
      'doors.png',
      'long_metal_spike_01.png',
      'long_metal_spike_02.png',
      'long_metal_spike_03.png',
    ]);

    // Background
    add(SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size
      ..position = Vector2.zero());

    // Character animation
    final image = images.fromCache('Character.png');
    final frameSize = Vector2(32, 32);

// Walking animation frames
    final walkFrames = [
      Sprite(image, srcPosition: Vector2(0, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(32, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(64, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(96, 96), srcSize: frameSize),
    ];

    final walkAnimation =
        SpriteAnimation.spriteList(walkFrames, stepTime: 0.15, loop: true);
    character = SpriteAnimationComponent()
      ..animation = walkAnimation
      ..size = Vector2(size.x * 0.06, size.x * 0.06)
      ..position = Vector2(size.x * 0.05, size.y * 0.65);
    add(character);

    // Spike trap animation
    spikeTrap = SpriteAnimationComponent()
      ..animation = SpriteAnimation.spriteList([
        Sprite(images.fromCache('long_metal_spike_01.png')),
        Sprite(images.fromCache('long_metal_spike_02.png')),
        Sprite(images.fromCache('long_metal_spike_03.png')),
      ], stepTime: 0.2, loop: true)
      ..size = Vector2(size.x * 0.05, size.x * 0.05)
      ..position = Vector2(size.x * 0.76, size.y * 0.65)
      ..opacity = 0;
    add(spikeTrap);

    // Door animation setup
    final doorSheet = images.fromCache('doors.png');
    final frameHeight = doorSheet.height / 10;
    door = SpriteComponent()
      ..sprite = Sprite(
        doorSheet,
        srcPosition: Vector2(0, 0),
        srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
      )
      ..size = Vector2(
          size.x * 0.15, (size.x * 0.15) * (frameHeight / doorSheet.width))
      ..position = Vector2(size.x * 0.78, size.y * 0.6);
    add(door);

    doorAnimation = SpriteAnimation.spriteList(
      List.generate(10, (i) {
        return Sprite(
          doorSheet,
          srcPosition: Vector2(0, i * frameHeight),
          srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
        );
      }),
      stepTime: 0.1,
      loop: false,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead || levelComplete) return;

    // Movement
    if (moveLeft) {
      character.position.x -= moveSpeed * dt;
      if (facingRight) {
        character.flipHorizontally();
        facingRight = false;
      }
    }
    if (moveRight) {
      character.position.x += moveSpeed * dt;
      if (!facingRight) {
        character.flipHorizontally();
        facingRight = true;
      }
    }

    // Jumping
    if (isJumping && isOnGround) {
      verticalSpeed = jumpForce;
      isOnGround = false;
    }

    verticalSpeed += gravity * dt;
    character.position.y += verticalSpeed * dt;

    final groundY = size.y * 0.65;
    if (character.position.y >= groundY) {
      character.position.y = groundY;
      verticalSpeed = 0;
      isOnGround = true;
    }

    // Stay on screen
    character.position.x =
        character.position.x.clamp(0, size.x - character.size.x);

    // Trigger trap
    if (!doorTriggered &&
        character.position.x >= door.position.x - character.size.x * 1.2) {
      doorTriggered = true;
      door.add(MoveEffect.by(
          Vector2(size.x * 0.05, 0), EffectController(duration: 0.3)));
      spikeTrap.add(OpacityEffect.to(1.0, EffectController(duration: 0.4)));
      trapVisible = true;
    }

    // Check trap collision
    if (trapVisible) {
      final characterBox = Rect.fromLTWH(
        character.position.x + character.size.x * 0.2,
        character.position.y + character.size.y * 0.2,
        character.size.x * 0.6,
        character.size.y * 0.6,
      );
      final trapBox = Rect.fromLTWH(
        spikeTrap.position.x + spikeTrap.size.x * 0.1,
        spikeTrap.position.y + spikeTrap.size.y * 0.1,
        spikeTrap.size.x * 0.8,
        spikeTrap.size.y * 0.8,
      );
      if (characterBox.overlaps(trapBox)) {
        die();
      }
    }

    // Reaching door
    if (!doorOpened &&
        character.position.x >= door.position.x - character.size.x * 0.3 &&
        isOnGround &&
        trapVisible &&
        !isDead) {
      openDoor();
    }
  }

  void die() {
    if (!isDead) {
      isDead = true;
      showLoseOverlay = true;
      character.add(
        OpacityEffect.to(
            0, EffectController(duration: 1.2, curve: Curves.easeOut)),
      );
      onPlayerDied?.call(); // <--- Notify the Flutter side
    }
  }

  Future<void> openDoor() async {
    doorOpened = true;

    final animatedDoor = SpriteAnimationComponent()
      ..animation = doorAnimation
      ..size = door.size
      ..position = door.position.clone();

    remove(door);
    add(animatedDoor);

    await Future.delayed(const Duration(milliseconds: 1200));

    // Move character into the door
    character.add(MoveEffect.by(
        Vector2(size.x * 0.1, 0), EffectController(duration: 1.0)));

    // Set level as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_1', true);

    await Future.delayed(const Duration(milliseconds: 1000));

    levelComplete = true;
    showWinOverlay = true;
    onLevelComplete?.call(); // Notify Flutter side
  }

  void restart() {
    overlays.clear();
    children.clear();
    isDead = false;
    levelComplete = false;
    showLoseOverlay = false;
    showWinOverlay = false;
    doorOpened = false;
    doorTriggered = false;
    trapVisible = false;

    onLoad(); // Reload everything
  }
}

extension on ReadOnlyOrderedSet<Component> {
  void clear() {}
}

class LevelTwoScreen extends StatefulWidget {
  const LevelTwoScreen({super.key});

  @override
  State<LevelTwoScreen> createState() => _LevelTwoScreenState();
}

class _LevelTwoScreenState extends State<LevelTwoScreen> {
  final LevelTwo game = LevelTwo();

  @override
  void initState() {
    super.initState();
    game.onLevelComplete = () {
      setState(() {}); // To show the win overlay
    };
    game.onPlayerDied = () {
      setState(() {}); // Show lose overlay
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),

          // 🔴 Lose overlay
          if (game.showLoseOverlay)
            GestureDetector(
              onTap: () {
                setState(() {
                  game.overlays.clear();
                  game.restart();
                });
              },
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const Text(
                  'You Died! Tap to Retry',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),

          // 🟢 Win overlay
          if (game.showWinOverlay)
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Back to level selection
              },
              child: Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: const Text(
                  'Level Complete!\nTap to Continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, color: Colors.greenAccent),
                ),
              ),
            ),

          // Control Buttons (same as before)
          Positioned(
            left: 20,
            bottom: 30,
            child: Row(
              children: [
                GestureDetector(
                  onTapDown: (_) => game.moveLeft = true,
                  onTapUp: (_) => game.moveLeft = false,
                  onTapCancel: () => game.moveLeft = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_left,
                        color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTapDown: (_) => game.moveRight = true,
                  onTapUp: (_) => game.moveRight = false,
                  onTapCancel: () => game.moveRight = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_right,
                        color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),

          // Jump Button
          Positioned(
            right: 20,
            bottom: 30,
            child: GestureDetector(
              onTapDown: (_) => game.isJumping = true,
              onTapUp: (_) => game.isJumping = false,
              onTapCancel: () => game.isJumping = false,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward,
                    color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LevelTwo extends FlameGame {
  late SpriteAnimationComponent character;
  late SpriteComponent trap1;
  late SpriteComponent trap2;
  late SpriteComponent trap3;
  late SpriteComponent door;
  late SpriteAnimation doorAnimation;

  bool moveLeft = false;
  bool moveRight = false;
  bool isJumping = false;
  bool isDead = false;
  bool facingRight = true;
  double moveSpeed = 200;

  double verticalSpeed = 0.0;
  final double gravity = 500;
  final double jumpForce = -500;
  bool isOnGround = true;
  bool doorOpened = false;
  bool levelComplete = false;
  bool showLoseOverlay = false;
  bool showWinOverlay = false;

  // Original positions for traps 2 and 3 to return to
  late Vector2 trap2OriginalPos;
  late Vector2 trap3OriginalPos;

  final double trapMoveDistance = 40.0; // pixels traps 2 & 3 move

  Function()? onLevelComplete;
  Function()? onPlayerDied;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await images.loadAll([
      'background.png',
      'Character.png',
      'doors.png',
      'long_metal_spike_03.png',
    ]);

    // Background
    add(SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size
      ..position = Vector2.zero());

    // Character animation setup
    final image = images.fromCache('Character.png');
    final frameSize = Vector2(32, 32);

    final walkFrames = [
      Sprite(image, srcPosition: Vector2(0, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(32, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(64, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(96, 96), srcSize: frameSize),
    ];
    final walkAnimation =
        SpriteAnimation.spriteList(walkFrames, stepTime: 0.15, loop: true);
    character = SpriteAnimationComponent()
      ..animation = walkAnimation
      ..size = Vector2(size.x * 0.06, size.x * 0.06)
      ..position = Vector2(size.x * 0.05, size.y * 0.65);
    add(character);

    // Traps setup
    final trapSprite = await loadSprite('long_metal_spike_03.png');
    final trapSize = Vector2(size.x * 0.05, size.x * 0.05);
    final trapY = size.y * 0.65;

    trap1 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = Vector2(size.x * 0.25, trapY); // Static trap
    add(trap1);

    trap2OriginalPos = Vector2(size.x * 0.45, trapY);
    trap2 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = trap2OriginalPos.clone();
    add(trap2);

    trap3OriginalPos = Vector2(size.x * 0.65, trapY);
    trap3 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = trap3OriginalPos.clone();
    add(trap3);

    // Door setup
    final doorSheet = images.fromCache('doors.png');
    final frameHeight = doorSheet.height / 10;
    door = SpriteComponent()
      ..sprite = Sprite(
        doorSheet,
        srcPosition: Vector2(0, 0),
        srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
      )
      ..size = Vector2(
          size.x * 0.15, (size.x * 0.15) * (frameHeight / doorSheet.width))
      ..position = Vector2(size.x * 0.78, size.y * 0.6);
    add(door);

    doorAnimation = SpriteAnimation.spriteList(
      List.generate(10, (i) {
        return Sprite(
          doorSheet,
          srcPosition: Vector2(0, i * frameHeight),
          srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
        );
      }),
      stepTime: 0.1,
      loop: false,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead || levelComplete) return;

    // Movement
    if (moveLeft) {
      character.position.x -= moveSpeed * dt;
      if (facingRight) {
        character.flipHorizontally();
        facingRight = false;
      }
    }
    if (moveRight) {
      character.position.x += moveSpeed * dt;
      if (!facingRight) {
        character.flipHorizontally();
        facingRight = true;
      }
    }

    // Jumping
    if (isJumping && isOnGround) {
      verticalSpeed = jumpForce;
      isOnGround = false;
    }

    verticalSpeed += gravity * dt;
    character.position.y += verticalSpeed * dt;

    final groundY = size.y * 0.65;
    if (character.position.y >= groundY) {
      character.position.y = groundY;
      verticalSpeed = 0;
      isOnGround = true;
    }

    // Clamp character on screen
    character.position.x =
        character.position.x.clamp(0, size.x - character.size.x);

    // Trap 2 moves left if near player, else back
    if ((character.position.x - trap2.position.x).abs() < 80) {
      final targetX = trap2OriginalPos.x - trapMoveDistance;
      trap2.position.x = (trap2.position.x - moveSpeed * dt)
          .clamp(targetX, trap2OriginalPos.x);
    } else {
      trap2.position.x = (trap2.position.x + moveSpeed * dt)
          .clamp(trap2OriginalPos.x - trapMoveDistance, trap2OriginalPos.x);
    }

    // Trap 3 moves right if near player, else back
    if ((character.position.x - trap3.position.x).abs() < 80) {
      final targetX = trap3OriginalPos.x + trapMoveDistance;
      trap3.position.x = (trap3.position.x + moveSpeed * dt)
          .clamp(trap3OriginalPos.x, targetX);
    } else {
      trap3.position.x = (trap3.position.x - moveSpeed * dt)
          .clamp(trap3OriginalPos.x, trap3OriginalPos.x + trapMoveDistance);
    }

    // Check collision with all traps
    final characterBox = Rect.fromLTWH(
      character.position.x + character.size.x * 0.2,
      character.position.y + character.size.y * 0.2,
      character.size.x * 0.6,
      character.size.y * 0.6,
    );

    for (final trap in [trap1, trap2, trap3]) {
      final trapBox = Rect.fromLTWH(
        trap.position.x + trap.size.x * 0.1,
        trap.position.y + trap.size.y * 0.1,
        trap.size.x * 0.8,
        trap.size.y * 0.8,
      );
      if (characterBox.overlaps(trapBox)) {
        die();
        break;
      }
    }

    // Door open logic: player near door, on ground, and not dead
    if (!doorOpened &&
        character.position.x >= door.position.x - character.size.x * 0.3 &&
        isOnGround &&
        !isDead) {
      openDoor();
    }
  }

  void die() {
    if (!isDead) {
      isDead = true;
      showLoseOverlay = true;
      character.add(
        OpacityEffect.to(
            0, EffectController(duration: 1.2, curve: Curves.easeOut)),
      );
      onPlayerDied?.call();
    }
  }

  // Move character into door
  Future<void> openDoor() async {
    if (doorOpened) return;
    doorOpened = true;

    // Replace static door with animated door
    final animatedDoor = SpriteAnimationComponent()
      ..animation = doorAnimation
      ..size = door.size
      ..position = door.position.clone();

    remove(door);
    add(animatedDoor);

    // Wait for door to finish opening (shorter delay)
    await Future.delayed(const Duration(milliseconds: 800));

    // Start fade first, move second (faster fade)
    character.addAll([
      OpacityEffect.to(
        0,
        EffectController(duration: 0.7, curve: Curves.easeIn),
      ),
      MoveEffect.by(
        Vector2(size.x * 0.1, 0),
        EffectController(duration: 1.0, curve: Curves.linear),
      ),
    ]);

    // Wait until both effects complete
    await Future.delayed(const Duration(milliseconds: 1000));

    // Mark level as complete
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_2', true);

    levelComplete = true;
    showWinOverlay = true;
    onLevelComplete?.call();
  }

  void restart() {
    overlays.clear();
    children.clear();
    isDead = false;
    levelComplete = false;
    showLoseOverlay = false;
    showWinOverlay = false;
    doorOpened = false;

    onLoad();
  }
}

class LevelThreeScreen extends StatefulWidget {
  const LevelThreeScreen({super.key});

  @override
  State<LevelThreeScreen> createState() => _LevelThreeScreenState();
}

class _LevelThreeScreenState extends State<LevelThreeScreen> {
  final levelThree game = levelThree();

  @override
  void initState() {
    super.initState();
    game.onLevelComplete = () {
      setState(() {}); // To show the win overlay
    };
    game.onPlayerDied = () {
      setState(() {}); // Show lose overlay
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),

          // 🔴 Lose overlay
          if (game.showLoseOverlay)
            GestureDetector(
              onTap: () {
                setState(() {
                  game.overlays.clear();
                  game.restart();
                });
              },
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const Text(
                  'You Died! Tap to Retry',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),

          // 🟢 Win overlay
          if (game.showWinOverlay)
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Back to level selection
              },
              child: Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: const Text(
                  'Level Complete!\nTap to Continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, color: Colors.greenAccent),
                ),
              ),
            ),

          // Control Buttons (same as before)
          Positioned(
            left: 20,
            bottom: 30,
            child: Row(
              children: [
                GestureDetector(
                  onTapDown: (_) => game.moveLeft = true,
                  onTapUp: (_) => game.moveLeft = false,
                  onTapCancel: () => game.moveLeft = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_left,
                        color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTapDown: (_) => game.moveRight = true,
                  onTapUp: (_) => game.moveRight = false,
                  onTapCancel: () => game.moveRight = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_right,
                        color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),

          // Jump Button
          Positioned(
            right: 20,
            bottom: 30,
            child: GestureDetector(
              onTapDown: (_) => game.isJumping = true,
              onTapUp: (_) => game.isJumping = false,
              onTapCancel: () => game.isJumping = false,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward,
                    color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class levelThree extends FlameGame {
  late SpriteAnimationComponent character;
  late SpriteComponent chasingTrap;
  late SpriteComponent door;
  late SpriteAnimation doorAnimation;

  bool moveLeft = false;
  bool moveRight = false;
  bool isJumping = false;
  bool isDead = false;
  bool facingRight = true;
  double moveSpeed = 200;

  double verticalSpeed = 0.0;
  final double gravity = 700;
  final double jumpForce = -600; // Increased jump speed
  bool isOnGround = true;
  bool doorOpened = false;
  bool levelComplete = false;
  bool showLoseOverlay = false;
  bool showWinOverlay = false;

  // Trap movement variables
  late Vector2 trapOriginalPos;
  final double trapMoveDistance = 40.0;
  double trapSpeed = 120;
  bool trapMovingLeft = true;

  // Trap chasing and jump-over detection
  bool wasAboveTrap = false;
  bool jumpedOverTrap = false;
  bool hasLandedAfterJump = false;
  bool trapChasing = false;

  Function()? onLevelComplete;
  Function()? onPlayerDied;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await images.loadAll([
      'background.png',
      'Character.png',
      'doors.png',
      'long_metal_spike_03.png',
    ]);

    // Background
    add(SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size
      ..position = Vector2.zero());

    // Character animation setup
    final image = images.fromCache('Character.png');
    final frameSize = Vector2(32, 32);

    final walkFrames = [
      Sprite(image, srcPosition: Vector2(0, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(32, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(64, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(96, 96), srcSize: frameSize),
    ];
    final walkAnimation =
        SpriteAnimation.spriteList(walkFrames, stepTime: 0.15, loop: true);
    character = SpriteAnimationComponent()
      ..animation = walkAnimation
      ..size = Vector2(size.x * 0.06, size.x * 0.06)
      ..position = Vector2(size.x * 0.05, size.y * 0.65);
    add(character);

    // Trap setup (single trap)
    final trapSprite = await loadSprite('long_metal_spike_03.png');
    final trapSize = Vector2(size.x * 0.05, size.x * 0.05);
    final trapY = size.y * 0.65;

    trapOriginalPos = Vector2(size.x * 0.45, trapY);
    chasingTrap = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = trapOriginalPos.clone();
    add(chasingTrap);

    // Door setup
    final doorSheet = images.fromCache('doors.png');
    final frameHeight = doorSheet.height / 10;
    door = SpriteComponent()
      ..sprite = Sprite(
        doorSheet,
        srcPosition: Vector2(0, 0),
        srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
      )
      ..size = Vector2(
          size.x * 0.15, (size.x * 0.15) * (frameHeight / doorSheet.width))
      ..position = Vector2(size.x * 0.78, size.y * 0.6);
    add(door);

    doorAnimation = SpriteAnimation.spriteList(
      List.generate(10, (i) {
        return Sprite(
          doorSheet,
          srcPosition: Vector2(0, i * frameHeight),
          srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
        );
      }),
      stepTime: 0.1,
      loop: false,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead || levelComplete) return;

    // Movement
    if (moveLeft) {
      character.position.x -= moveSpeed * dt;
      if (facingRight) {
        character.flipHorizontally();
        facingRight = false;
      }
    }
    if (moveRight) {
      character.position.x += moveSpeed * dt;
      if (!facingRight) {
        character.flipHorizontally();
        facingRight = true;
      }
    }

    // Jumping
    if (isJumping && isOnGround) {
      verticalSpeed = jumpForce;
      isOnGround = false;
    }

    verticalSpeed += gravity * dt;
    character.position.y += verticalSpeed * dt;

    final groundY = size.y * 0.65;
    if (character.position.y >= groundY) {
      character.position.y = groundY;
      verticalSpeed = 0;
      isOnGround = true;
    }

    // Clamp character on screen
    character.position.x =
        character.position.x.clamp(0, size.x - character.size.x);

    // --- Jump-over detection & trap chasing logic ---

    final playerMidX = character.position.x + character.size.x / 2;
    final trapMidX = chasingTrap.position.x + chasingTrap.size.x / 2;

    // Track if the player was in the air above the trap
    if (!isOnGround &&
        character.position.y + character.size.y < chasingTrap.position.y &&
        (playerMidX - trapMidX).abs() < 25) {
      wasAboveTrap = true;
    }

    // If the player jumped over and landed on the other side
    if (wasAboveTrap &&
        isOnGround &&
        playerMidX > trapMidX + chasingTrap.size.x / 2 &&
        !jumpedOverTrap) {
      jumpedOverTrap = true;
      hasLandedAfterJump = true;

      // Delay briefly before chasing
      Future.delayed(const Duration(milliseconds: 500), () {
        if (hasLandedAfterJump && !trapChasing) {
          trapChasing = true;
        }
      });
    }

    // Trap movement and chasing
    if (trapChasing) {
      final targetX = door.position.x;
      final direction = (targetX > chasingTrap.position.x) ? 1 : -1;
      chasingTrap.position.x += direction * (trapSpeed * 2) * dt;
    } else {
      // Default back-and-forth patrol before chase
      final leftLimit = trapOriginalPos.x - trapMoveDistance;
      final rightLimit = trapOriginalPos.x + trapMoveDistance;

      if (chasingTrap.position.x <= leftLimit) {
        trapMovingLeft = false;
      } else if (chasingTrap.position.x >= rightLimit) {
        trapMovingLeft = true;
      }

      chasingTrap.position.x += (trapMovingLeft ? -1 : 1) * trapSpeed * dt;
    }

    // Check collision with trap
    final characterBox = Rect.fromLTWH(
      character.position.x + character.size.x * 0.2,
      character.position.y + character.size.y * 0.2,
      character.size.x * 0.6,
      character.size.y * 0.6,
    );
    final trapBox = Rect.fromLTWH(
      chasingTrap.position.x + chasingTrap.size.x * 0.1,
      chasingTrap.position.y + chasingTrap.size.y * 0.1,
      chasingTrap.size.x * 0.8,
      chasingTrap.size.y * 0.8,
    );
    if (characterBox.overlaps(trapBox)) {
      die();
    }

    // Door open logic: player near door, on ground, and not dead
    if (!doorOpened &&
        character.position.x >= door.position.x - character.size.x * 0.3 &&
        isOnGround &&
        !isDead) {
      openDoor();
    }
  }

  void die() {
    if (!isDead) {
      isDead = true;
      showLoseOverlay = true;
      character.add(
        OpacityEffect.to(
            0, EffectController(duration: 1.2, curve: Curves.easeOut)),
      );
      onPlayerDied?.call();
    }
  }

  // Move character into door
  Future<void> openDoor() async {
    if (doorOpened) return;
    doorOpened = true;

    // Replace static door with animated door
    final animatedDoor = SpriteAnimationComponent()
      ..animation = doorAnimation
      ..size = door.size
      ..position = door.position.clone();

    remove(door);
    add(animatedDoor);

    // Wait for door to finish opening (shorter delay)
    await Future.delayed(const Duration(milliseconds: 800));

    // Start fade first, move second (faster fade)
    character.addAll([
      OpacityEffect.to(
        0,
        EffectController(duration: 0.7, curve: Curves.easeIn),
      ),
      MoveEffect.by(
        Vector2(size.x * 0.1, 0),
        EffectController(duration: 1.0, curve: Curves.linear),
      ),
    ]);

    // Wait until both effects complete
    await Future.delayed(const Duration(milliseconds: 1000));

    // Mark level as complete
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_3', true);

    levelComplete = true;
    showWinOverlay = true;
    onLevelComplete?.call();
  }

  void restart() {
    overlays.clear();
    children.clear();
    isDead = false;
    levelComplete = false;
    showLoseOverlay = false;
    showWinOverlay = false;
    doorOpened = false;

    // Reset trap flags
    wasAboveTrap = false;
    jumpedOverTrap = false;
    hasLandedAfterJump = false;
    trapChasing = false;
    trapMovingLeft = true;

    onLoad();
  }
}

class LevelFourScreen extends StatefulWidget {
  const LevelFourScreen({super.key});

  @override
  State<LevelFourScreen> createState() => _LevelFourScreenState();
}

class _LevelFourScreenState extends State<LevelFourScreen> {
  late levelFour game;

  @override
  void initState() {
    super.initState();
    initGame();
  }

  void initGame() {
    game = levelFour();
    game.onLevelComplete = () {
      setState(() {}); // To show the win overlay
    };
    game.onPlayerDied = () {
      setState(() {}); // Show lose overlay
    };
  }

  void restartGame() {
    setState(() {
      initGame(); // re-create game instance
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),

          // 🔴 Lose overlay
          if (game.showLoseOverlay)
            GestureDetector(
              onTap: () {
                restartGame(); // Use this instead of game.restart()
              },
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const Text(
                  'You Died! Tap to Retry',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),

          // 🟢 Win overlay
          if (game.showWinOverlay)
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Back to level selection
              },
              child: Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: const Text(
                  'Level Complete!\nTap to Continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, color: Colors.greenAccent),
                ),
              ),
            ),

          // Control Buttons
          Positioned(
            left: 20,
            bottom: 30,
            child: Row(
              children: [
                GestureDetector(
                  onTapDown: (_) => game.moveLeft = true,
                  onTapUp: (_) => game.moveLeft = false,
                  onTapCancel: () => game.moveLeft = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_left,
                        color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTapDown: (_) => game.moveRight = true,
                  onTapUp: (_) => game.moveRight = false,
                  onTapCancel: () => game.moveRight = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_right,
                        color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),

          // Jump Button
          Positioned(
            right: 20,
            bottom: 30,
            child: GestureDetector(
              onTapDown: (_) => game.isJumping = true,
              onTapUp: (_) => game.isJumping = false,
              onTapCancel: () => game.isJumping = false,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward,
                    color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelFourScreen extends State<LevelFourScreen> {
  late levelFour game;
  bool isGameReady = false;

  @override
  void initState() {
    super.initState();
    initGame();
  }

  void initGame() {
    game = levelFour();

    game.onLevelComplete = () {
      setState(() {});
    };

    game.onPlayerDied = () {
      setState(() {});
    };

    game.onLoad().then((_) {
      setState(() {
        isGameReady = true;
      });
    });
  }

  void restartGame() {
    setState(() {
      isGameReady = false;
    });
    initGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isGameReady
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GameWidget(game: game),

                if (game.showLoseOverlay)
                  GestureDetector(
                    onTap: restartGame,
                    child: Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: const Text(
                        'You Died! Tap to Retry',
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                    ),
                  ),

                if (game.showWinOverlay)
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      color: Colors.black87,
                      alignment: Alignment.center,
                      child: const Text(
                        'Level Complete!\nTap to Continue',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 28, color: Colors.greenAccent),
                      ),
                    ),
                  ),

                // Left and Right Controls
                Positioned(
                  left: 20,
                  bottom: 30,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTapDown: (_) => game.moveLeft = true,
                        onTapUp: (_) => game.moveLeft = false,
                        onTapCancel: () => game.moveLeft = false,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                              color: Colors.black87, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_left,
                              color: Colors.white, size: 40),
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTapDown: (_) => game.moveRight = true,
                        onTapUp: (_) => game.moveRight = false,
                        onTapCancel: () => game.moveRight = false,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                              color: Colors.black87, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_right,
                              color: Colors.white, size: 40),
                        ),
                      ),
                    ],
                  ),
                ),

                // Jump Button
                Positioned(
                  right: 20,
                  bottom: 30,
                  child: GestureDetector(
                    onTapDown: (_) => game.isJumping = true,
                    onTapUp: (_) => game.isJumping = false,
                    onTapCancel: () => game.isJumping = false,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                          color: Colors.redAccent, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_upward,
                          color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class levelFour extends FlameGame {
  late SpriteAnimationComponent character;
  late SpriteComponent trap;
  late SpriteAnimationComponent door;
  late SpriteAnimation doorAnimation;

  bool moveLeft = false;
  bool moveRight = false;
  bool isJumping = false;
  bool isOnGround = true;
  bool doorOpened = false;
  bool levelComplete = false;
  bool isDead = false;
  bool showLoseOverlay = false;
  bool showWinOverlay = false;

  double doorVerticalSpeed = 0.0;
  final double gravity = 700;
  final double jumpForce = -900;
  final double moveSpeed = 200;

  Function()? onLevelComplete;
  Function()? onPlayerDied;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'background.png',
      'Character.png',
      'doors.png',
      'long_metal_spike_03.png',
    ]);

    add(SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size
      ..position = Vector2.zero());

    final image = images.fromCache('Character.png');
    final frameSize = Vector2(32, 32);
    final walkFrames = [
      Sprite(image, srcPosition: Vector2(0, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(32, 96), srcSize: frameSize),
    ];
    character = SpriteAnimationComponent()
      ..animation =
          SpriteAnimation.spriteList(walkFrames, stepTime: 0.3, loop: true)
      ..size = Vector2(size.x * 0.06, size.x * 0.06)
      ..position = Vector2(size.x * 0.05, size.y * 0.65);
    add(character);

    trap = SpriteComponent()
      ..sprite = await loadSprite('long_metal_spike_03.png')
      ..size = Vector2(size.x * 0.05, size.x * 0.05)
      ..position = Vector2(size.x * 0.45, size.y * 0.665);
    add(trap);

    final doorSheet = images.fromCache('doors.png');
    final frameHeight = doorSheet.height / 10;
    doorAnimation = SpriteAnimation.spriteList(
      List.generate(
          10,
          (i) => Sprite(
                doorSheet,
                srcPosition: Vector2(0, i * frameHeight),
                srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
              )),
      stepTime: 0.1,
      loop: false,
    );

    door = SpriteAnimationComponent()
      ..animation = SpriteAnimation.spriteList(
        [
          Sprite(doorSheet,
              srcPosition: Vector2(0, 0),
              srcSize: Vector2(doorSheet.width.toDouble(), frameHeight))
        ],
        stepTime: 0.1,
      )
      ..size = Vector2(
          size.x * 0.15, (size.x * 0.15) * (frameHeight / doorSheet.width))
      ..position = Vector2(size.x * 0.8, size.y * 0.6);
    add(door);
  }

  @override
  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || levelComplete) return;

    // Door horizontal movement
    if (moveLeft) door.position.x -= moveSpeed * dt;
    if (moveRight) door.position.x += moveSpeed * dt;

    // Door jump
    if (isJumping && isOnGround) {
      doorVerticalSpeed = jumpForce;
      isOnGround = false;
    }

    // Apply gravity
    doorVerticalSpeed += gravity * dt;
    door.position.y += doorVerticalSpeed * dt;

    // Stay on ground
    final groundY = size.y * 0.6;
    if (door.position.y >= groundY) {
      door.position.y = groundY;
      doorVerticalSpeed = 0;
      isOnGround = true;
    }

    // Clamp door to screen bounds
    door.position.x = door.position.x.clamp(0, size.x - door.size.x);

    // Death by trap
    if (door.toRect().overlaps(trap.toRect())) {
      die();
    }

    // ✅ New collision check: distance-based, more reliable
    double distance = door.position.distanceTo(character.position);
    if (!doorOpened && distance < 40 && isOnGround) {
      openDoor();
    }
  }

  void die() {
    if (!isDead) {
      isDead = true;
      showLoseOverlay = true;
      onPlayerDied?.call();
    }
  }

  Future<void> openDoor() async {
    doorOpened = true;
    print("Door opening...");
    door.animation = doorAnimation;
    await Future.delayed(const Duration(milliseconds: 1000));
    character.add(OpacityEffect.to(0, EffectController(duration: 1.5)));
    await Future.delayed(const Duration(milliseconds: 1000));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_4', true);
    levelComplete = true;
    showWinOverlay = true;
    onLevelComplete?.call();
  }

  void restart() {
    overlays.clear();
    isDead = false;
    doorOpened = false;
    showLoseOverlay = false;
    showWinOverlay = false;
    levelComplete = false;
    door.position = Vector2(size.x * 0.8, size.y * 0.6);
    character.opacity = 1;
  }
}

class LevelFiveScreen extends StatefulWidget {
  const LevelFiveScreen({super.key});

  @override
  State<LevelFiveScreen> createState() => _LevelFiveScreenState();
}

class _LevelFiveScreenState extends State<LevelFiveScreen> {
  final Levelfive game = Levelfive();

  @override
  void initState() {
    super.initState();
    game.onLevelComplete = () {
      setState(() {}); // To show the win overlay
    };
    game.onPlayerDied = () {
      setState(() {}); // Show lose overlay
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),

          // 🔴 Lose overlay
          if (game.showLoseOverlay)
            GestureDetector(
              onTap: () {
                setState(() {
                  game.overlays.clear();
                  game.restart();
                });
              },
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const Text(
                  'You Died! Tap to Retry',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),

          // 🟢 Win overlay
          if (game.showWinOverlay)
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Back to level selection
              },
              child: Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: const Text(
                  'Level Complete!\nTap to Continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, color: Colors.greenAccent),
                ),
              ),
            ),

          // Control Buttons (same as before)
          Positioned(
            left: 20,
            bottom: 30,
            child: Row(
              children: [
                GestureDetector(
                  onTapDown: (_) => game.moveLeft = true,
                  onTapUp: (_) => game.moveLeft = false,
                  onTapCancel: () => game.moveLeft = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_left,
                        color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTapDown: (_) => game.moveRight = true,
                  onTapUp: (_) => game.moveRight = false,
                  onTapCancel: () => game.moveRight = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_right,
                        color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),

          // Jump Button
          Positioned(
            right: 20,
            bottom: 30,
            child: GestureDetector(
              onTapDown: (_) => game.isJumping = true,
              onTapUp: (_) => game.isJumping = false,
              onTapCancel: () => game.isJumping = false,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward,
                    color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Levelfive extends FlameGame {
  late SpriteAnimationComponent character;
  late SpriteComponent trap1;
  late SpriteComponent trap2;
  late SpriteComponent trap3;
  late SpriteComponent trap4;
  late SpriteComponent door;
  late SpriteAnimation doorAnimation;

  bool moveLeft = false;
  bool moveRight = false;
  bool isJumping = false;
  bool isDead = false;
  bool facingRight = true;
  double moveSpeed = 200;

  double verticalSpeed = 0.0;
  final double gravity = 500;
  final double jumpForce = -500;
  bool isOnGround = true;
  bool doorOpened = false;
  bool levelComplete = false;
  bool showLoseOverlay = false;
  bool showWinOverlay = false;

  late Vector2 trap2OriginalPos;
  final double trapMoveDistance = 40.0;

  Function()? onLevelComplete;
  Function()? onPlayerDied;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await images.loadAll([
      'background.png',
      'Character.png',
      'doors.png',
      'long_metal_spike_03.png',
    ]);

    // Background
    add(SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size
      ..position = Vector2.zero());

    // Character animation setup
    final image = images.fromCache('Character.png');
    final frameSize = Vector2(32, 32);

    final walkFrames = [
      Sprite(image, srcPosition: Vector2(0, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(32, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(64, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(96, 96), srcSize: frameSize),
    ];
    final walkAnimation =
        SpriteAnimation.spriteList(walkFrames, stepTime: 0.15, loop: true);
    character = SpriteAnimationComponent()
      ..animation = walkAnimation
      ..size = Vector2(size.x * 0.06, size.x * 0.06)
      ..position =
          Vector2(size.x * 0.4, size.y * 0.65); // between trap1 and trap2
    add(character);

    final trapSprite = await loadSprite('long_metal_spike_03.png');
    final trapSize = Vector2(size.x * 0.05, size.x * 0.05);
    final trapY = size.y * 0.65;

    // Move trap1 a bit closer to the character start position for better touch detection
    trap1 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position =
          Vector2(size.x * 0.34, trapY); // closer to character (left side)
    add(trap1);

    trap2OriginalPos = Vector2(size.x * 0.48, trapY); // right of character
    trap2 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = trap2OriginalPos.clone();
    add(trap2);

    trap3 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = Vector2(size.x * 0.62, trapY); // static trap
    add(trap3);

    trap4 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = Vector2(size.x * 0.75, trapY);
    add(trap4);

    final doorSheet = images.fromCache('doors.png');
    final frameHeight = doorSheet.height / 10;
    door = SpriteComponent()
      ..sprite = Sprite(doorSheet,
          srcPosition: Vector2(0, 0),
          srcSize: Vector2(doorSheet.width.toDouble(), frameHeight))
      ..size = Vector2(
          size.x * 0.15, (size.x * 0.15) * (frameHeight / doorSheet.width))
      ..position = Vector2(size.x * 0.85, size.y * 0.6);
    add(door);

    doorAnimation = SpriteAnimation.spriteList(
      List.generate(
          10,
          (i) => Sprite(
                doorSheet,
                srcPosition: Vector2(0, i * frameHeight),
                srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
              )),
      stepTime: 0.1,
      loop: false,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || levelComplete) return;

    // Movement logic
    if (moveLeft) {
      character.position.x += moveSpeed * dt;
      if (!facingRight) {
        character.flipHorizontally();
        facingRight = true;
      }
    }
    if (moveRight) {
      character.position.x -= moveSpeed * dt;
      if (facingRight) {
        character.flipHorizontally();
        facingRight = false;
      }
    }

    // Jump logic
    if (isJumping && isOnGround) {
      verticalSpeed = jumpForce;
      isOnGround = false;
    }

    verticalSpeed += gravity * dt;
    character.position.y += verticalSpeed * dt;

    final groundY = size.y * 0.65;
    if (character.position.y >= groundY) {
      character.position.y = groundY;
      verticalSpeed = 0;
      isOnGround = true;
    }

    character.position.x =
        character.position.x.clamp(0, size.x - character.size.x);

    // Trap 2 moves left when player is close
    if ((character.position.x - trap2.position.x).abs() < 80) {
      final targetX = trap2OriginalPos.x - trapMoveDistance;
      trap2.position.x = (trap2.position.x - moveSpeed * dt)
          .clamp(targetX, trap2OriginalPos.x);
    } else {
      trap2.position.x = (trap2.position.x + moveSpeed * dt)
          .clamp(trap2OriginalPos.x - trapMoveDistance, trap2OriginalPos.x);
    }

    // Trap 3 is static - no movement logic here

    // Collision check - modified to fix trap1 detection
    final characterBox = Rect.fromLTWH(
      character.position.x,
      character.position.y,
      character.size.x,
      character.size.y,
    );

    for (final trap in [trap1, trap2, trap3, trap4]) {
      Rect trapBox;

      if (trap == trap1) {
        // Expand trap1 collision box a bit for better detection
        trapBox = Rect.fromLTWH(
          trap.position.x - 5,
          trap.position.y - 5,
          trap.size.x + 10,
          trap.size.y + 10,
        );
      } else {
        trapBox = Rect.fromLTWH(
          trap.position.x,
          trap.position.y,
          trap.size.x,
          trap.size.y,
        );
      }

      if (characterBox.overlaps(trapBox)) {
        die();
        break;
      }
    }

    // Door logic
    if (!doorOpened &&
        character.position.x >= door.position.x - character.size.x * 0.3 &&
        isOnGround &&
        !isDead) {
      openDoor();
    }
  }

  void die() {
    if (!isDead) {
      isDead = true;
      showLoseOverlay = true;
      character.add(OpacityEffect.to(
          0, EffectController(duration: 1.2, curve: Curves.easeOut)));
      onPlayerDied?.call();
    }
  }

  Future<void> openDoor() async {
    if (doorOpened) return;
    doorOpened = true;

    final animatedDoor = SpriteAnimationComponent()
      ..animation = doorAnimation
      ..size = door.size
      ..position = door.position.clone();

    remove(door);
    add(animatedDoor);

    await Future.delayed(const Duration(milliseconds: 800));

    character.addAll([
      OpacityEffect.to(
          0, EffectController(duration: 0.7, curve: Curves.easeIn)),
      MoveEffect.by(Vector2(size.x * 0.1, 0),
          EffectController(duration: 1.0, curve: Curves.linear)),
    ]);

    await Future.delayed(const Duration(milliseconds: 1000));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_5', true);

    levelComplete = true;
    showWinOverlay = true;
    onLevelComplete?.call();
  }

  void restart() {
    overlays.remove('LoseOverlay');
    overlays.remove('WinOverlay');
    showLoseOverlay = false;
    showWinOverlay = false;
    isDead = false;
    doorOpened = false;
    levelComplete = false;

    character.position = Vector2(size.x * 0.4, size.y * 0.65);
    character.opacity = 1.0;

    trap2.position = trap2OriginalPos.clone();

    removeWhere((component) =>
        component is SpriteAnimationComponent &&
        component.animation == doorAnimation);
  }
}

class LevelSixScreen extends StatefulWidget {
  const LevelSixScreen({super.key});

  @override
  State<LevelSixScreen> createState() => _LevelSixScreenState();
}

class _LevelSixScreenState extends State<LevelSixScreen> {
  final LevelSix game = LevelSix();

  @override
  void initState() {
    super.initState();
    game.onLevelComplete = () {
      setState(() {}); // Show win overlay
    };
    game.onPlayerDied = () {
      setState(() {}); // Show lose overlay
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),

          // Lose overlay
          if (game.showLoseOverlay)
            GestureDetector(
              onTap: () {
                setState(() {
                  game.overlays.clear();
                  game.restart();
                });
              },
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const Text(
                  'You Died! Tap to Retry',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),

          // Win overlay
          if (game.showWinOverlay)
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: const Text(
                  'Level Complete!\nTap to Continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, color: Colors.greenAccent),
                ),
              ),
            ),

          // Controls
          Positioned(
            left: 20,
            bottom: 30,
            child: Row(
              children: [
                GestureDetector(
                  onTapDown: (_) => game.moveLeft = true,
                  onTapUp: (_) => game.moveLeft = false,
                  onTapCancel: () => game.moveLeft = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_left,
                        color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTapDown: (_) => game.moveRight = true,
                  onTapUp: (_) => game.moveRight = false,
                  onTapCancel: () => game.moveRight = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_right,
                        color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 20,
            bottom: 30,
            child: GestureDetector(
              onTapDown: (_) => game.isJumping = true,
              onTapUp: (_) => game.isJumping = false,
              onTapCancel: () => game.isJumping = false,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward,
                    color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LevelSix extends FlameGame {
  late SpriteAnimationComponent character;
  late SpriteComponent trap1, trap2;
  late SpriteComponent initialDoor;
  late SpriteComponent newChasingTrap;
  late SpriteAnimation doorAnimation;
  SpriteAnimationComponent? animatedDoor;

  SpriteComponent? finalDoor;

  bool moveLeft = false;
  bool moveRight = false;
  bool isJumping = false;
  bool isOnGround = true;
  bool isDead = false;
  bool doorOpened = false;
  bool levelComplete = false;
  bool showLoseOverlay = false;
  bool showWinOverlay = false;
  bool chasing = false;

  double moveSpeed = 200;
  double verticalSpeed = 0.0;
  final double gravity = 700;
  final double jumpForce = -800;

  Function()? onLevelComplete;
  Function()? onPlayerDied;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await images.loadAll([
      'background.png',
      'Character.png',
      'doors.png',
      'long_metal_spike_03.png',
    ]);

    // Background
    add(SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size
      ..position = Vector2.zero());

    // Character
    final image = images.fromCache('Character.png');
    final frameSize = Vector2(32, 32);
    final walkFrames = [
      Sprite(image, srcPosition: Vector2(0, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(32, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(64, 96), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(96, 96), srcSize: frameSize),
    ];
    final walkAnimation =
        SpriteAnimation.spriteList(walkFrames, stepTime: 0.15, loop: true);
    character = SpriteAnimationComponent()
      ..animation = walkAnimation
      ..size = Vector2(size.x * 0.06, size.x * 0.06)
      ..position = Vector2(size.x * 0.05, size.y * 0.65);
    add(character);

    // Traps
    final trapSprite = await loadSprite('long_metal_spike_03.png');
    trap1 = SpriteComponent()
      ..sprite = trapSprite
      ..size = Vector2(size.x * 0.05, size.x * 0.05)
      ..position = Vector2(size.x * 0.25, size.y * 0.65);
    trap2 = SpriteComponent()
      ..sprite = trapSprite
      ..size = Vector2(size.x * 0.05, size.x * 0.05)
      ..position = Vector2(size.x * 0.45, size.y * 0.65);
    addAll([trap1, trap2]);

    // Initial Door
    final doorSheet = images.fromCache('doors.png');
    final frameHeight = doorSheet.height / 10;
    initialDoor = SpriteComponent()
      ..sprite = Sprite(doorSheet,
          srcPosition: Vector2(0, 0),
          srcSize: Vector2(doorSheet.width.toDouble(), frameHeight))
      ..size = Vector2(
          size.x * 0.15, (size.x * 0.15) * (frameHeight / doorSheet.width))
      ..position = Vector2(size.x * 0.8, size.y * 0.6);
    add(initialDoor);

    doorAnimation = SpriteAnimation.spriteList(
      List.generate(10, (i) {
        return Sprite(
          doorSheet,
          srcPosition: Vector2(0, i * frameHeight),
          srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
        );
      }),
      stepTime: 0.1,
      loop: false,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || levelComplete) return;

    // Movement
    if (moveLeft) character.position.x -= moveSpeed * dt;
    if (moveRight) character.position.x += moveSpeed * dt;

    // Jumping
    if (isJumping && isOnGround) {
      verticalSpeed = jumpForce;
      isOnGround = false;
    }
    verticalSpeed += gravity * dt;
    character.position.y += verticalSpeed * dt;

    final groundY = size.y * 0.65;
    if (character.position.y >= groundY) {
      character.position.y = groundY;
      verticalSpeed = 0;
      isOnGround = true;
    }

    // Clamp to screen
    character.position.x =
        character.position.x.clamp(0, size.x - character.size.x);

    // Collision with fixed traps
    if (character.toRect().overlaps(trap1.toRect()) ||
        character.toRect().overlaps(trap2.toRect())) {
      die();
    }

    // If character near the initial door
    if (!doorOpened &&
        character.position.x >= size.x * 0.6 && // fade earlier
        isOnGround) {
      triggerTransition();
    }

    // Chasing trap logic
    if (chasing) {
      final direction =
          (character.position.x > newChasingTrap.position.x) ? 1 : -1;
      newChasingTrap.position.x += direction * 180 * dt;

      if (character.toRect().overlaps(newChasingTrap.toRect())) {
        die();
      }
    }

    // Reached final door
    if (doorOpened &&
        finalDoor != null &&
        character.position.x >=
            finalDoor!.position.x - character.size.x * 0.3 &&
        character.position.x <= finalDoor!.position.x + finalDoor!.size.x) {
      openDoor(finalDoor!);
    }
  }

  void die() {
    if (!isDead) {
      isDead = true;
      showLoseOverlay = true;
      character.add(
        OpacityEffect.to(0, EffectController(duration: 1.0)),
      );
      onPlayerDied?.call();
    }
  }

  Future<void> triggerTransition() async {
    doorOpened = true;

    // Fade out door and traps
    for (final comp in [initialDoor, trap1, trap2]) {
      comp.add(OpacityEffect.to(0, EffectController(duration: 0.8))
        ..onComplete = () => comp.removeFromParent());
    }
    await Future.delayed(const Duration(milliseconds: 900));

    // Spawn new door at start
    final doorSheet = images.fromCache('doors.png');
    final frameHeight = doorSheet.height / 10;
    finalDoor = SpriteComponent()
      ..sprite = Sprite(doorSheet,
          srcPosition: Vector2(0, 0),
          srcSize: Vector2(doorSheet.width.toDouble(), frameHeight))
      ..size = Vector2(
          size.x * 0.15, (size.x * 0.15) * (frameHeight / doorSheet.width))
      ..position = Vector2(size.x * 0.05, size.y * 0.6);
    add(finalDoor!);

    final trapSprite = await loadSprite('long_metal_spike_03.png');
    final trapY = size.y * 0.65; // same Y as trap1 and trap2
    newChasingTrap = SpriteComponent()
      ..sprite = trapSprite
      ..size = Vector2(size.x * 0.05, size.x * 0.05)
      ..position = Vector2(
          initialDoor.position.x + size.x * 0.1, trapY); // farther to right
    add(newChasingTrap);

    chasing = true;
// Start chasing
    chasing = true;
  }

  Future<void> openDoor(SpriteComponent doorToReplace) async {
    if (levelComplete) return;

    final animated = SpriteAnimationComponent()
      ..animation = doorAnimation
      ..size = doorToReplace.size
      ..position = doorToReplace.position.clone();
    remove(doorToReplace);
    add(animated);

    character.addAll([
      OpacityEffect.to(0, EffectController(duration: 0.7)),
      MoveEffect.by(Vector2(size.x * 0.1, 0),
          EffectController(duration: 1.0, curve: Curves.linear)),
    ]);

    await Future.delayed(const Duration(milliseconds: 1000));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_6', true);

    levelComplete = true;
    showWinOverlay = true;
    onLevelComplete?.call();
  }

  void restart() {
    overlays.clear();
    children.clear();
    isDead = false;
    levelComplete = false;
    showLoseOverlay = false;
    showWinOverlay = false;
    doorOpened = false;
    chasing = false;
    onLoad();
  }
}
