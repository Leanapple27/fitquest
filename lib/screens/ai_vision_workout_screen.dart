import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_state.dart';

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

  String _repFeedback = 'Stand back so your body is inside the frame';
  DateTime _lastRepTimestamp = DateTime.now();

  // Optical Motion Tracking
  int _frameCounter = 0;
  List<int>? _prevFrameSample;
  double _currentMotionY = 0.5; // Normalized 0.0 (top) to 1.0 (bottom)
  double _baselineY = 0.45;
  int _calibrationFrames = 0;

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
      if (_frameCounter % 3 != 0) return; // Process every 3rd frame for high responsiveness

      try {
        final plane = image.planes.first;
        final bytes = plane.bytes;
        final width = image.width;
        final height = image.height;

        // Subsample grid (16x16)
        const gridY = 16;
        const gridX = 16;
        final stepY = (height / gridY).floor();
        final stepX = (width / gridX).floor();

        final currentSample = List<int>.filled(gridY * gridX, 0);
        for (int y = 0; y < gridY; y++) {
          final rowOffset = y * stepY * width;
          for (int x = 0; x < gridX; x++) {
            final pixelIndex = rowOffset + (x * stepX);
            if (pixelIndex < bytes.length) {
              currentSample[y * gridX + x] = bytes[pixelIndex];
            }
          }
        }

        if (_prevFrameSample != null) {
          double totalDiff = 0;
          double weightedY = 0;

          for (int y = 0; y < gridY; y++) {
            for (int x = 0; x < gridX; x++) {
              final idx = y * gridX + x;
              final diff = (currentSample[idx] - _prevFrameSample![idx]).abs();
              if (diff > 18) { // Noise threshold
                totalDiff += diff;
                weightedY += y * diff;
              }
            }
          }

          if (totalDiff > 120) {
            final detectedY = (weightedY / totalDiff) / gridY;
            
            // Smooth motion centroid
            _currentMotionY = (_currentMotionY * 0.6) + (detectedY * 0.4);

            // Auto-calibration during initial standing frames
            if (_calibrationFrames < 15) {
              _calibrationFrames++;
              _baselineY = (_baselineY * 0.8) + (_currentMotionY * 0.2);
            } else {
              _processExerciseStateMachine();
            }
          }
        }

        _prevFrameSample = currentSample;

        if (mounted) {
          setState(() {});
        }
      } catch (_) {}
    });
  }

  void _processExerciseStateMachine() {
    final displacement = _currentMotionY - _baselineY;

    // SQUAT DOWN PHASE: User's motion centroid drops significantly
    if (!_isDownPosition && displacement > 0.12) {
      _isDownPosition = true;
      _repFeedback = 'Great depth! ⬇️ Now push through your heels!';
      HapticFeedback.selectionClick();
    }
    // SQUAT UP PHASE: User returns back to standing baseline
    else if (_isDownPosition && displacement < 0.05) {
      final now = DateTime.now();
      if (now.difference(_lastRepTimestamp).inMilliseconds > 650) {
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
  }

  void _manualRecordRep() {
    if (_isWorkoutComplete) return;

    final now = DateTime.now();
    if (now.difference(_lastRepTimestamp).inMilliseconds > 500) {
      _lastRepTimestamp = now;
      setState(() {
        _completedReps++;
        _repFeedback = 'Rep $_completedReps / ${widget.targetReps} Counted! 🔥';
      });

      HapticFeedback.mediumImpact();

      if (_completedReps >= widget.targetReps) {
        _triggerWorkoutSuccess();
      }
    }
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
          // 1. Full Bleed Camera Preview
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
                'Camera permission required for AI Vision Workout.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF00F5D4)),
            ),

          // 2. Full-Screen Edge-to-Edge AR Viewfinder Frame
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Top Header
                  Row(
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1B4B).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF00F5D4), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00F5D4).withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00F5D4),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.exerciseName.toUpperCase()} TRACKER',
                              style: const TextStyle(
                                color: Color(0xFF00F5D4),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${widget.targetReps} REPS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Large AR Viewport with Corner Brackets
                  Expanded(
                    child: Stack(
                      children: [
                        // AR Corner Brackets
                        _buildArBoundingBox(),

                        // Vertical Motion Meter on the right side
                        Positioned(
                          right: 12,
                          top: 40,
                          bottom: 40,
                          child: _buildVerticalMotionMeter(),
                        ),

                        // Center Pose Guidance Pill
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 14),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: (_isDownPosition
                                      ? const Color(0xFF00F5D4)
                                      : Colors.black.withValues(alpha: 0.75)),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isDownPosition ? Colors.white : Colors.white24,
                              ),
                            ),
                            child: Text(
                              _isDownPosition ? 'DEPTH REACHED ⬇️' : 'STAND IN FRAME 🧍',
                              style: TextStyle(
                                color: _isDownPosition ? Colors.black : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bottom HUD: Big Reps Counter + Progress + Manual Tap
                  _buildBottomHud(),
                ],
              ),
            ),
          ),

          // 3. Victory Celebration Dialog
          if (_isWorkoutComplete) _buildVictoryOverlay(),
        ],
      ),
    );
  }

  Widget _buildArBoundingBox() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isDownPosition
              ? const Color(0xFF00F5D4).withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildVerticalMotionMeter() {
    return Container(
      width: 18,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Depth threshold line
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Container(height: 2, color: const Color(0xFF00F5D4)),
          ),
          // Live Moving Centroid Dot
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            top: (_currentMotionY * 200).clamp(0.0, 200.0),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _isDownPosition ? const Color(0xFF00F5D4) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isDownPosition ? const Color(0xFF00F5D4) : Colors.white)
                        .withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomHud() {
    final progress = (_completedReps / widget.targetReps).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _repFeedback,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'AI Camera Auto-Detecting Motion',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF00F5D4).withValues(alpha: 0.5)),
                ),
                child: Text(
                  '$_completedReps / ${widget.targetReps}',
                  style: const TextStyle(
                    color: Color(0xFF00F5D4),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F5D4)),
            ),
          ),
          const SizedBox(height: 10),
          // Fail-Safe Manual Rep Tap Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dim room lighting?',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              GestureDetector(
                onTap: _manualRecordRep,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '+1 Rep Manually',
                    style: TextStyle(
                      color: Color(0xFF00F5D4),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVictoryOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.92),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
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
                'You completed all ${widget.targetReps} verified ${widget.exerciseName}!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E1065),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00F5D4), width: 1.2),
                ),
                child: Text(
                  '+${widget.rewardXp} XP CLAIMED ⚡',
                  style: const TextStyle(
                    color: Color(0xFF00F5D4),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 28),
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
                    'RETURN TO QUESTS',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
