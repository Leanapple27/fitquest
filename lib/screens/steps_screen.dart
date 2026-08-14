import 'package:flutter/material.dart';
import 'package:health/health.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final Health _health = Health();

  int _steps = 0;
  bool _loading = true;
  bool _authorized = false;
  String _status = 'Connecting to Health Connect...';
  String _error = '';

  static const int _dailyGoal = 10000;

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _status = 'Requesting step access...';
      _error = '';
    });

    try {
      await _health.configure();

      bool authorized =
          await _health.hasPermissions(
            [HealthDataType.STEPS],
          ) ??
          false;

      if (!authorized) {
        authorized = await _health.requestAuthorization(
          [HealthDataType.STEPS],
        );
      }

      if (!authorized) {
        if (!mounted) return;

        setState(() {
          _authorized = false;
          _loading = false;
          _status = 'Step access not granted';
          _error =
              'Please allow FitQuest to read your steps in Health Connect.';
        });

        return;
      }

      final now = DateTime.now();

      final midnight = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final steps = await _health.getTotalStepsInInterval(
        midnight,
        now,
      );

      if (!mounted) return;

      setState(() {
        _authorized = true;
        _loading = false;
        _steps = steps ?? 0;
        _status = 'Connected to Health Connect';
      });
    } catch (error) {
      debugPrint('FITQUEST HEALTH ERROR: $error');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _authorized = false;
        _status = 'Unable to read steps';
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (_steps / _dailyGoal).clamp(0.0, 1.0);

    final calories =
        (_steps * 0.04).round();

    final distance =
        _steps * 0.00075;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Step Counter',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadSteps,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF302B63),
                  Color(0xFF51489A),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                const Text(
                  '👟',
                  style: TextStyle(
                    fontSize: 52,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "TODAY'S STEPS",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                if (_loading)
                  const SizedBox(
                    height: 64,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Text(
                    '$_steps',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                const Text(
                  'steps',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 24),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor:
                        Colors.white24,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  '$_steps / $_dailyGoal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _authorized
                      ? Icons.check_circle_rounded
                      : Icons.info_rounded,
                  color: _authorized
                      ? const Color(0xFF27733A)
                      : const Color(0xFF302B63),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    _status,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),

            Container(
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Text(
                _error,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _infoCard(
                  icon: '🔥',
                  title: 'Calories',
                  value: '$calories kcal',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _infoCard(
                  icon: '📍',
                  title: 'Distance',
                  value:
                      '${distance.toStringAsFixed(1)} km',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding:
                const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D8),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text(
                  '🏆',
                  style: TextStyle(
                    fontSize: 32,
                  ),
                ),

                SizedBox(width: 14),

                Expanded(
                  child: Text(
                    'Reach 10,000 steps today to complete your daily step goal!',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed:
                  _loading ? null : _loadSteps,
              icon: const Icon(
                Icons.sync_rounded,
              ),
              label: const Text(
                'SYNC STEPS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF302B63),
                foregroundColor:
                    Colors.white,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(
              fontSize: 28,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}