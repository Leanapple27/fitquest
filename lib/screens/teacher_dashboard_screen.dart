import 'package:flutter/material.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends State<TeacherDashboardScreen> {
  String selectedClass = 'Class 8-A';
  String selectedAssessment = '100m Run';

  final List<Map<String, dynamic>> students = [
    {
      'name': 'Aarav',
      'emoji': '🧑',
      'present': true,
      'participation': 92,
      'speed': 84,
      'strength': 72,
      'endurance': 81,
      'flexibility': 69,
      'teamwork': 90,
      'run': 15.2,
      'pushups': 18,
      'note':
          'Strong overall fitness. Keep improving flexibility.',
    },
    {
      'name': 'Maya',
      'emoji': '👩',
      'present': true,
      'participation': 88,
      'speed': 91,
      'strength': 61,
      'endurance': 73,
      'flexibility': 86,
      'teamwork': 94,
      'run': 16.1,
      'pushups': 14,
      'note':
          'Excellent teamwork. Add beginner strength activities.',
    },
    {
      'name': 'Rahul',
      'emoji': '🧑',
      'present': true,
      'participation': 61,
      'speed': 68,
      'strength': 74,
      'endurance': 52,
      'flexibility': 58,
      'teamwork': 76,
      'run': 17.4,
      'pushups': 20,
      'note':
          'Needs support with endurance and regular participation.',
    },
    {
      'name': 'Sara',
      'emoji': '👩',
      'present': true,
      'participation': 95,
      'speed': 87,
      'strength': 82,
      'endurance': 89,
      'flexibility': 79,
      'teamwork': 91,
      'run': 15.8,
      'pushups': 24,
      'note':
          'Consistent performer. Ready for advanced activities.',
    },
    {
      'name': 'Dev',
      'emoji': '🧑',
      'present': false,
      'participation': 48,
      'speed': 55,
      'strength': 59,
      'endurance': 46,
      'flexibility': 63,
      'teamwork': 68,
      'run': 18.2,
      'pushups': 10,
      'note':
          'Low recent participation. Check in and encourage gradual activity.',
    },
    {
      'name': 'Priya',
      'emoji': '👩',
      'present': true,
      'participation': 90,
      'speed': 83,
      'strength': 76,
      'endurance': 85,
      'flexibility': 91,
      'teamwork': 88,
      'run': 16.0,
      'pushups': 21,
      'note':
          'Very balanced fitness profile.',
    },
    {
      'name': 'Kabir',
      'emoji': '🧑',
      'present': true,
      'participation': 79,
      'speed': 74,
      'strength': 88,
      'endurance': 71,
      'flexibility': 55,
      'teamwork': 82,
      'run': 16.8,
      'pushups': 27,
      'note':
          'Strong strength profile. Work on mobility and flexibility.',
    },
    {
      'name': 'Ananya',
      'emoji': '👩',
      'present': true,
      'participation': 86,
      'speed': 79,
      'strength': 66,
      'endurance': 80,
      'flexibility': 88,
      'teamwork': 93,
      'run': 16.5,
      'pushups': 16,
      'note':
          'Excellent teamwork and flexibility.',
    },
  ];

  final List<String> assessmentTypes = [
    '100m Run',
    'Push-ups',
    'Endurance',
    'Flexibility',
    'Participation',
  ];

  @override
  Widget build(BuildContext context) {
    final presentCount =
        students.where((s) => s['present'] == true).length;

    final attentionCount =
        students.where(_needsAttention).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF151B3D),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showTeacherInfo,
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF151B3D),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTeacherHeader(),

            const SizedBox(height: 18),

            _buildClassSelector(),

            const SizedBox(height: 18),

            _buildOverviewCard(presentCount),

            const SizedBox(height: 20),

            _sectionTitle('TODAY\'S PE SESSION'),

            const SizedBox(height: 10),

            _buildSessionCard(),

            const SizedBox(height: 20),

            _sectionTitle('QUICK ACTIONS'),

            const SizedBox(height: 10),

            _buildQuickActions(),

            const SizedBox(height: 20),

            _buildNoPhoneCard(),

            const SizedBox(height: 20),

            _sectionTitle('CLASS FITNESS'),

            const SizedBox(height: 10),

            _buildFitnessOverview(),

            const SizedBox(height: 20),

            _sectionTitle('STUDENTS NEEDING ATTENTION'),

            const SizedBox(height: 10),

            _buildAttentionCard(attentionCount),

            const SizedBox(height: 20),

            _sectionTitle('RECENT PE RECORDS'),

            const SizedBox(height: 10),

            ...students.take(4).map(_buildRecentStudent),

            const SizedBox(height: 20),

            _sectionTitle('TEACHER GUIDANCE'),

            const SizedBox(height: 10),

            _buildGuidanceCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF302B63),
            Color(0xFF51489A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Text(
              '👩‍🏫',
              style: TextStyle(fontSize: 31),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning, Ma\'am! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'PE Teacher • FitQuest School',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.groups_rounded,
            color: Color(0xFF302B63),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'My Class',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF151B3D),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedClass,
              items: const [
                DropdownMenuItem(
                  value: 'Class 8-A',
                  child: Text('Class 8-A'),
                ),
                DropdownMenuItem(
                  value: 'Class 8-B',
                  child: Text('Class 8-B'),
                ),
                DropdownMenuItem(
                  value: 'Class 9-A',
                  child: Text('Class 9-A'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedClass = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(int presentCount) {
    final percentage = students.isEmpty
        ? 0
        : (presentCount / students.length * 100).round();

    final averageFitness = _averageFitness();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'CLASS OVERVIEW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.black45,
                ),
              ),
              Spacer(),
              Text(
                'Today',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black38,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _overviewStat(
                  '👥',
                  '$presentCount/${students.length}',
                  'Present',
                ),
              ),
              Expanded(
                child: _overviewStat(
                  '🏃',
                  '$percentage%',
                  'Participation',
                ),
              ),
              Expanded(
                child: _overviewStat(
                  '📊',
                  '$averageFitness%',
                  'Avg fitness',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 9,
              backgroundColor:
                  const Color(0xFFE8E8EE),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Color(0xFF302B63),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '$percentage% of students participated today',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewStat(
    String emoji,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 21),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Color(0xFF302B63),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.black45,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEDEBFF),
            Color(0xFFF7F6FF),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Text(
            '🏃',
            style: TextStyle(fontSize: 28),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Endurance & Running',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF151B3D),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Running Track • 45 minutes',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Focus: endurance, pacing and teamwork.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF51489A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'TODAY',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Color(0xFF51489A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionCard(
                emoji: '✅',
                title: 'Attendance',
                subtitle: 'Mark today',
                onTap: _openAttendance,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                emoji: '📊',
                title: 'Assessment',
                subtitle: 'Record fitness',
                onTap: _openAssessment,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _actionCard(
                emoji: '👥',
                title: 'Students',
                subtitle: 'View class',
                onTap: _openStudents,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                emoji: '🏆',
                title: 'Leaderboard',
                subtitle: 'Class rankings',
                onTap: _openLeaderboard,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EFFF),
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF151B3D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPhoneCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFB9DEC2),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            '📋',
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Students without phones',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF205C32),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Teachers can record and verify physical '
                  'activity for students who do not have a '
                  'personal smartphone.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Color(0xFF477A55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessOverview() {
    final values = {
      'Speed': _average('speed'),
      'Strength': _average('strength'),
      'Endurance': _average('endurance'),
      'Flexibility': _average('flexibility'),
      'Teamwork': _average('teamwork'),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: values.entries.map((entry) {
          final value = entry.value;

          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF151B3D),
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      minHeight: 8,
                      backgroundColor:
                          const Color(0xFFE9E9EF),
                      valueColor:
                          const AlwaysStoppedAnimation<
                              Color>(
                        Color(0xFF51489A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                SizedBox(
                  width: 30,
                  child: Text(
                    '$value%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF51489A),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAttentionCard(int count) {
    final needsHelp =
        students.where(_needsAttention).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFD9A5),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '💡',
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$count student${count == 1 ? '' : 's'} may need support',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF805318),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          const Text(
            'Use this as a coaching prompt, not a performance label.',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF946A32),
            ),
          ),

          const SizedBox(height: 12),

          ...needsHelp.take(3).map((student) {
            return InkWell(
              onTap: () => _openStudent(student),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(
                      student['emoji'] as String,
                      style:
                          const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        student['name'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF151B3D),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentStudent(
    Map<String, dynamic> student,
  ) {
    return GestureDetector(
      onTap: () => _openStudent(student),
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor:
                  const Color(0xFFEDEBFF),
              child: Text(
                student['emoji'] as String,
                style:
                    const TextStyle(fontSize: 21),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF151B3D),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '100m: ${(student['run'] as num).toStringAsFixed(1)}s • '
                    '${student['pushups']} push-ups',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceCard() {
    final weakest = _weakestArea();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEBFF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            '🧠',
            style: TextStyle(fontSize: 29),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Class coaching insight',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF302B63),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$weakest is currently the lowest class '
                  'fitness area. Consider adding short, '
                  'beginner-friendly activities focused '
                  'on this area.',
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.45,
                    color: Color(0xFF51489A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _weakestArea() {
    final values = {
      'Speed': _average('speed'),
      'Strength': _average('strength'),
      'Endurance': _average('endurance'),
      'Flexibility': _average('flexibility'),
      'Teamwork': _average('teamwork'),
    };

    return values.entries.reduce(
      (a, b) => a.value <= b.value ? a : b,
    ).key;
  }

  int _average(String key) {
    if (students.isEmpty) return 0;

    final total = students.fold<int>(
      0,
      (total, student) =>
          total + (student[key] as num).toInt(),
    );

    return (total / students.length).round();
  }

  int _averageFitness() {
    if (students.isEmpty) return 0;

    var total = 0;

    for (final student in students) {
      total +=
          ((student['speed'] as num).toInt() +
                  (student['strength'] as num).toInt() +
                  (student['endurance'] as num).toInt() +
                  (student['flexibility'] as num).toInt() +
                  (student['teamwork'] as num).toInt()) ~/
              5;
    }

    return (total / students.length).round();
  }

  bool _needsAttention(
    Map<String, dynamic> student,
  ) {
    return (student['participation'] as num)
                .toInt() <
            65 ||
        (student['endurance'] as num).toInt() < 55;
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: Colors.black45,
      ),
    );
  }

  void _openAttendance() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheet(
          title: 'Attendance • $selectedClass',
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final presentCount = students
                  .where((s) => s['present'] == true)
                  .length;

              return Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '$presentCount/${students.length} present',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF302B63),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            for (final student in students) {
                              student['present'] = true;
                            }
                          });

                          setState(() {});
                        },
                        child: const Text(
                          'MARK ALL PRESENT',
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      children: students.map((student) {
                        final present =
                            student['present'] == true;

                        return CheckboxListTile(
                          value: present,
                          onChanged: (value) {
                            setSheetState(() {
                              student['present'] =
                                  value ?? false;
                            });

                            setState(() {});
                          },
                          title: Text(
                            student['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            present
                                ? 'Present'
                                : 'Absent',
                          ),
                          secondary: Text(
                            student['emoji'] as String,
                            style: const TextStyle(
                              fontSize: 23,
                            ),
                          ),
                          activeColor:
                              const Color(0xFF302B63),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _showMessage(
                          'Attendance saved for $selectedClass.',
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF302B63),
                      ),
                      child: const Text(
                        'SAVE ATTENDANCE',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _openAssessment() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheet(
          title: 'Fitness Assessment',
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Assessment type',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedAssessment,
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      const Color(0xFFF5F6FA),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: assessmentTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedAssessment = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: students.map((student) {
                    return _assessmentRow(student);
                  }).toList(),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showMessage(
                      '$selectedAssessment records saved.',
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF302B63),
                  ),
                  child: const Text(
                    'SAVE ASSESSMENT',
                    style: TextStyle(
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
  }

  Widget _assessmentRow(
    Map<String, dynamic> student,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(
            student['emoji'] as String,
            style: const TextStyle(fontSize: 21),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              student['name'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: TextFormField(
              initialValue:
                  _assessmentValue(student),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Value',
              ),
              onChanged: (value) {
                _setAssessmentValue(
                  student,
                  value,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _assessmentValue(
    Map<String, dynamic> student,
  ) {
    switch (selectedAssessment) {
      case '100m Run':
        return (student['run'] as num)
            .toStringAsFixed(1);

      case 'Push-ups':
        return '${student['pushups']}';

      case 'Endurance':
        return '${student['endurance']}';

      case 'Flexibility':
        return '${student['flexibility']}';

      case 'Participation':
        return '${student['participation']}';

      default:
        return '';
    }
  }

  void _setAssessmentValue(
    Map<String, dynamic> student,
    String value,
  ) {
    final parsed = double.tryParse(value);

    if (parsed == null) return;

    switch (selectedAssessment) {
      case '100m Run':
        student['run'] = parsed;
        break;

      case 'Push-ups':
        student['pushups'] = parsed.round();
        break;

      case 'Endurance':
        student['endurance'] = parsed.round();
        break;

      case 'Flexibility':
        student['flexibility'] = parsed.round();
        break;

      case 'Participation':
        student['participation'] = parsed.round();
        break;
    }

    setState(() {});
  }

  void _openStudents() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheet(
          title:
              '$selectedClass • ${students.length} students',
          child: ListView(
            children: students.map((student) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor:
                      const Color(0xFFEDEBFF),
                  child: Text(
                    student['emoji'] as String,
                  ),
                ),
                title: Text(
                  student['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  '${student['participation']}% participation • '
                  '${_personalFitness(student)}% fitness',
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openStudent(student);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  int _personalFitness(
    Map<String, dynamic> student,
  ) {
    return ((student['speed'] as num).toInt() +
            (student['strength'] as num).toInt() +
            (student['endurance'] as num).toInt() +
            (student['flexibility'] as num).toInt() +
            (student['teamwork'] as num).toInt()) ~/
        5;
  }

  void _openStudent(
    Map<String, dynamic> student,
  ) {
    final fitness = _personalFitness(student);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheet(
          title:
              '${student['name']} • PE Record',
          child: ListView(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        const Color(0xFFEDEBFF),
                    child: Text(
                      student['emoji'] as String,
                      style: const TextStyle(
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name'] as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF151B3D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Overall fitness: $fitness%',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _studentMetric(
                'Speed',
                student['speed'] as num,
              ),
              _studentMetric(
                'Strength',
                student['strength'] as num,
              ),
              _studentMetric(
                'Endurance',
                student['endurance'] as num,
              ),
              _studentMetric(
                'Flexibility',
                student['flexibility'] as num,
              ),
              _studentMetric(
                'Teamwork',
                student['teamwork'] as num,
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBFF),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡',
                      style:
                          TextStyle(fontSize: 21),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        student['note'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          color: Color(0xFF51489A),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _smallRecord(
                      '🏃',
                      '100m',
                      '${(student['run'] as num).toStringAsFixed(1)}s',
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _smallRecord(
                      '💪',
                      'Push-ups',
                      '${student['pushups']}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _studentMetric(
    String title,
    num value,
  ) {
    final percentage =
        value.toInt().clamp(0, 100);

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor:
                    const Color(0xFFE8E8EE),
                valueColor:
                    const AlwaysStoppedAnimation<
                        Color>(
                  Color(0xFF51489A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallRecord(
    String emoji,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style:
                const TextStyle(fontSize: 19),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openLeaderboard() {
    final ranked = [...students];

    ranked.sort(
      (a, b) => _personalFitness(b)
          .compareTo(_personalFitness(a)),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheet(
          title: 'Class Fitness Ranking',
          child: ListView(
            children:
                ranked.asMap().entries.map((entry) {
              final index = entry.key;
              final student = entry.value;

              final medal = index == 0
                  ? '🥇'
                  : index == 1
                      ? '🥈'
                      : index == 2
                          ? '🥉'
                          : '${index + 1}';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SizedBox(
                  width: 35,
                  child: Text(
                    medal,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Text(
                  student['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  '${student['participation']}% participation',
                ),
                trailing: Text(
                  '${_personalFitness(student)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF51489A),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _sheet({
    required String title,
    required Widget child,
  }) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.78,
      padding:
          const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .scaffoldBackgroundColor,
        borderRadius:
            const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius:
                    BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: Color(0xFF151B3D),
            ),
          ),

          const SizedBox(height: 14),

          Expanded(child: child),
        ],
      ),
    );
  }

  void _showTeacherInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'PE Teacher Mode',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'FitQuest lets PE teachers keep digital '
            'records for students who may not have '
            'phones. Teachers can record attendance, '
            'fitness assessments, progress and coaching '
            'notes from one device.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('OK'),
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
          behavior:
              SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
  }
}