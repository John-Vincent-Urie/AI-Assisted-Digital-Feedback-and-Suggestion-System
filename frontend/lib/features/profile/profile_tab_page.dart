import 'package:flutter/material.dart';

import '../../core/app_session.dart';
import '../../core/app_colors.dart';
import '../settings/settings_tab_page.dart';

class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.card,
            child: Icon(Icons.person, size: 42, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            AppSession.displayName ?? 'Guest User',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 2),
        Center(
          child: Text(
            AppSession.email ?? 'Not signed in',
            style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
          ),
        ),
        const SizedBox(height: 18),
        _ProfileTile(
          icon: Icons.music_note_outlined,
          title: 'Favorite Genres',
          value: 'Acoustic, Worship, Chill',
          onTap: () {},
        ),
        _ProfileTile(
          icon: Icons.insights_outlined,
          title: 'Mood Insights',
          value: 'View weekly mood summary',
          onTap: () {},
        ),
        _ProfileTile(
          icon: Icons.history_outlined,
          title: 'Listening History',
          value: 'See recent sessions',
          onTap: () {},
        ),
        _ProfileTile(
          icon: Icons.settings_outlined,
          title: 'Settings',
          value: 'Notifications, check-in, and autoplay',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsTabPage()),
            );
          },
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.45)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        value,
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
