import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class SnapScreen extends StatefulWidget {
  const SnapScreen({super.key});

  @override
  State<SnapScreen> createState() => _SnapScreenState();
}

class _SnapScreenState extends State<SnapScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;

  bool _loading = true;
  bool _cameraError = false;
  bool _avatarMode = false;
  bool _showStats = true;

  int _selectedFilter = 0;
  String _privacy = 'Only Me';

  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _filters = [
    {
      'name': 'Running',
      'emoji': '🏃',
      'subtitle': 'RUN MODE',
      'color': Color(0xFFFF6B35),
      'xp': '+50 XP',
    },
    {
      'name': 'Gym',
      'emoji': '🏋️',
      'subtitle': 'BEAST MODE',
      'color': Color(0xFF302B63),
      'xp': '+100 XP',
    },
    {
      'name': 'Cycling',
      'emoji': '🚴',
      'subtitle': 'RIDE MODE',
      'color': Color(0xFF00A896),
      'xp': '+75 XP',
    },
    {
      'name': 'Yoga',
      'emoji': '🧘',
      'subtitle': 'ZEN MODE',
      'color': Color(0xFF7B61FF),
      'xp': '+60 XP',
    },
    {
      'name': 'Sports',
      'emoji': '🏸',
      'subtitle': 'SPORT MODE',
      'color': Color(0xFFEF476F),
      'xp': '+80 XP',
    },
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (!mounted) return;

        setState(() {
          _loading = false;
          _cameraError = true;
        });
        return;
      }

      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _cameraError = true;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentFilter =>
      _filters[_selectedFilter];

  Color get _filterColor =>
      _currentFilter['color'] as Color;

  Future<void> _takeSnap() async {
    if (_avatarMode) {
      _showPreviewDialog(null);
      return;
    }

    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized) {
      _showPreviewDialog(null);
      return;
    }

    try {
      final image = await controller.takePicture();

      if (!mounted) return;

      _showPreviewDialog(image);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not capture Snap. Try again.',
          ),
        ),
      );
    }
  }

  void _showPreviewDialog(XFile? image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _buildPreviewSheet(
          sheetContext,
          image,
        );
      },
    );
  }

  Widget _buildPreviewSheet(
    BuildContext sheetContext,
    XFile? image,
  ) {
    final filter = _currentFilter;

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 720,
      ),
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text(
                    'Your Snap ✨',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF151B3D),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPreviewImage(image),
              const SizedBox(height: 18),
              const Text(
                'Who can see this?',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Color(0xFF151B3D),
                ),
              ),
              const SizedBox(height: 9),
              _buildPrivacySelector(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _previewInfo(
                      Icons.local_fire_department_rounded,
                      '7 day streak',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _previewInfo(
                      Icons.star_rounded,
                      filter['xp'] as String,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        backgroundColor:
                            const Color(0xFF302B63),
                        content: Text(
                          '✨ Snap saved • $_privacy',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.send_rounded,
                  ),
                  label: const Text(
                    'Save & Share Snap',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filterColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewImage(XFile? image) {
    final filter = _currentFilter;

    return Container(
      height: 360,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _filterColor,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            Image.file(
              File(image.path),
              fit: BoxFit.cover,
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _filterColor,
                    Colors.black,
                  ],
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.12),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 18,
            child: _glassBadge(
              '${filter['emoji']} ${filter['name']}',
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: _glassBadge(
              '🔒 $_privacy',
            ),
          ),
          if (image == null)
            Center(
              child: Text(
                filter['emoji'] as String,
                style: const TextStyle(
                  fontSize: 92,
                ),
              ),
            ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        filter['subtitle'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '🔥 7 DAY STREAK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        filter['xp'] as String,
                        style: const TextStyle(
                          color: Color(0xFFFFD166),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                _privacyMiniBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _privacyMiniBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        _privacy,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _previewInfo(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: _filterColor,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySelector() {
    final options = [
      ('🔒', 'Only Me'),
      ('👥', 'Friends'),
      ('🏠', 'My House'),
      ('🌎', 'Community'),
    ];

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: options.map((option) {
        final selected =
            _privacy == option.$2;

        return ChoiceChip(
          selected: selected,
          label: Text(
            '${option.$1} ${option.$2}',
          ),
          onSelected: (_) {
            setState(() {
              _privacy = option.$2;
            });
          },
          selectedColor:
              const Color(0xFF302B63),
          labelStyle: TextStyle(
            color: selected
                ? Colors.white
                : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = _currentFilter;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildCamera(),
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black
                            .withValues(alpha: 0.38),
                        Colors.transparent,
                        Colors.black
                            .withValues(alpha: 0.70),
                      ],
                      stops: const [
                        0.0,
                        0.48,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 12,
              left: 15,
              right: 15,
              child: Row(
                children: [
                  _roundButton(
                    icon: Icons.close_rounded,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'FITQUEST SNAP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  _roundButton(
                    icon: _avatarMode
                        ? Icons.face_rounded
                        : Icons
                            .face_retouching_natural_rounded,
                    onTap: () {
                      setState(() {
                        _avatarMode = !_avatarMode;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _roundButton(
                    icon: _showStats
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    onTap: () {
                      setState(() {
                        _showStats = !_showStats;
                      });
                    },
                  ),
                ],
              ),
            ),

            Positioned(
              top: 78,
              left: 18,
              child: AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 250),
                child: _glassBadge(
                  '${filter['emoji']} '
                  '${(filter['name'] as String).toUpperCase()}',
                ),
              ),
            ),

            Positioned(
              top: 78,
              right: 18,
              child: GestureDetector(
                onTap: _showPrivacySheet,
                child: _glassBadge(
                  '🔒 $_privacy',
                ),
              ),
            ),

            if (_showStats && !_avatarMode)
              Positioned(
                left: 18,
                top: 145,
                child: _buildStatsOverlay(),
              ),

            if (_avatarMode)
              Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale =
                        1.0 +
                        (_pulseController.value * 0.04);

                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _filterColor,
                              Colors.black,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _filterColor
                                  .withValues(alpha: 0.45),
                              blurRadius: 35,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            filter['emoji'] as String,
                            style: const TextStyle(
                              fontSize: 80,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'AVATAR MODE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Your face stays private 🔒',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 139,
              child: SizedBox(
                height: 92,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    return _buildFilterItem(index);
                  },
                ),
              ),
            ),

            Positioned(
              bottom: 27,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  _roundButton(
                    icon: Icons.photo_library_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Gallery sharing can be added later.',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 28),
                  GestureDetector(
                    onTap: _takeSnap,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale =
                            1.0 +
                            (_pulseController.value * 0.035);

                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 82,
                        height: 82,
                        padding:
                            const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _filterColor
                                  .withValues(alpha: 0.45),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _filterColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 31,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  _roundButton(
                    icon: Icons.lock_rounded,
                    onTap: _showPrivacySheet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverlay() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            '🔥 7 DAY STREAK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            '⭐ +50 XP',
            style: TextStyle(
              color: Color(0xFFFFD166),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            '🏆 FITNESS EXPLORER',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(int index) {
    final item = _filters[index];
    final selected =
        index == _selectedFilter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            AnimatedContainer(
              duration:
                  const Duration(milliseconds: 220),
              width: selected ? 65 : 55,
              height: selected ? 65 : 55,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? Colors.white
                      : Colors.white38,
                  width: selected ? 3 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color:
                              (item['color'] as Color)
                                  .withValues(
                            alpha: 0.55,
                          ),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  item['emoji'] as String,
                  style: TextStyle(
                    fontSize:
                        selected ? 31 : 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item['name'] as String,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: selected
                    ? FontWeight.w900
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FIXED CAMERA PREVIEW
  // ============================================================

  Widget _buildCamera() {
    if (_avatarMode) {
      return AnimatedContainer(
        duration:
            const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _filterColor,
              Colors.black,
            ],
          ),
        ),
      );
    }

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_cameraError ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF302B63),
              Color(0xFF151B3D),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 60,
              ),
              SizedBox(height: 14),
              Text(
                'Camera unavailable',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Avatar Mode is still available',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _controller!;

    return ClipRect(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.center,
          child: SizedBox(
            width:
                controller.value.previewSize?.height ??
                    1080,
            height:
                controller.value.previewSize?.width ??
                    1920,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  void _showPrivacySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        final options = [
          ('🔒', 'Only Me', 'Safest option'),
          ('👥', 'Friends', 'Only approved friends'),
          ('🏠', 'My House', 'Your FitQuest house'),
          ('🌎', 'Community', 'Everyone in FitQuest'),
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Snap Privacy 🔒',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF151B3D),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Choose who can see your fitness Snap.',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                ...options.map(
                  (option) {
                    final selected =
                        _privacy == option.$2;

                    return ListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      leading: Text(
                        option.$1,
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      title: Text(
                        option.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        option.$3,
                      ),
                      trailing: selected
                          ? const Icon(
                              Icons
                                  .check_circle_rounded,
                              color:
                                  Color(0xFF302B63),
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _privacy = option.$2;
                        });

                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFF5F6FA),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color:
                            Color(0xFF302B63),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your privacy comes first. '
                          'You never need to share your face.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}