import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// FitQuest Gamified Audio & Sound Effects Engine
class FQAudioService {
  static final FQAudioService _instance = FQAudioService._internal();
  factory FQAudioService() => _instance;
  FQAudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;
  void toggleSound(bool enabled) => _soundEnabled = enabled;

  // Ultra-fast cached Web Audio SFX streams (low latency wav/mp3)
  static const String _xpCoinSfx = 'https://assets.mixkit.co/active_storage/sfx/2000/2000-preview.mp3'; // Arcade Level Win / Coin
  static const String _repDingSfx = 'https://assets.mixkit.co/active_storage/sfx/1435/1435-preview.mp3'; // Ding / Bell
  static const String _victorySfx = 'https://assets.mixkit.co/active_storage/sfx/1433/1433-preview.mp3'; // Triumph Fanfare
  static const String _checkInSfx = 'https://assets.mixkit.co/active_storage/sfx/2019/2019-preview.mp3'; // Magic chime
  static const String _warningSfx = 'https://assets.mixkit.co/active_storage/sfx/2874/2874-preview.mp3'; // Alert pop

  /// 🪙 Play XP Coin / Level Up Chime
  Future<void> playXpGain() async {
    HapticFeedback.mediumImpact();
    if (!_soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(UrlSource(_xpCoinSfx), volume: 0.85);
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// 🔔 Play Clean Rep / Good Form Ding
  Future<void> playRepDing() async {
    HapticFeedback.selectionClick();
    if (!_soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(UrlSource(_repDingSfx), volume: 0.75);
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// 🏆 Play 1v1 Duel Win / Challenge Victory Fanfare
  Future<void> playVictory() async {
    HapticFeedback.heavyImpact();
    if (!_soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(UrlSource(_victorySfx), volume: 0.95);
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  /// 📍 Play FitMap Hotspot Check-In Chime
  Future<void> playCheckIn() async {
    HapticFeedback.mediumImpact();
    if (!_soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(UrlSource(_checkInSfx), volume: 0.8);
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// ⚠️ Play Biomechanical Form Warning Alert
  Future<void> playWarning() async {
    HapticFeedback.heavyImpact();
    if (!_soundEnabled) return;
    try {
      await _player.stop();
      await _player.play(UrlSource(_warningSfx), volume: 0.7);
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  /// 🔘 Play UI Click / Button Tap
  void playTap() {
    HapticFeedback.selectionClick();
  }
}
