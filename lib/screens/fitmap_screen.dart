import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_state.dart';
import '../services/fq_audio_service.dart';
import '../theme/fq_animations.dart';

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
  late final MapController _mapController;

  // Campus Base Coordinates
  static const LatLng _campusCenter = LatLng(12.9716, 77.5946);

  String _selectedFilter = 'ALL';
  Map<String, dynamic>? _selectedHotspot;
  bool _checkedIn = false;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _hotspots = [
    {
      'id': 'run_track',
      'emoji': '🏃',
      'title': 'Olympic Running Track',
      'subtitle': '8-Lane 400m Tartan Oval',
      'category': 'RUN',
      'location': LatLng(12.9726, 77.5936),
      'people': 14,
      'status': 'Moderate',
      'xp': 100,
      'distance': '180m',
      'walkTime': '2 min walk',
      'color': Color(0xFFEF4444),
      'buddies': [
        {'name': 'Rohan (Ignis)', 'avatar': '🔥', 'time': '6:00 PM'},
        {'name': 'Sneha (Vayu)', 'avatar': '🌪️', 'time': '6:15 PM'},
      ],
    },
    {
      'id': 'fit_gym',
      'emoji': '🏋️',
      'title': 'University Fitness Gym',
      'subtitle': 'Free Weights & Strength Arena',
      'category': 'GYM',
      'location': LatLng(12.9712, 77.5958),
      'people': 18,
      'status': 'Busy',
      'xp': 150,
      'distance': '320m',
      'walkTime': '4 min walk',
      'color': Color(0xFF8B5CF6),
      'buddies': [
        {'name': 'Karan (Ignis)', 'avatar': '🦁', 'time': '5:30 PM'},
        {'name': 'Aditya (Ignis)', 'avatar': '⚡', 'time': '6:30 PM'},
      ],
    },
    {
      'id': 'bball_court',
      'emoji': '🏀',
      'title': 'Indoor Basketball Court',
      'subtitle': 'Hardwood Court & Hoops',
      'category': 'SPORT',
      'location': LatLng(12.9730, 77.5955),
      'people': 8,
      'status': 'Available',
      'xp': 120,
      'distance': '250m',
      'walkTime': '3 min walk',
      'color': Color(0xFFF59E0B),
      'buddies': [
        {'name': 'Maya (Aqua)', 'avatar': '🌊', 'time': '5:45 PM'},
      ],
    },
    {
      'id': 'foot_ground',
      'emoji': '⚽',
      'title': 'Campus Football Stadium',
      'subtitle': 'FIFA Standard Turf Pitch',
      'category': 'SPORT',
      'location': LatLng(12.9705, 77.5938),
      'people': 22,
      'status': 'Busy',
      'xp': 120,
      'distance': '410m',
      'walkTime': '5 min walk',
      'color': Color(0xFF10B981),
      'buddies': [
        {'name': 'Vikram (Aqua)', 'avatar': '💧', 'time': '6:00 PM'},
        {'name': 'Kabir (Terra)', 'avatar': '🏋️', 'time': '6:00 PM'},
      ],
    },
    {
      'id': 'swim_pool',
      'emoji': '🏊',
      'title': 'Aquatic Swimming Complex',
      'subtitle': '50m Heated Olympic Pool',
      'category': 'SWIM',
      'location': LatLng(12.9702, 77.5960),
      'people': 6,
      'status': 'Available',
      'xp': 130,
      'distance': '480m',
      'walkTime': '6 min walk',
      'color': Color(0xFF0284C7),
      'buddies': [
        {'name': 'Priya (Aqua)', 'avatar': '🐬', 'time': '5:00 PM'},
      ],
    },
    {
      'id': 'yoga_lawn',
      'emoji': '🧘',
      'title': 'Zen Calisthenics & Yoga Lawn',
      'subtitle': 'Open Air Pull-up Bars & Lawn',
      'category': 'YOGA',
      'location': LatLng(12.9722, 77.5948),
      'people': 9,
      'status': 'Available',
      'xp': 100,
      'distance': '120m',
      'walkTime': '1 min walk',
      'color': Color(0xFF14B8A6),
      'buddies': [
        {'name': 'Ananya (Terra)', 'avatar': '🌱', 'time': '6:30 PM'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedHotspot = _hotspots.first;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredHotspots {
    return _hotspots.where((h) {
      final matchesFilter = _selectedFilter == 'ALL' || h['category'] == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          (h['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (h['subtitle'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _recenterCampus() {
    _mapController.move(_campusCenter, 16.2);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 0.8);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 0.8);
  }

  void _selectHotspot(Map<String, dynamic> hotspot) {
    setState(() {
      _selectedHotspot = hotspot;
      _checkedIn = false;
    });
    _mapController.move(hotspot['location'] as LatLng, 17.0);
  }

  void _handleCheckIn(Map<String, dynamic> hotspot) {
    setState(() => _checkedIn = true);
    final xpEarned = hotspot['xp'] as int;
    FQAudioService().playCheckIn();
    widget.appState.addXp(xpEarned);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Checked In at ${hotspot['title']}!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF151B3D)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+$xpEarned XP EARNED! ⚡',
                style: const TextStyle(
                  color: Color(0xFFD97706),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Your GPS hotspot check-in was verified by FairPlay engine. Keep moving to boost your Clan score!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF302B63),
                  foregroundColor: const Color(0xFF00F5D4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('AWESOME', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // 1. Real Interactive OpenStreetMap Engine
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _campusCenter,
              initialZoom: 16.2,
              minZoom: 13.0,
              maxZoom: 18.5,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // OpenStreetMap Standard Tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.fitquest',
                maxZoom: 19,
              ),

              // 50m Geofence Glowing Circles
              CircleLayer(
                circles: _filteredHotspots.map((h) {
                  final color = h['color'] as Color;
                  final isSelected = _selectedHotspot?['id'] == h['id'];

                  return CircleMarker(
                    point: h['location'] as LatLng,
                    radius: isSelected ? 55 : 45,
                    useRadiusInMeter: true,
                    color: color.withValues(alpha: isSelected ? 0.28 : 0.16),
                    borderColor: color.withValues(alpha: 0.8),
                    borderStrokeWidth: isSelected ? 2.5 : 1.5,
                  );
                }).toList(),
              ),

              // Hotspot 3D Pin Markers
              MarkerLayer(
                markers: _filteredHotspots.map((h) {
                  final isSelected = _selectedHotspot?['id'] == h['id'];
                  final color = h['color'] as Color;

                  return Marker(
                    point: h['location'] as LatLng,
                    width: isSelected ? 68 : 54,
                    height: isSelected ? 68 : 54,
                    child: GestureDetector(
                      onTap: () => _selectHotspot(h),
                      child: FQBounce(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF00F5D4) : color,
                              width: isSelected ? 3.5 : 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: isSelected ? 0.45 : 0.25),
                                blurRadius: isSelected ? 12 : 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              h['emoji'] as String,
                              style: TextStyle(fontSize: isSelected ? 26 : 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. Top Header & Search Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Search Bar & Back Button
                  Row(
                    children: [
                      FQBounce(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF151B3D)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (val) => setState(() => _searchQuery = val),
                                  decoration: const InputDecoration(
                                    hintText: 'Search campus gym, track, courts...',
                                    hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Category Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _filterPill('ALL', '🌍 All Zones'),
                        _filterPill('RUN', '🏃 Track'),
                        _filterPill('GYM', '🏋️ Gym'),
                        _filterPill('SPORT', '🏀 Courts'),
                        _filterPill('SWIM', '🏊 Pool'),
                        _filterPill('YOGA', '🧘 Lawn'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Right Floating Map Controls
          Positioned(
            right: 16,
            bottom: 230,
            child: Column(
              children: [
                _mapControlButton(
                  icon: Icons.my_location_rounded,
                  onTap: _recenterCampus,
                  tooltip: 'Recenter Campus',
                ),
                const SizedBox(height: 8),
                _mapControlButton(
                  icon: Icons.add_rounded,
                  onTap: _zoomIn,
                  tooltip: 'Zoom In',
                ),
                const SizedBox(height: 8),
                _mapControlButton(
                  icon: Icons.remove_rounded,
                  onTap: _zoomOut,
                  tooltip: 'Zoom Out',
                ),
              ],
            ),
          ),

          // 4. Bottom Selected Hotspot Info Sheet
          if (_selectedHotspot != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: FQFadeSlide(
                child: _buildHotspotDetailCard(_selectedHotspot!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterPill(String key, String label) {
    final isSelected = _selectedFilter == key;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FQBounce(
        onTap: () => setState(() => _selectedFilter = key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF302B63) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF00F5D4) : Colors.transparent,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00F5D4) : const Color(0xFF1E293B),
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _mapControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return FQBounce(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF151B3D), size: 20),
      ),
    );
  }

  Widget _buildHotspotDetailCard(Map<String, dynamic> hotspot) {
    final color = hotspot['color'] as Color;
    final buddies = hotspot['buddies'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(hotspot['emoji'], style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotspot['title'],
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF151B3D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${hotspot['distance']} • ${hotspot['walkTime']}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFD97706)),
                    Text(
                      '+${hotspot['xp']} XP',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_rounded, size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      '${hotspot['people']} Active Students',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hotspot['status'],
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FQBounce(
                  onTap: () => _handleCheckIn(hotspot),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF302B63), Color(0xFF0F0C29)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        _checkedIn ? 'CHECKED IN ✓' : 'CHECK IN (+${hotspot['xp']} XP) ⚡',
                        style: const TextStyle(
                          color: Color(0xFF00F5D4),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FQBounce(
                onTap: () => _showBuddyModal(hotspot, buddies),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.group_add_rounded, color: Color(0xFF302B63), size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBuddyModal(Map<String, dynamic> hotspot, List<dynamic> buddies) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(hotspot['emoji'], style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Text(
                  'Workout Buddies at ${hotspot['title']}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF151B3D)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...buddies.map((b) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Text(b['avatar'], style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          b['name'],
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B)),
                        ),
                      ),
                      Text(
                        b['time'],
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}