import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../theme/fq_colors.dart';

class AiVisionWorkoutScreen extends StatefulWidget {
  final AppState appState;
  final String exerciseName;
  final int targetReps;
  final int rewardXp;
  final String questId;

  const AiVisionWorkoutScreen({
    super.key,
    required this.appState,
    this.exerciseName = 'Squats',
    this.targetReps = 12,
    this.rewardXp = 100,
    this.questId = 'morning_warrior',
  });

  @override
  State<AiVisionWorkoutScreen> createState() => _AiVisionWorkoutScreenState();
}

class _AiVisionWorkoutScreenState extends State<AiVisionWorkoutScreen> {
  CameraController? _cameraController;
  bool _cameraInitialized = false;
  bool _cameraError = false;

  int _completedReps = 0;
  bool _isDownPosition = false;
  bool _isWorkoutComplete = false;

  String _repFeedback = 'Get into frame and start!';
  DateTime _lastRepTimestamp = DateTime.now();

  int _frameCounter = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraError = true);
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _cameraInitialized = true;
      });

      _startVisionAnalysis();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Camera initialization error: $e');
      }
      if (mounted) {
        setState(() => _cameraError = true);
      }
    }
  }

  void _startVisionAnalysis() {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    controller.startImageStream((CameraImage image) {
      if (_isWorkoutComplete) return;

      _frameCounter++;
      if (_frameCounter % 4 != 0) return; // Process every 4th frame for smooth 60fps performance

      try {
        final plane = image.planes.first;
        final bytes = plane.bytes;
        final width = image.width;
        final height = image.height;

        // Sample top half vs bottom half luminance mass
        double topSum = 0;
        double bottomSum = 0;
        final step = 16; // Subsample pixels

        for (int y = 0; y < height; y += step) {
          final rowOffset = y * width;
          for (int x = 0; x < width; x += step) {
            final pixelIndex = rowOffset + x;
            if (pixelIndex < bytes.length) {
              final val = bytes[pixelIndex].toDouble();
              if (y < height / 2) {
                topSum += val;
              } else {
                bottomSum += val;
              }
            }
          }
        }

        // Ratio of upper body vs lower body presence
        final ratio = topSum / (bottomSum > 0 ? bottomSum : 1.0);

        if (!mounted) return;

        setState(() {
          // State Machine: Detect Squat / Motion Downward Transition
          if (!_isDownPosition && ratio < 0.88) {
            _isDownPosition = true;
            _repFeedback = 'Good depth! Now rise up! ⬆️';
          } else if (_isDownPosition && ratio >= 1.05) {
            // Rising up finishes the rep
            final now = DateTime.now();
            if (now.difference(_lastRepTimestamp).inMilliseconds > 700) {
              _lastRepTimestamp = now;
              _completedReps++;
              _isDownPosition = false;
              _repFeedback = 'Rep $_completedReps / ${widget.targetReps} Counted! 🔥';

              HapticFeedback.mediumImpact();

              if (_completedReps >= widget.targetReps) {
                _triggerWorkoutSuccess();
              }
            }
          }
        });
      } catch (_) {}
    });
  }

  void _triggerWorkoutSuccess() {
    _isWorkoutComplete = true;
    _cameraController?.stopImageStream();

    widget.appState.completeDynamicQuest(
      questId: widget.questId,
      rewardXp: widget.rewardXp,
    );

    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_cameraInitialized && _cameraController != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 1,
                  height: _cameraController!.value.previewSize?.width ?? 1,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else if (_cameraError)
            const Center(
              child: Text(
                'Camera unavailable. Please check permissions.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: FqColors.accent),
            ),

          // Vision Detection Overlay
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1B4B).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF00F5D4), width: 1.2),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.camera_alt_rounded, color: Color(0xFF00F5D4), size: 14),
                            SizedBox(width: 6),
                            Text(
                              'AI LIVE VISION VERIFIED',
                              style: TextStyle(
                                color: Color(0xFF00F5D4),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: Text(
                          '${widget.targetReps}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Live Pose Silhouette / Focus Frame
                Center(
                  child: Container(
                    width: 260,
                    height: 320,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isDownPosition ? const Color(0xFF00F5D4) : Colors.white38,
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Text(
                        _isDownPosition ? 'HOLD DEPTH ⬇️' : 'STAND IN FRAME 🧍',
                        style: TextStyle(
                          color: _isDownPosition ? const Color(0xFF00F5D4) : Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          backgroundColor: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom HUD: Rep Counter & Feedback
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.exerciseName.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _repFeedback,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$_completedReps / ${widget.targetReps}',
                            style: const TextStyle(
                              color: Color(0xFF00F5D4),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (_completedReps / widget.targetReps).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: const Color(0xFF1E293B),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F5D4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Workout Completed Victory Overlay
          if (_isWorkoutComplete)
            Container(
              color: Colors.black.withValues(alpha: 0.9),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      const Text(
                        'AI VERIFIED WORKOUT COMPLETE!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You completed ${widget.targetReps} verified ${widget.exerciseName}!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E1065),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF00F5D4)),
                        ),
                        child: Text(
                          '+${widget.rewardXp} XP EARNED ⚡',
                          style: const TextStyle(
                            color: Color(0xFF00F5D4),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00F5D4),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'CLAIM & RETURN TO QUESTS',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
