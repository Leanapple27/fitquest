import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

import '../theme_controller.dart';
import 'privacy_safety_screen.dart';
import 'teacher_dashboard_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool buddyRequests = true;
  bool leaderboardVisibility = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          FqSpacing.page,
          FqSpacing.label,
          FqSpacing.page,
          FqSpacing.pageBottom,
        ),
        children: [
          _sectionTitle('APPEARANCE'),
          const SizedBox(height: 8),
          _card(
            children: [
              ListTile(
                leading: const Text(
                  '🎨',
                  style: TextStyle(fontSize: 24),
                ),
                title: const Text(
                  'Theme',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  _themeName(
                    ThemeController.instance.themeMode,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: _showThemePicker,
              ),
            ],
          ),
          const SizedBox(height: FqSpacing.section),
          _sectionTitle('NOTIFICATIONS'),
          const SizedBox(height: 8),
          _card(
            children: [
              SwitchListTile(
                secondary: const Text(
                  '🔔',
                  style: TextStyle(fontSize: 23),
                ),
                title: const Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: const Text(
                  'Quest, streak and activity reminders',
                ),
                value: notifications,
                onChanged: (value) {
                  setState(() {
                    notifications = value;
                  });
                },
              ),
              SwitchListTile(
                secondary: const Text(
                  '🤝',
                  style: TextStyle(fontSize: 23),
                ),
                title: const Text(
                  'Fitness Buddy',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: const Text(
                  'Allow buddy activity notifications',
                ),
                value: buddyRequests,
                onChanged: (value) {
                  setState(() {
                    buddyRequests = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: FqSpacing.section),
          _sectionTitle('PRIVACY'),
          const SizedBox(height: 8),
          _card(
            children: [
              SwitchListTile(
                secondary: const Text(
                  '🏆',
                  style: TextStyle(fontSize: 23),
                ),
                title: const Text(
                  'Leaderboard visibility',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: const Text(
                  'Show your profile on public leaderboards',
                ),
                value: leaderboardVisibility,
                onChanged: (value) {
                  setState(() {
                    leaderboardVisibility = value;
                  });
                },
              ),
              ListTile(
                leading: const Text(
                  '🛡️',
                  style: TextStyle(fontSize: 23),
                ),
                title: const Text(
                  'Privacy & Safety',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: const Text(
                  'Manage your privacy controls',
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacySafetyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: FqSpacing.section),
          _sectionTitle('ACCOUNT'),
          const SizedBox(height: 8),
          _card(
            children: [
              ListTile(
                leading: const Text(
                  '🧑‍🏫',
                  style: TextStyle(fontSize: 23),
                ),
                title: const Text(
                  'PE Teacher Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: const Text(
                  'For teachers managing PE classes',
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: _showTeacherMode,
              ),
              ListTile(
                leading: const Text(
                  '🚪',
                  style: TextStyle(fontSize: 23),
                ),
                title: Text(
                  'Log Out',
                  style: FqTypography.cardTitle(color: FqColors.danger),
                ),
                onTap: _logout,
              ),
            ],
          ),
          const SizedBox(height: 25),
          Center(
            child: Text(
              'FitQuest • Fitness for everyone',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: FqTypography.sectionLabel(),
    );
  }

  Widget _card({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: FqRadii.cardBorder,
      ),
      child: Column(
        children: children,
      ),
    );
  }

  String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';

      case ThemeMode.dark:
        return 'Dark';

      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showThemePicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  FqSpacing.page,
                  FqSpacing.page,
                  FqSpacing.page,
                  FqSpacing.label,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose appearance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                subtitle: const Text(
                  'Follow your phone settings',
                ),
                value: ThemeMode.system,
                groupValue: ThemeController.instance.themeMode,
                onChanged: (value) {
                  if (value == null) return;

                  ThemeController.instance.setThemeMode(value);

                  Navigator.pop(sheetContext);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                subtitle: const Text(
                  'Bright FitQuest appearance',
                ),
                value: ThemeMode.light,
                groupValue: ThemeController.instance.themeMode,
                onChanged: (value) {
                  if (value == null) return;

                  ThemeController.instance.setThemeMode(value);

                  Navigator.pop(sheetContext);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                subtitle: const Text(
                  'Dark FitQuest appearance',
                ),
                value: ThemeMode.dark,
                groupValue: ThemeController.instance.themeMode,
                onChanged: (value) {
                  if (value == null) return;

                  ThemeController.instance.setThemeMode(value);

                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: FqSpacing.label),
            ],
          ),
        );
      },
    );
  }

  void _showTeacherMode() {
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
            'Teacher mode lets PE teachers manage classes, '
            'attendance, fitness assessments, student progress, '
            'and personalized activity recommendations.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('LATER'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeacherDashboardScreen(),
                  ),
                );
              },
              child: const Text('CONTINUE'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }
}
