import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class SettingsTabPage extends StatefulWidget {
  const SettingsTabPage({super.key});

  @override
  State<SettingsTabPage> createState() => _SettingsTabPageState();
}

class _SettingsTabPageState extends State<SettingsTabPage> {
  bool _notificationsEnabled = true;
  bool _dailyCheckInEnabled = true;
  bool _reflectionPromptEnabled = true;
  bool _autoplayEnabled = false;
  bool _dataSaverEnabled = false;

  @override
  Widget build(BuildContext context) {
    final enabledCount = <bool>[
      _notificationsEnabled,
      _dailyCheckInEnabled,
      _reflectionPromptEnabled,
      _autoplayEnabled,
      _dataSaverEnabled,
    ].where((enabled) => enabled).length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withOpacity(0.45)),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.card,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.28),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border.withOpacity(0.55)),
                    ),
                    child: const Icon(
                      Icons.settings_suggest_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Settings',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$enabledCount options enabled',
                          style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _SectionTitle(title: 'Wellbeing'),
            const SizedBox(height: 8),
            _SwitchTile(
              icon: Icons.notifications_active_outlined,
              title: 'Enable Notifications',
              subtitle: 'Get updates about mood reminders and playlists.',
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
            ),
            _SwitchTile(
              icon: Icons.today_outlined,
              title: 'Daily Mood Check-In',
              subtitle: 'Receive one gentle prompt each day.',
              value: _dailyCheckInEnabled,
              onChanged: (value) => setState(() => _dailyCheckInEnabled = value),
            ),
            _SwitchTile(
              icon: Icons.self_improvement_outlined,
              title: 'Reflection Prompt',
              subtitle: 'Show short reflection prompts after recommendations.',
              value: _reflectionPromptEnabled,
              onChanged: (value) => setState(() => _reflectionPromptEnabled = value),
            ),
            const SizedBox(height: 10),
            const _SectionTitle(title: 'Playback'),
            const SizedBox(height: 8),
            _SwitchTile(
              icon: Icons.play_circle_outline_rounded,
              title: 'Autoplay Recommendations',
              subtitle: 'Start playing recommended songs automatically.',
              value: _autoplayEnabled,
              onChanged: (value) => setState(() => _autoplayEnabled = value),
            ),
            _SwitchTile(
              icon: Icons.data_saver_on_outlined,
              title: 'Data Saver Mode',
              subtitle: 'Prefer lighter previews and lower network usage.',
              value: _dataSaverEnabled,
              onChanged: (value) => setState(() => _dataSaverEnabled = value),
            ),
            const SizedBox(height: 10),
            const _SectionTitle(title: 'More'),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.info_outline_rounded,
              title: 'About EmoTune',
              subtitle: 'Version and app information',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('EmoTune v0.1.0')),
                );
              },
            ),
            _ActionTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Notice',
              subtitle: 'How we handle your mood data',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy page is not yet available.')),
                );
              },
            ),
            _ActionTile(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              subtitle: 'Return to login screen',
              danger: true,
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 13,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = danger ? const Color(0xFFFF8F8F) : AppColors.text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.45)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.w600, color: titleColor),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
