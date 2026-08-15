import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class ActivityCalendarScreen extends StatefulWidget {
  const ActivityCalendarScreen({super.key});

  @override
  State<ActivityCalendarScreen> createState() =>
      _ActivityCalendarScreenState();
}

class _ActivityCalendarScreenState extends State<ActivityCalendarScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate;
  bool _loading = true;
  String? _error;

  final Map<String, String> _statuses = {};
  final Map<String, _CalendarEvent> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadCalendar();
  }

  String _dateKey(DateTime date) {
    final d = date.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  DateTime _parseDateKey(String key) {
    final parts = key.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  Future<void> _loadCalendar() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Please sign in to view your activity calendar.';
        });
      }
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activityCalendar')
          .get();

      _statuses.clear();
      _events.clear();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status']?.toString();

        if (status == 'completed' || status == 'skipped') {
          _statuses[doc.id] = status!;
        }

        final eventTitle = data['eventTitle']?.toString();
        if (eventTitle != null && eventTitle.trim().isNotEmpty) {
          _events[doc.id] = _CalendarEvent(
            title: eventTitle.trim(),
            description: data['eventDescription']?.toString() ?? '',
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not load your activity calendar.';
      });
    }
  }

  Future<void> _setStatus(String status) async {
    final user = FirebaseAuth.instance.currentUser;
    final date = _selectedDate;

    if (user == null || date == null) return;

    final key = _dateKey(date);

    setState(() => _statuses[key] = status);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activityCalendar')
          .doc(key)
          .set(
        {
          'status': status,
          'date': Timestamp.fromDate(
            DateTime(date.year, date.month, date.day),
          ),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _statuses.remove(key));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this activity status.'),
        ),
      );
    }
  }

  Future<void> _addEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    final date = _selectedDate;

    if (user == null || date == null) return;

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Add event',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Event',
                      hintText: 'Sports Day',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Details',
                      hintText: 'Optional event details',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('ADD EVENT'),
              ),
            ],
          );
        },
      );

      if (result != true || titleController.text.trim().isEmpty) return;

      final key = _dateKey(date);
      final event = _CalendarEvent(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activityCalendar')
          .doc(key)
          .set(
        {
          'eventTitle': event.title,
          'eventDescription': event.description,
          'date': Timestamp.fromDate(
            DateTime(date.year, date.month, date.day),
          ),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      setState(() => _events[key] = event);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event added.')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add the event.')),
      );
    } finally {
      titleController.dispose();
      descriptionController.dispose();
    }
  }

  void _previousMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1);
      _selectedDate = DateTime(_month.year, _month.month, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month + 1);
      _selectedDate = DateTime(_month.year, _month.month, 1);
    });
  }

  void _today() {
    final now = DateTime.now();
    setState(() {
      _month = DateTime(now.year, now.month);
      _selectedDate = now;
    });
  }

  int _daysInMonth() {
    return DateTime(_month.year, _month.month + 1, 0).day;
  }

  int _firstWeekday() {
    // Monday = 0 ... Sunday = 6.
    return (DateTime(_month.year, _month.month, 1).weekday + 6) % 7;
  }

  int get _completedCount =>
      _statuses.values.where((status) => status == 'completed').length;

  int get _skippedCount =>
      _statuses.values.where((status) => status == 'skipped').length;

  @override
  Widget build(BuildContext context) {
    final selectedKey =
        _selectedDate == null ? null : _dateKey(_selectedDate!);
    final selectedEvent =
        selectedKey == null ? null : _events[selectedKey];
    final selectedStatus =
        selectedKey == null ? null : _statuses[selectedKey];

    return Scaffold(
      backgroundColor: FqColors.scaffold,
      appBar: AppBar(
        title: const Text('Activity Calendar'),
        actions: [
          IconButton(
            tooltip: 'Today',
            onPressed: _today,
            icon: const Icon(Icons.today_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCalendar,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  FqSpacing.page,
                  FqSpacing.pageTop,
                  FqSpacing.page,
                  FqSpacing.pageBottom,
                ),
                children: [
                  _buildHero(),
                  const SizedBox(height: 18),
                  _buildCalendarCard(),
                  const SizedBox(height: 16),
                  _buildSelectedDay(
                    status: selectedStatus,
                    event: selectedEvent,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: FqColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: FqColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: FqRadii.heroBorder,
        boxShadow: FqShadows.heroBrand(),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR ACTIVITY',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Build your streak, one day at a time.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _heroStat('$_completedCount', 'DONE'),
                    const SizedBox(width: 18),
                    _heroStat('$_skippedCount', 'SKIPPED'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    final days = _daysInMonth();
    final leading = _firstWeekday();
    final cells = leading + days;
    final rows = (cells / 7).ceil();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: FqColors.surface,
        borderRadius: FqRadii.cardBorder,
        boxShadow: FqShadows.cardSoft(),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  _monthName(_month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: FqColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              _WeekLabel('MON'),
              _WeekLabel('TUE'),
              _WeekLabel('WED'),
              _WeekLabel('THU'),
              _WeekLabel('FRI'),
              _WeekLabel('SAT'),
              _WeekLabel('SUN'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows * 7,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 7,
              crossAxisSpacing: 5,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - leading + 1;

              if (dayNumber < 1 || dayNumber > days) {
                return const SizedBox.shrink();
              }

              final date =
                  DateTime(_month.year, _month.month, dayNumber);
              final key = _dateKey(date);
              final status = _statuses[key];
              final event = _events[key];
              final selected = _selectedDate != null &&
                  _dateKey(_selectedDate!) == key;
              final today = _dateKey(DateTime.now()) == key;

              return _CalendarDay(
                day: dayNumber,
                status: status,
                hasEvent: event != null,
                selected: selected,
                today: today,
                onTap: () => setState(() => _selectedDate = date),
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: const [
              _LegendDot(
                color: FqColors.success,
                label: 'Completed',
              ),
              _LegendDot(
                color: FqColors.danger,
                label: 'Skipped',
              ),
              _LegendDot(
                color: FqColors.energy,
                label: 'Event',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDay({
    required String? status,
    required _CalendarEvent? event,
  }) {
    final date = _selectedDate ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FqColors.surface,
        borderRadius: FqRadii.cardBorder,
        boxShadow: FqShadows.cardSoft(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _fullDate(date),
            style: const TextStyle(
              color: FqColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            status == 'completed'
                ? 'Activity completed'
                : status == 'skipped'
                    ? 'Activity skipped'
                    : 'No activity status yet',
            style: const TextStyle(
              color: FqColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (event != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: FqColors.energy.withValues(alpha: 0.10),
                borderRadius: FqRadii.buttonBorder,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_rounded,
                    color: FqColors.energy,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: FqColors.ink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (event.description.isNotEmpty)
                          Text(
                            event.description,
                            style: const TextStyle(
                              color: FqColors.muted,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _setStatus('completed'),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('DONE'),
                  style: FilledButton.styleFrom(
                    backgroundColor: FqColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: FqRadii.buttonBorder,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _setStatus('skipped'),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('SKIPPED'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FqColors.danger,
                    side: const BorderSide(color: FqColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: FqRadii.buttonBorder,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _addEvent,
              icon: const Icon(Icons.event_available_rounded),
              label: const Text('ADD EVENT'),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _fullDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[date.weekday - 1]}, '
        '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final String? status;
  final bool hasEvent;
  final bool selected;
  final bool today;
  final VoidCallback onTap;

  const _CalendarDay({
    required this.day,
    required this.status,
    required this.hasEvent,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill = status == 'completed'
        ? FqColors.success
        : status == 'skipped'
            ? FqColors.danger
            : FqColors.scaffold;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? FqColors.primary
                : today
                    ? FqColors.primary.withValues(alpha: 0.45)
                    : Colors.transparent,
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: status == null
                      ? FqColors.ink
                      : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (hasEvent)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: FqColors.energy,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeekLabel extends StatelessWidget {
  final String text;

  const _WeekLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: FqColors.muted,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: FqColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CalendarEvent {
  final String title;
  final String description;

  const _CalendarEvent({
    required this.title,
    required this.description,
  });
}
