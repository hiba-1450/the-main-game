import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame/flame.dart';

// Constants for shared values
class GameConstants {
  static const double moveSpeed = 200;
  static const double gravity = 500;
  static const double jumpForce = -500;
  static const String backgroundAsset = 'background.png';
  static const String characterAsset = 'Character.png';
  static const String doorAsset = 'doors.png';
  static const String spikeAsset1 = 'long_metal_spike_01.png';
  static const String spikeAsset2 = 'long_metal_spike_02.png';
  static const String spikeAsset3 = 'long_metal_spike_03.png';
}

// Function to mark level as completed
Future<void> markLevelAsCompleted(String levelId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('level_$levelId', true);
}

// Abstract base game class
abstract class BaseGame extends FlameGame {
  SpriteAnimationComponent get character;
  bool moveLeft = false;
  bool moveRight = false;
  bool isJumping = false;
  bool isDead = false;
  bool facingRight = true;
  bool isOnGround = true;
  bool doorOpened = false;
  bool levelComplete = false;
  bool showLoseOverlay = false;
  bool showWinOverlay = false;
  double moveSpeed = GameConstants.moveSpeed;
  double verticalSpeed = 0.0;
  double gravity = GameConstants.gravity;
  double jumpForce = GameConstants.jumpForce;

  Function()? onLevelComplete;
  Function()? onPlayerDied;

  void die();
  Future<void> openDoor();
  void restart();
  String getLevelId();
}

// Base platformer game with shared logic
abstract class PlatformerGame extends BaseGame {
  late SpriteAnimationComponent character;
  late SpriteComponent door;
  late SpriteAnimation doorAnimation;
  Vector2? doorPosition;

  @override
  Future<void> onLoad() async {
    // Background
    add(SpriteComponent()
      ..sprite = await loadSprite(GameConstants.backgroundAsset)
      ..size = size
      ..position = Vector2.zero());

    // Character
    final image = images.fromCache(GameConstants.characterAsset);
    final frameSize = Vector2(32, 32);
    final walkFrames = [
      for (int i = 0; i < 4; i++)
        Sprite(image, srcPosition: Vector2(i * 32, 96), srcSize: frameSize),
    ];
    character = SpriteAnimationComponent()
      ..animation =
          SpriteAnimation.spriteList(walkFrames, stepTime: 0.15, loop: true)
      ..size = Vector2(size.x * 0.06, size.x * 0.06)
      ..position = Vector2(size.x * 0.05, size.y * 0.65);
    add(character);

    // Door
    final doorSheet = images.fromCache(GameConstants.doorAsset);
    final frameHeight = doorSheet.height / 10;
    doorAnimation = SpriteAnimation.spriteList(
      List.generate(
        10,
        (i) => Sprite(
          doorSheet,
          srcPosition: Vector2(0, i * frameHeight),
          srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
        ),
      ),
      stepTime: 0.1,
      loop: false,
    );
    doorPosition ??= Vector2(size.x * 0.78, size.y * 0.6);
    door = SpriteComponent()
      ..sprite = Sprite(
        doorSheet,
        srcPosition: Vector2(0, 0),
        srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
      )
      ..size = Vector2(
          size.x * 0.15, (size.x * 0.15) * (frameHeight / doorSheet.width))
      ..position = doorPosition!;
    add(door);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || levelComplete) return;

    // Call customizable character movement
    updateCharacterMovement(dt);

    // Door logic
    if (!doorOpened &&
        character.position.x >= door.position.x - character.size.x * 0.3 &&
        isOnGround &&
        !isDead) {
      openDoor();
    }
  }

  // Virtual method for character movement
  void updateCharacterMovement(double dt) {
    // Default movement (used by other levels)
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

    character.position.x =
        character.position.x.clamp(0, size.x - character.size.x);
  }

  @override
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

  @override
  Future<void> openDoor() async {
    if (doorOpened) return;
    doorOpened = true;

    final animatedDoor = SpriteAnimationComponent()
      ..animation = doorAnimation
      ..size = door.size
      ..position = door.position.clone();
    remove(door);
    add(animatedDoor);

    // Start character fade-out and move effects immediately with door animation
    character.addAll([
      OpacityEffect.to(
          0, EffectController(duration: 0.7, curve: Curves.easeIn)),
      MoveEffect.by(Vector2(size.x * 0.1, 0), EffectController(duration: 1.0)),
    ]);

    // Wait for the door animation and character effects to complete
    await Future.delayed(const Duration(milliseconds: 1800));

    await markLevelAsCompleted(getLevelId());
    levelComplete = true;
    showWinOverlay = true;
    onLevelComplete?.call();
  }

  @override
  void restart() {
    overlays.clear();
    removeAll(children.toList());
    isDead = false;
    levelComplete = false;
    showLoseOverlay = false;
    showWinOverlay = false;
    doorOpened = false;
    onLoad();
  }
}

// Level 1
class CharacterDisplayGame extends PlatformerGame {
  late SpriteAnimationComponent spikeTrap;
  bool doorTriggered = false;
  bool trapVisible = false;

  @override
  String getLevelId() => '1';

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    spikeTrap = SpriteAnimationComponent()
      ..animation = SpriteAnimation.spriteList(
        [
          Sprite(images.fromCache(GameConstants.spikeAsset1)),
          Sprite(images.fromCache(GameConstants.spikeAsset2)),
          Sprite(images.fromCache(GameConstants.spikeAsset3)),
        ],
        stepTime: 0.2,
        loop: true,
      )
      ..size = Vector2(size.x * 0.05, size.x * 0.05)
      ..position = Vector2(size.x * 0.76, size.y * 0.65)
      ..opacity = 0;
    add(spikeTrap);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || levelComplete) return;

    if (!doorTriggered &&
        character.position.x >= door.position.x - character.size.x * 1.2) {
      doorTriggered = true;
      door.add(MoveEffect.by(
          Vector2(size.x * 0.05, 0), EffectController(duration: 0.3)));
      spikeTrap.add(OpacityEffect.to(1.0, EffectController(duration: 0.4)));
      trapVisible = true;
    }

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
  }

  @override
  void restart() {
    super.restart();
    doorTriggered = false;
    trapVisible = false;
  }
}

// Level 2
class LevelTwo extends PlatformerGame {
  late SpriteComponent trap1, trap2, trap3;
  late Vector2 trap2OriginalPos, trap3OriginalPos;
  final double trapMoveDistance = 40.0;

  @override
  String getLevelId() => '2';

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final trapSprite = await loadSprite(GameConstants.spikeAsset3);
    final trapSize = Vector2(size.x * 0.05, size.x * 0.05);
    final trapY = size.y * 0.65;

    trap1 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = Vector2(size.x * 0.25, trapY);
    trap2OriginalPos = Vector2(size.x * 0.45, trapY);
    trap2 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = trap2OriginalPos.clone();
    trap3OriginalPos = Vector2(size.x * 0.65, trapY);
    trap3 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = trap3OriginalPos.clone();
    addAll([trap1, trap2, trap3]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || levelComplete) return;

    // Trap 2 movement
    if ((character.position.x - trap2.position.x).abs() < 80) {
      final targetX = trap2OriginalPos.x - trapMoveDistance;
      trap2.position.x = (trap2.position.x - moveSpeed * dt)
          .clamp(targetX, trap2OriginalPos.x);
    } else {
      trap2.position.x = (trap2.position.x + moveSpeed * dt)
          .clamp(trap2OriginalPos.x - trapMoveDistance, trap2OriginalPos.x);
    }

    // Trap 3 movement
    if ((character.position.x - trap3.position.x).abs() < 80) {
      final targetX = trap3OriginalPos.x + trapMoveDistance;
      trap3.position.x = (trap3.position.x + moveSpeed * dt)
          .clamp(trap3OriginalPos.x, targetX);
    } else {
      trap3.position.x = (trap3.position.x - moveSpeed * dt)
          .clamp(trap3OriginalPos.x, trap3OriginalPos.x + trapMoveDistance);
    }

    // Collision check
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
  }
}

// Level 3

class levelThree extends PlatformerGame {
  late SpriteComponent chasingTrap;
  late Vector2 trapOriginalPos;
  final double trapMoveDistance = 40.0;
  double trapSpeed = 120;
  double chasingTrapSpeed = 160; // Increased speed when chasing
  bool trapMovingLeft = true;
  bool wasAboveTrap = false;
  bool jumpedOverTrap = false;
  bool hasLandedAfterJump = false;
  bool trapChasing = false;

  @override
  String getLevelId() => '3';

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final trapSprite = await loadSprite(GameConstants.spikeAsset3);
    final trapSize = Vector2(size.x * 0.05, size.x * 0.05);
    final trapY = size.y * 0.65;

    trapOriginalPos = Vector2(size.x * 0.45, trapY);
    chasingTrap = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = trapOriginalPos.clone();
    add(chasingTrap);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || levelComplete) return;

    final playerMidX = character.position.x + character.size.x / 2;
    final trapMidX = chasingTrap.position.x + chasingTrap.size.x / 2;

    // Detect jump over trap
    if (!isOnGround &&
        character.position.y + character.size.y < chasingTrap.position.y &&
        (playerMidX - trapMidX).abs() < 25) {
      wasAboveTrap = true;
    }

    if (wasAboveTrap &&
        isOnGround &&
        playerMidX > trapMidX + chasingTrap.size.x / 2 &&
        !jumpedOverTrap) {
      jumpedOverTrap = true;
      hasLandedAfterJump = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (hasLandedAfterJump && !trapChasing) {
          trapChasing = true;
        }
      });
    }

    // Stop trap when character reaches the door
    if (character.position.x + character.size.x >= door.position.x &&
        isOnGround &&
        !isDead) {
      trapChasing = false;
    }

    // Trap movement
    if (trapChasing) {
      final targetX = character.position.x;
      final direction = (targetX > chasingTrap.position.x) ? 1 : -1;
      chasingTrap.position.x += direction * chasingTrapSpeed * dt;
    } else {
      final leftLimit = trapOriginalPos.x - trapMoveDistance;
      final rightLimit = trapOriginalPos.x + trapMoveDistance;
      if (chasingTrap.position.x <= leftLimit)
        trapMovingLeft = false;
      else if (chasingTrap.position.x >= rightLimit) trapMovingLeft = true;
      chasingTrap.position.x += (trapMovingLeft ? -1 : 1) * trapSpeed * dt;
    }

    // Collision check
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
  }

  @override
  void restart() {
    super.restart();
    wasAboveTrap = false;
    jumpedOverTrap = false;
    hasLandedAfterJump = false;
    trapChasing = false;
    trapMovingLeft = true;
    chasingTrap.position = trapOriginalPos.clone();
  }
}

// Level 4
class levelFour extends PlatformerGame {
  late SpriteComponent trap;
  double doorVerticalSpeed = 0.0;

  @override
  String getLevelId() => '4';

  @override
  Future<void> onLoad() async {
    gravity = 600;
    jumpForce = -600;
    doorPosition = Vector2(size.x * 0.8, size.y * 0.6);
    await super.onLoad();

    // Set character to a fixed position
    character.position = Vector2(size.x * 0.05, size.y * 0.65);

    trap = SpriteComponent()
      ..sprite = await loadSprite(GameConstants.spikeAsset3)
      ..size = Vector2(size.x * 0.05, size.x * 0.05)
      ..position = Vector2(size.x * 0.45, size.y * 0.65);
    add(trap);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || levelComplete) return;

    // ✅ Door horizontal movement directly based on input
    if (moveLeft) {
      door.position.x -= moveSpeed * dt;
    }
    if (moveRight) {
      door.position.x += moveSpeed * dt;
    }

    // Clamp door to screen bounds
    door.position.x = door.position.x.clamp(0, size.x - door.size.x);

    // Door vertical movement (jumping)
    if (isJumping && isOnGround) {
      doorVerticalSpeed = jumpForce;
      isOnGround = false;
    }
    doorVerticalSpeed += gravity * dt;
    door.position.y += doorVerticalSpeed * dt;

    final groundY = size.y * 0.6;
    if (door.position.y >= groundY) {
      door.position.y = groundY;
      doorVerticalSpeed = 0;
      isOnGround = true;
    }

    // Door-trap collision check
    final doorBox = Rect.fromLTWH(
      door.position.x + door.size.x * 0.2,
      door.position.y + door.size.y * 0.2,
      door.size.x * 0.6,
      door.size.y * 0.6,
    );
    final trapBox = Rect.fromLTWH(
      trap.position.x + trap.size.x * 0.1,
      trap.position.y + trap.size.y * 0.1,
      trap.size.x * 0.8,
      trap.size.y * 0.8,
    );
    if (doorBox.overlaps(trapBox)) {
      die();
    }

    // Door open logic when near character
    final targetX = character.position.x + character.size.x * 0.5;
    if (!doorOpened &&
        (door.position.x - targetX).abs() < 5 &&
        isOnGround &&
        !isDead) {
      openDoor();
    }
  }

  @override
  Future<void> openDoor() async {
    if (doorOpened) return;
    doorOpened = true;

    final animatedDoor = SpriteAnimationComponent()
      ..animation = doorAnimation
      ..size = door.size
      ..position = door.position.clone();
    remove(door);
    add(animatedDoor);

    // Move character to door's position
    final doorCenterX = door.position.x + door.size.x * 0.5;
    final characterCenterX = character.position.x + character.size.x * 0.5;
    final moveDistanceX = doorCenterX - characterCenterX;

    character.addAll([
      OpacityEffect.to(
          0, EffectController(duration: 0.7, curve: Curves.easeIn)),
      MoveEffect.by(Vector2(moveDistanceX, 0), EffectController(duration: 1.0)),
    ]);

    await Future.delayed(const Duration(milliseconds: 1800));

    await markLevelAsCompleted(getLevelId());
    levelComplete = true;
    showWinOverlay = true;
    onLevelComplete?.call();
  }

  @override
  void updateCharacterMovement(double dt) {
    // Character is completely stationary
    character.position = Vector2(size.x * 0.05, size.y * 0.65);
  }

  @override
  void restart() {
    super.restart();
    character.position = Vector2(size.x * 0.05, size.y * 0.65);
    door.position = Vector2(size.x * 0.8, size.y * 0.6);
    doorVerticalSpeed = 0.0;
    isOnGround = true;
  }
}

// Level 5
class Levelfive extends PlatformerGame {
  late SpriteComponent trap1, trap2, trap3, trap4;
  late Vector2 trap2OriginalPos;
  final double trapMoveDistance = 40.0;

  @override
  String getLevelId() => '5';

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Start between trap1 and trap2
    character.position = Vector2(size.x * 0.175, size.y * 0.65);
    doorPosition = Vector2(size.x * 0.85, size.y * 0.6);

    final trapSprite = await loadSprite(GameConstants.spikeAsset3);
    final trapSize = Vector2(size.x * 0.05, size.x * 0.05);
    final trapY = size.y * 0.65;

    trap1 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = Vector2(size.x * 0.10, trapY);

    trap2OriginalPos = Vector2(size.x * 0.25, trapY);
    trap2 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = trap2OriginalPos.clone();

    trap3 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = Vector2(size.x * 0.40, trapY);

    trap4 = SpriteComponent()
      ..sprite = trapSprite
      ..size = trapSize
      ..position = Vector2(size.x * 0.55, trapY);

    addAll([trap1, trap2, trap3, trap4]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || levelComplete) return;

    // Trap 2 movement
    if ((character.position.x - trap2.position.x).abs() < 80) {
      final targetX = trap2OriginalPos.x - trapMoveDistance;
      trap2.position.x = (trap2.position.x - moveSpeed * dt)
          .clamp(targetX, trap2OriginalPos.x);
    } else {
      trap2.position.x = (trap2.position.x + moveSpeed * dt)
          .clamp(trap2OriginalPos.x - trapMoveDistance, trap2OriginalPos.x);
    }

    // Collision check
    final characterBox = Rect.fromLTWH(
      character.position.x,
      character.position.y,
      character.size.x,
      character.size.y,
    );
    for (final trap in [trap1, trap2, trap3, trap4]) {
      final trapBox = Rect.fromLTWH(
        trap.position.x - (trap == trap1 ? 5 : 0),
        trap.position.y - (trap == trap1 ? 5 : 0),
        trap.size.x + (trap == trap1 ? 10 : 0),
        trap.size.y + (trap == trap1 ? 10 : 0),
      );
      if (characterBox.overlaps(trapBox)) {
        die();
        break;
      }
    }
  }

  @override
  void updateCharacterMovement(double dt) {
    // Swapped movement: left button moves right, right button moves left
    if (moveRight) {
      character.position.x -= moveSpeed * dt; // Right button moves left
      if (facingRight) {
        character.flipHorizontally();
        facingRight = false;
      }
    }
    if (moveLeft) {
      character.position.x += moveSpeed * dt; // Left button moves right
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

    character.position.x =
        character.position.x.clamp(0, size.x - character.size.x);
  }

  @override
  void restart() {
    super.restart();
    character.position =
        Vector2(size.x * 0.175, size.y * 0.65); // Same as initial
    trap2.position = trap2OriginalPos.clone();
  }
}

// Level 6
class LevelSix extends PlatformerGame {
  late SpriteComponent trap1, trap2;
  late SpriteComponent initialDoor;
  SpriteComponent? finalDoor;
  late SpriteComponent newChasingTrap;
  bool chasing = false;
  bool trapActive = false;
  RectangleComponent? characterDebugBox; // For visualizing character collision
  RectangleComponent? trapDebugBox; // For visualizing trap collision

  @override
  String getLevelId() => '6';

  @override
  Future<void> onLoad() async {
    gravity = 700;
    jumpForce = -800;
    doorPosition = Vector2(size.x * 0.8, size.y * 0.6);
    await super.onLoad();
    initialDoor = door;

    final trapSprite = await loadSprite(GameConstants.spikeAsset3);
    trap1 = SpriteComponent()
      ..sprite = trapSprite
      ..size = Vector2(size.x * 0.05, size.x * 0.05)
      ..position = Vector2(size.x * 0.25, size.y * 0.65);
    trap2 = SpriteComponent()
      ..sprite = trapSprite
      ..size = Vector2(size.x * 0.05, size.x * 0.05)
      ..position = Vector2(size.x * 0.45, size.y * 0.65);
    addAll([trap1, trap2]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead || levelComplete) return;

    // Update character debug box position
    if (characterDebugBox != null) {
      characterDebugBox!.position = character.position +
          Vector2(character.size.x * 0.25, character.size.y * 0.25);
    }

    // Update trap debug box position
    if (trapDebugBox != null && newChasingTrap != null) {
      trapDebugBox!.position = newChasingTrap.position +
          Vector2(newChasingTrap.size.x * 0.25, newChasingTrap.size.y * 0.25);
    }

    // Collision with fixed traps
    final characterBox = Rect.fromLTWH(
      character.position.x + character.size.x * 0.25,
      character.position.y + character.size.y * 0.25,
      character.size.x * 0.5,
      character.size.y * 0.5,
    );
    for (final trap in [trap1, trap2]) {
      if (trap.parent == null) continue; // Skip removed traps
      final trapBox = Rect.fromLTWH(
        trap.position.x + trap.size.x * 0.25,
        trap.position.y + trap.size.y * 0.25,
        trap.size.x * 0.5,
        trap.size.y * 0.5,
      );
      if (characterBox.overlaps(trapBox)) {
        print(
            'Collision with fixed trap at character.x=${character.position.x}, trap.x=${trap.position.x}');
        die();
        return;
      }
    }

    // Trigger transition
    if (!doorOpened && character.position.x >= size.x * 0.6 && isOnGround) {
      triggerTransition();
    }

    // Chasing trap logic
    if (chasing && newChasingTrap != null && trapActive) {
      final direction =
          (character.position.x > newChasingTrap.position.x) ? 1 : -1;
      newChasingTrap.position.x +=
          direction * 100 * dt; // Further reduced speed from 120 to 100
      final trapBox = Rect.fromLTWH(
        newChasingTrap.position.x + newChasingTrap.size.x * 0.25,
        newChasingTrap.position.y + newChasingTrap.size.y * 0.25,
        newChasingTrap.size.x * 0.5,
        newChasingTrap.size.y * 0.5,
      );
      if (characterBox.overlaps(trapBox)) {
        print(
            'Collision with chasing trap at character.x=${character.position.x}, trap.x=${newChasingTrap.position.x}');
        die();
        return;
      }
    }

    // Final door
    if (doorOpened &&
        finalDoor != null &&
        character.position.x >=
            finalDoor!.position.x - character.size.x * 0.3 &&
        character.position.x <= finalDoor!.position.x + finalDoor!.size.x) {
      openDoor();
    }
  }

  Future<void> triggerTransition() async {
    doorOpened = true;
    for (final comp in [initialDoor, trap1, trap2]) {
      if (comp.parent != null) {
        comp.add(OpacityEffect.to(0, EffectController(duration: 0.8))
          ..onComplete = () => comp.removeFromParent());
      }
    }
    await Future.delayed(const Duration(milliseconds: 900));

    final doorSheet = images.fromCache(GameConstants.doorAsset);
    final frameHeight = doorSheet.height / 10;
    finalDoor = SpriteComponent()
      ..sprite = Sprite(
        doorSheet,
        srcPosition: Vector2(0, 0),
        srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
      )
      ..size = Vector2(
          size.x * 0.15, (size.x * 0.15) * (frameHeight / doorSheet.width))
      ..position = Vector2(size.x * 0.05, size.y * 0.6);
    add(finalDoor!);

    final trapSprite = await loadSprite(GameConstants.spikeAsset3);
    newChasingTrap = SpriteComponent()
      ..sprite = trapSprite
      ..size = Vector2(size.x * 0.05, size.x * 0.05)
      ..position = Vector2(size.x * 0.95, size.y * 0.65);
    add(newChasingTrap);

    chasing = true;
    await Future.delayed(
        const Duration(milliseconds: 1000)); // Increased delay to 1000ms
    trapActive = true;
  }

  @override
  Future<void> openDoor() async {
    if (levelComplete || finalDoor == null) return;
    doorOpened = true;

    final animated = SpriteAnimationComponent()
      ..animation = doorAnimation
      ..size = finalDoor!.size
      ..position = finalDoor!.position.clone();
    remove(finalDoor!);
    add(animated);

    // Start character fade-out and move effects immediately with door animation
    character.addAll([
      OpacityEffect.to(0, EffectController(duration: 0.7)),
      MoveEffect.by(Vector2(size.x * 0.1, 0), EffectController(duration: 1.0)),
    ]);

    // Wait for the door animation and character effects to complete
    await Future.delayed(const Duration(milliseconds: 1800));

    await markLevelAsCompleted(getLevelId());
    levelComplete = true;
    showWinOverlay = true;
    onLevelComplete?.call();
  }

  @override
  void restart() {
    super.restart();
    chasing = false;
    trapActive = false;
    trapDebugBox?.removeFromParent();
    trapDebugBox = null;
    characterDebugBox?.removeFromParent();
    characterDebugBox = null;
  }
}

// LevelScreen
class LevelScreen extends StatefulWidget {
  final String levelId;
  final BaseGame game;

  const LevelScreen({super.key, required this.levelId, required this.game});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  @override
  void initState() {
    super.initState();
    widget.game.onLevelComplete = () => setState(() {});
    widget.game.onPlayerDied = () => setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: widget.game),
          if (widget.game.showLoseOverlay)
            GestureDetector(
              onTap: () => setState(() => widget.game.restart()),
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const Text(
                  'You Died! Tap to Retry',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),
          if (widget.game.showWinOverlay)
            GestureDetector(
              onTap: () => Navigator.pop(context),
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
          Positioned(
            left: 20,
            bottom: 30,
            child: Row(
              children: [
                _buildControlButton(
                  icon: Icons.arrow_left,
                  onDown: () => widget.game.moveLeft = true,
                  onUp: () => widget.game.moveLeft = false,
                ),
                const SizedBox(width: 20),
                _buildControlButton(
                  icon: Icons.arrow_right,
                  onDown: () => widget.game.moveRight = true,
                  onUp: () => widget.game.moveRight = false,
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 30,
            child: _buildControlButton(
              icon: Icons.arrow_upward,
              color: Colors.redAccent,
              onDown: () => widget.game.isJumping = true,
              onUp: () => widget.game.isJumping = false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    Color color = Colors.black87,
    required VoidCallback onDown,
    required VoidCallback onUp,
  }) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 40),
      ),
    );
  }
}

class LevelsPage extends StatefulWidget {
  const LevelsPage({super.key});

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage>
    with SingleTickerProviderStateMixin {
  List<bool> levelCompletionStatus = List.filled(6, false);
  late AnimationController _controller;

  final List<Map<String, dynamic>> levelConfigs = [
    {'id': '1', 'game': CharacterDisplayGame(), 'left': 0.150, 'top': 0.55},
    {'id': '2', 'game': LevelTwo(), 'left': 0.26, 'top': 0.77},
    {'id': '3', 'game': levelThree(), 'left': 0.358, 'top': 0.50},
    {'id': '4', 'game': levelFour(), 'left': 0.53, 'top': 0.66},
    {'id': '5', 'game': Levelfive(), 'left': 0.6, 'top': 0.53},
    {'id': '6', 'game': LevelSix(), 'left': 0.678, 'top': 0.78},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _loadCompletionStatus();
  }

  Future<void> _loadCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = [
      for (int i = 1; i <= 6; i++) prefs.getBool('level_$i') ?? false
    ];
    setState(() => levelCompletionStatus = status);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          return Stack(
            children: [
              Positioned.fill(
                child:
                    Image.asset('assets/images/levels.jpg', fit: BoxFit.cover),
              ),
              for (int i = 0; i < levelConfigs.length; i++)
                Positioned(
                  left: width * levelConfigs[i]['left'] - width * 0.02,
                  top: height * levelConfigs[i]['top'] - height * 0.05,
                  child: GestureDetector(
                    onTap: () {
                      if (i == 0 || levelCompletionStatus[i - 1]) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LevelScreen(
                              levelId: levelConfigs[i]['id'],
                              game: levelConfigs[i]['game'],
                            ),
                          ),
                        ).then((_) => _loadCompletionStatus());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Level ${i + 1} is locked.')),
                        );
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final glowOpacity = levelCompletionStatus[i]
                            ? 1.0
                            : 0.5 + 0.5 * _controller.value;
                        return Container(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '->',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.yellow.withOpacity(glowOpacity),
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.yellow.withOpacity(glowOpacity),
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // 🔴 Transparent button for the horned door (secret level)
              Positioned(
                left: width * 0.79,
                top: height * 0.48,
                width: width * 0.08,
                height: height * 0.15,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RedMoonScreen(),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
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

class RedMoonScreen extends StatelessWidget {
  const RedMoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/images/red_moon.jpg', // Use the correct image path
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

// Main menu and app entry
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.images.loadAll([
    GameConstants.backgroundAsset,
    GameConstants.characterAsset,
    GameConstants.doorAsset,
    GameConstants.spikeAsset1,
    GameConstants.spikeAsset2,
    GameConstants.spikeAsset3,
  ]);
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/images/main.jpg', fit: BoxFit.cover),
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
