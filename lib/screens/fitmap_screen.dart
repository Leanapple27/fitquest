import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/fq_colors.dart';
import '../theme/fq_typography.dart';

class FitMapScreen extends StatefulWidget {
  final AppState appState;

  const FitMapScreen({
    super.key,
    required this.appState,
  });

  @override
  State<FitMapScreen> createState() => _FitMapScreenState();
}

class _FitMapScreenState extends State<FitMapScreen> {
  String? activeActivity;
  bool activityStarted = false;
  bool buddyJoined = false;
  bool hotspotJoined = false;
  String selectedFilter = 'ALL';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _activities = [
    {
      'id': 'run_track',
      'emoji': '🏃',
      'title': 'Running Track',
      'subtitle': 'Outdoor track',
      'people': 12,
      'status': 'Moderate',
      'xp': 100,
      'free': true,
      'type': 'RUN',
      'buddyCount': 5,
      'time': '6:00 PM',
      'relativeX': 0.16,
      'relativeY': 0.32,
    },
    {
      'id': 'swim_pool',
      'emoji': '🏊',
      'title': 'Swimming Area',
      'subtitle': 'Pool zone',
      'people': 7,
      'status': 'Available',
      'xp': 120,
      'free': false,
      'type': 'SWIM',
      'buddyCount': 3,
      'time': '5:30 PM',
      'relativeX': 0.18,
      'relativeY': 0.67,
    },
    {
      'id': 'bball_court',
      'emoji': '🏀',
      'title': 'Basketball Court',
      'subtitle': 'Indoor court',
      'people': 18,
      'status': 'Busy',
      'xp': 100,
      'free': true,
      'type': 'SPORT',
      'buddyCount': 8,
      'time': '5:30 PM',
      'relativeX': 0.82,
      'relativeY': 0.34,
    },
    {
      'id': 'fit_gym',
      'emoji': '🏋️',
      'title': 'Fitness Gym',
      'subtitle': 'Strength & fitness',
      'people': 9,
      'status': 'Moderate',
      'xp': 150,
      'free': false,
      'type': 'GYM',
      'buddyCount': 4,
      'time': '7:00 PM',
      'relativeX': 0.82,
      'relativeY': 0.66,
    },
    {
      'id': 'foot_ground',
      'emoji': '⚽',
      'title': 'Football Ground',
      'subtitle': 'Main field',
      'people': 15,
      'status': 'Busy',
      'xp': 120,
      'free': true,
      'type': 'SPORT',
      'buddyCount': 10,
      'time': '6:30 PM',
      'relativeX': 0.50,
      'relativeY': 0.46,
    },
  ];

  final List<Map<String, dynamic>> _demoBuddies = [
    {
      'name': 'Arjun',
      'emoji': '🏃',
      'activity': 'Running',
      'level': 7,
      'demo': true,
    },
    {
      'name': 'Maya',
      'emoji': '🧘',
      'activity': 'Yoga',
      'level': 9,
      'demo': true,
    },
    {
      'name': 'Rahul',
      'emoji': '🏋️',
      'activity': 'Gym',
      'level': 6,
      'demo': true,
    },
    {
      'name': 'Sara',
      'emoji': '🏀',
      'activity': 'Basketball',
      'level': 8,
      'demo': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final text = _searchController.text.trim();
      if (_searchQuery != text) {
        setState(() {
          _searchQuery = text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSmartBack() {
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      return;
    }
    if (activeActivity != null) {
      setState(() {
        activeActivity = null;
        activityStarted = false;
        buddyJoined = false;
      });
      return;
    }
    if (selectedFilter != 'ALL') {
      setState(() {
        selectedFilter = 'ALL';
      });
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  List<Map<String, dynamic>> _filteredActivities() {
    return _activities.where((activity) {
      // 1. Filter match
      bool matchesFilter = true;
      if (selectedFilter == 'FREE') {
        matchesFilter = activity['free'] == true;
      } else if (selectedFilter == 'RUN') {
        matchesFilter = activity['type'] == 'RUN';
      } else if (selectedFilter == 'SPORT') {
        matchesFilter = activity['type'] == 'SPORT';
      } else if (selectedFilter == 'GYM') {
        matchesFilter = activity['type'] == 'GYM';
      }

      if (!matchesFilter) return false;

      // 2. Search query match
      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      final title = (activity['title'] as String).toLowerCase();
      final subtitle = (activity['subtitle'] as String).toLowerCase();
      final type = (activity['type'] as String).toLowerCase();

      return title.contains(query) ||
          subtitle.contains(query) ||
          type.contains(query);
    }).toList();
  }

  Map<String, dynamic>? _activityByTitle(String title) {
    for (final activity in _activities) {
      if (activity['title'] == title) {
        return activity;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: FqColors.scaffold,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Interactive/Background Map
                    _buildMapBackground(),

                    // Map Markers
                    _buildMapMarkers(constraints.biggest),

                    // Top Bar & Controls
                    _buildTopControls(),

                    // Bottom Sheet Experience
                    _buildBottomContent(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // MAP BACKGROUND
  // ---------------------------------------------------------------------------

  Widget _buildMapBackground() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFFE7F0E2),
        child: CustomPaint(
          painter: _CampusMapPainter(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP CONTROLS (Top Bar + Live Search + Filter Chips)
  // ---------------------------------------------------------------------------

  Widget _buildTopControls() {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          Row(
            children: [
              _glassButton(
                icon: Icons.arrow_back_rounded,
                onTap: _handleSmartBack,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        size: 20,
                        color: FqColors.primary,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        'FitMap',
                        style: FqTypography.screenTitle(
                          color: FqColors.ink,
                        ).copyWith(fontSize: 17),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: FqColors.lavender,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_filteredActivities().length} Active',
                          style: const TextStyle(
                            color: FqColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _glassButton(
                icon: Icons.info_outline_rounded,
                onTap: _showInfo,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Live Search Bar
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF747887),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: FqColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search activity areas or sports...',
                      hintStyle: TextStyle(
                        color: Color(0xFF8B8E99),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Category Filter Row
          _buildFilterRow(),
        ],
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: FqColors.primary,
            size: 21,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = ['ALL', 'FREE', 'RUN', 'SPORT', 'GYM'];

    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: filters.map((filter) {
            final selected = selectedFilter == filter;

            return Padding(
              padding: const EdgeInsets.only(right: 7),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? FqColors.primary
                          : Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: FqColors.primary.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: selected ? Colors.white : FqColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAP MARKERS (Responsive coordinates)
  // ---------------------------------------------------------------------------

  Widget _buildMapMarkers(Size canvasSize) {
    final visible = _filteredActivities();

    return Stack(
      children: [
        // Activity Markers positioned relatively
        ..._activities.map((activity) {
          final isVisible = visible.any((a) => a['id'] == activity['id']);
          if (!isVisible) return const SizedBox.shrink();

          final rx = (activity['relativeX'] as num).toDouble();
          final ry = (activity['relativeY'] as num).toDouble();

          final posX = rx * canvasSize.width;
          final posY = ry * canvasSize.height;

          return Positioned(
            left: posX - 28,
            top: posY - 36,
            child: _buildActivityMarker(activity),
          );
        }),

        // Interactive Hotspot Badge
        Positioned(
          left: (canvasSize.width * 0.50) - 75,
          top: canvasSize.height * 0.55,
          child: GestureDetector(
            onTap: _showHotspotDetails,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: hotspotJoined
                    ? const Color(0xFFFFF0D6)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hotspotJoined
                      ? FqColors.energy
                      : const Color(0xFFDDE2D8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hotspotJoined ? '🔥' : '🏫',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'FitQuest Campus',
                        style: TextStyle(
                          color: Color(0xFF4F5649),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        hotspotJoined ? 'Hotspot Active (+20 XP)' : 'Tap to explore hotspot',
                        style: TextStyle(
                          color: hotspotJoined ? FqColors.energy : const Color(0xFF7A8373),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityMarker(Map<String, dynamic> activity) {
    final title = activity['title'] as String;
    final selected = activeActivity == title;

    return GestureDetector(
      onTap: () => _selectActivity(title),
      child: AnimatedScale(
        scale: selected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 56 : 48,
              height: selected ? 56 : 48,
              decoration: BoxDecoration(
                color: selected ? FqColors.primary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? FqColors.accent : Colors.white,
                  width: selected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: selected ? 0.22 : 0.12,
                    ),
                    blurRadius: selected ? 16 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  activity['emoji'] as String,
                  style: TextStyle(
                    fontSize: selected ? 26 : 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? FqColors.primary
                    : Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _shortTitle(title),
                style: TextStyle(
                  color: selected ? Colors.white : FqColors.ink,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortTitle(String title) {
    switch (title) {
      case 'Running Track':
        return 'Track';
      case 'Basketball Court':
        return 'Court';
      case 'Swimming Area':
        return 'Pool';
      case 'Fitness Gym':
        return 'Gym';
      case 'Football Ground':
        return 'Ground';
      default:
        return title;
    }
  }

  // ---------------------------------------------------------------------------
  // BOTTOM EXPERIENCE (Overlay sheet with empty state & smooth switching)
  // ---------------------------------------------------------------------------

  Widget _buildBottomContent() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 330),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        decoration: BoxDecoration(
          color: FqColors.scaffold,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: activeActivity == null
            ? _buildNearbyContent()
            : _buildSelectedActivity(),
      ),
    );
  }

  Widget _buildNearbyContent() {
    final activities = _filteredActivities();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dragHandle(),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                selectedFilter == 'ALL'
                    ? 'Nearby activities'
                    : '$selectedFilter activities',
                style: FqTypography.screenTitle(
                  color: FqColors.ink,
                ).copyWith(fontSize: 17),
              ),
            ),
            _smallActionButton(
              icon: Icons.people_alt_rounded,
              label: 'Buddies',
              onTap: _openBuddyFinder,
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (activities.isEmpty)
          _buildEmptyState()
        else
          SizedBox(
            height: 105,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _buildNearbyCard(activities[index]);
              },
            ),
          ),

        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _compactStat(
                icon: Icons.local_fire_department_rounded,
                value: '${widget.appState.streak}',
                label: 'day streak',
                iconColor: FqColors.energy,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _compactStat(
                icon: Icons.bolt_rounded,
                value: '${widget.appState.xp}',
                label: 'XP earned',
                iconColor: FqColors.primary,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _compactStat(
                icon: Icons.emoji_events_rounded,
                value: '4',
                label: 'campus rank',
                iconColor: const Color(0xFFE39A16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 105,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E8EE)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: FqColors.lavender,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: FqColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No activities found',
                  style: TextStyle(
                    color: FqColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No matches for "$_searchQuery"'
                      : 'No activities for $selectedFilter filter',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF747887),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                selectedFilter = 'ALL';
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: FqColors.primary,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _dragHandle() {
    return Container(
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildNearbyCard(Map<String, dynamic> activity) {
    final status = activity['status'] as String;
    final statusColor = _statusColor(status);

    return GestureDetector(
      onTap: () => _selectActivity(activity['title'] as String),
      child: Container(
        width: 205,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: const Color(0xFFE7E8EE),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: FqColors.lavender,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text(
                  activity['emoji'] as String,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: FqColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${activity['people']} active',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '+${activity['xp']} XP',
                        style: const TextStyle(
                          color: FqColors.energy,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (activity['free'] == true) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: FqColors.successSurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'FREE',
                            style: TextStyle(
                              color: FqColors.success,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedActivity() {
    final activity = activeActivity ?? 'Activity';
    final data = _activityByTitle(activity);
    final reward = _xpForActivity(activity);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dragHandle(),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: FqColors.lavender,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  data?['emoji'] as String? ?? '🏃',
                  style: const TextStyle(fontSize: 25),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: FqColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${data?['subtitle'] ?? 'Activity area'} • '
                    '${data?['people'] ?? 0} active'
                    '${data?['free'] == true ? ' • Free access' : ''}',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  activeActivity = null;
                  activityStarted = false;
                  buddyJoined = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F1F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _detailPill(
              Icons.bolt_rounded,
              '+$reward XP',
              FqColors.energy,
            ),
            const SizedBox(width: 7),
            _detailPill(
              Icons.people_alt_rounded,
              '${data?['buddyCount'] ?? 0} buddies',
              FqColors.primaryMid,
            ),
            const SizedBox(width: 7),
            _detailPill(
              Icons.circle,
              data?['status'] as String? ?? 'Available',
              _statusColor(data?['status'] as String? ?? 'Available'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (buddyJoined)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EC),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.people_alt_rounded,
                  size: 16,
                  color: FqColors.success,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Fitness buddy joined • +10 bonus XP on completion',
                    style: TextStyle(
                      color: FqColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: activityStarted
                      ? _completeActivity
                      : () {
                          setState(() {
                            activityStarted = true;
                          });
                          _showMessage('Activity started at $activity. Keep moving!');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activityStarted
                        ? FqColors.success
                        : FqColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(
                    activityStarted ? 'COMPLETE ACTIVITY' : 'START ACTIVITY',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 45,
              width: 48,
              child: OutlinedButton(
                onPressed: _openBuddyFinder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: FqColors.primary,
                  side: const BorderSide(
                    color: Color(0xFFD7D8E2),
                  ),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  size: 19,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailPill(
    IconData icon,
    String text,
    Color color,
  ) {
    return Expanded(
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: color,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: FqColors.lavender,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: FqColors.primary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: FqColors.primary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactStat({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      height: 47,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE7E8EE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: FqColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUDDY MODAL
  // ---------------------------------------------------------------------------

  void _openBuddyFinder() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.70,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6FA),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _dragHandle()),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Find a Fitness Buddy',
                      style: TextStyle(
                        color: FqColors.ink,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Join an activity with people who opted in.',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _demoBuddies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final buddy = _demoBuddies[index];

                    return Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: const Color(0xFFE7E8EE),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: FqColors.lavender,
                            child: Text(
                              buddy['emoji'] as String,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      buddy['name'] as String,
                                      style: const TextStyle(
                                        color: FqColors.ink,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    _demoTag(),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${buddy['activity']} • '
                                  'Level ${buddy['level']}',
                                  style: const TextStyle(
                                    color: Colors.black45,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _joinBuddy(
                                buddy['name'] as String,
                                buddy['activity'] as String,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FqColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 9,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'JOIN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FqColors.lavender,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      color: FqColors.primary,
                      size: 19,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo participants are simulated for the prototype. '
                        'Real matching can be connected with school privacy controls.',
                        style: TextStyle(
                          color: FqColors.primaryMid,
                          fontSize: 9.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _demoTag() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'DEMO',
        style: TextStyle(
          color: Colors.black45,
          fontSize: 7,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SELECTION & ACTIONS
  // ---------------------------------------------------------------------------

  void _selectActivity(String activity) {
    setState(() {
      activeActivity = activity;
      activityStarted = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Busy':
        return const Color(0xFFE49A2D);
      case 'Moderate':
        return const Color(0xFF4B8F52);
      default:
        return FqColors.success;
    }
  }

  int _xpForActivity(String activity) {
    switch (activity) {
      case 'Running Track':
        return 100;
      case 'Swimming Area':
        return 120;
      case 'Basketball Court':
        return 100;
      case 'Fitness Gym':
        return 150;
      case 'Football Ground':
        return 120;
      default:
        return 100;
    }
  }

  void _joinBuddy(String name, String activity) {
    setState(() {
      buddyJoined = true;
      activeActivity = _activityTitle(activity);
      activityStarted = false;
    });

    _showMessage(
      'You joined $name for $activity. +10 Buddy Bonus on completion!',
    );
  }

  String _activityTitle(String activity) {
    switch (activity) {
      case 'Running':
        return 'Running Track';
      case 'Gym':
        return 'Fitness Gym';
      case 'Basketball':
        return 'Basketball Court';
      case 'Yoga':
        return 'Recovery Yoga';
      default:
        return 'Running Track';
    }
  }

  void _completeActivity() {
    final activity = activeActivity ?? 'Activity';
    final reward = _xpForActivity(activity);
    final hotspotBonus = hotspotJoined ? 20 : 0;
    final totalReward = reward + (buddyJoined ? 10 : 0) + hotspotBonus;

    widget.appState.addXp(totalReward);

    setState(() {
      activityStarted = false;
      buddyJoined = false;
    });

    _showMessage(
      '$activity complete! +$totalReward XP'
      '${hotspotBonus > 0 ? ' (Includes +20 hotspot bonus)' : ''}',
    );
  }

  // ---------------------------------------------------------------------------
  // HOTSPOT DIALOG & ABOUT
  // ---------------------------------------------------------------------------

  void _showHotspotDetails() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F6FA),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _dragHandle()),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0D6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            '🔥',
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Central Sports Ground',
                              style: TextStyle(
                                color: FqColors.ink,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '32 FitQuest campus activities this week',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _hotspotStat('18', 'runs'),
                      _hotspotStat('9', 'games'),
                      _hotspotStat('5', 'workouts'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          hotspotJoined = !hotspotJoined;
                        });
                        setSheetState(() {});
                        Navigator.pop(context);

                        _showMessage(
                          hotspotJoined
                              ? 'Hotspot challenge joined! +20 XP on completion.'
                              : 'Hotspot challenge left.',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hotspotJoined
                            ? const Color(0xFFEAF6EC)
                            : FqColors.primary,
                        foregroundColor: hotspotJoined
                            ? FqColors.success
                            : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Text(
                        hotspotJoined
                            ? 'JOINED • +20 XP BONUS ACTIVE'
                            : 'JOIN HOTSPOT CHALLENGE (+20 XP)',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _hotspotStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: FqColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'About FitMap',
            style: TextStyle(
              color: FqColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'FitMap helps students discover campus activities, '
            'find opt-in fitness buddies, join activity groups, '
            'earn XP, and explore FitQuest hotspots.\n\n'
            'All locations are campus areas with privacy preserved.',
            style: TextStyle(
              height: 1.45,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: FqColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: FqColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
  }
}

// -----------------------------------------------------------------------------
// CAMPUS MAP PAINTER
// -----------------------------------------------------------------------------

class _CampusMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFD3DDCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final roadInnerPaint = Paint()
      ..color = const Color(0xFFE9EFE4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    final fieldPaint = Paint()
      ..color = const Color(0xFFDCE8D5)
      ..style = PaintingStyle.fill;

    final waterPaint = Paint()
      ..color = const Color(0xFFCFE3E7)
      ..style = PaintingStyle.fill;

    final buildingPaint = Paint()
      ..color = const Color(0xFFD9DED4)
      ..style = PaintingStyle.fill;

    final buildingLinePaint = Paint()
      ..color = const Color(0xFFC4CCC0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Large grass areas.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.04,
          size.height * 0.23,
          size.width * 0.34,
          size.height * 0.22,
        ),
        const Radius.circular(28),
      ),
      fieldPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.58,
          size.height * 0.28,
          size.width * 0.34,
          size.height * 0.24,
        ),
        const Radius.circular(28),
      ),
      fieldPaint,
    );

    // Water area.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.06,
          size.height * 0.64,
          size.width * 0.24,
          size.height * 0.13,
        ),
        const Radius.circular(24),
      ),
      waterPaint,
    );

    // Buildings.
    final buildings = [
      Rect.fromLTWH(
        size.width * 0.40,
        size.height * 0.23,
        size.width * 0.17,
        size.height * 0.13,
      ),
      Rect.fromLTWH(
        size.width * 0.40,
        size.height * 0.42,
        size.width * 0.17,
        size.height * 0.12,
      ),
      Rect.fromLTWH(
        size.width * 0.35,
        size.height * 0.68,
        size.width * 0.25,
        size.height * 0.13,
      ),
      Rect.fromLTWH(
        size.width * 0.70,
        size.height * 0.60,
        size.width * 0.18,
        size.height * 0.11,
      ),
    ];

    for (final rect in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(12),
        ),
        buildingPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(12),
        ),
        buildingLinePaint,
      );
    }

    // Roads.
    final horizontalRoad = Path()
      ..moveTo(0, size.height * 0.57)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.54,
        size.width * 0.65,
        size.height * 0.59,
        size.width,
        size.height * 0.55,
      );

    final verticalRoad = Path()
      ..moveTo(size.width * 0.48, size.height * 0.12)
      ..cubicTo(
        size.width * 0.46,
        size.height * 0.30,
        size.width * 0.53,
        size.height * 0.68,
        size.width * 0.50,
        size.height,
      );

    canvas.drawPath(horizontalRoad, roadPaint);
    canvas.drawPath(horizontalRoad, roadInnerPaint);
    canvas.drawPath(verticalRoad, roadPaint);
    canvas.drawPath(verticalRoad, roadInnerPaint);

    // Small walking paths.
    final pathPaint = Paint()
      ..color = const Color(0xFFCFD8C9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final walkingPath = Path()
      ..moveTo(size.width * 0.10, size.height * 0.47)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.50,
        size.width * 0.38,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.53,
        size.height * 0.24,
        size.width * 0.78,
        size.height * 0.35,
      );

    canvas.drawPath(walkingPath, pathPaint);

    // Trees / green points.
    final treePaint = Paint()
      ..color = const Color(0xFFB9CCAF)
      ..style = PaintingStyle.fill;

    final treePositions = [
      Offset(size.width * 0.08, size.height * 0.20),
      Offset(size.width * 0.24, size.height * 0.19),
      Offset(size.width * 0.78, size.height * 0.22),
      Offset(size.width * 0.90, size.height * 0.46),
      Offset(size.width * 0.33, size.height * 0.83),
      Offset(size.width * 0.82, size.height * 0.79),
    ];

    for (final position in treePositions) {
      canvas.drawCircle(position, 7, treePaint);
      canvas.drawCircle(
        position.translate(4, -3),
        5,
        treePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CampusMapPainter oldDelegate) {
    return false;
  }
}