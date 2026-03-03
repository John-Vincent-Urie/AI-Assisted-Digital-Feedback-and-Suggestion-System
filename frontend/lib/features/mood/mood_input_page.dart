import 'package:flutter/material.dart';

import '../../core/api_service.dart';
import '../../core/app_session.dart';
import '../../core/app_colors.dart';
import '../../core/spotify_session.dart';
import '../favorites/favorites_tab_page.dart';
import '../journal/journal_tab_page.dart';
import '../notifications/notifications_tab_page.dart';
import '../profile/profile_tab_page.dart';
import '../settings/settings_tab_page.dart';
import '../../widgets/emotune_logo.dart';

class MoodInputPage extends StatefulWidget {
  const MoodInputPage({super.key});

  @override
  State<MoodInputPage> createState() => _MoodInputPageState();
}

class _MoodInputPageState extends State<MoodInputPage> {
  int _selectedNav = 0;
  final TextEditingController _controller = TextEditingController();
  bool _isSubmittingMood = false;
  String? _latestEmotion;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
          child: _buildTabContent(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bg,
          border: Border(
            top: BorderSide(color: AppColors.border.withOpacity(0.25), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedNav,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) => setState(() => _selectedNav = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Journal'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedNav) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const FavoritesTabPage();
      case 2:
        return const NotificationsTabPage();
      case 3:
        return const JournalTabPage();
      case 4:
        return const ProfileTabPage();
      case 5:
        return const SettingsTabPage();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        const EmoTuneLogo(size: 96),
        if (SpotifySession.isConnected) ...[
          const SizedBox(height: 8),
          Text(
            'Connected as ${SpotifySession.displayName ?? SpotifySession.email ?? 'Spotify User'}',
            style: const TextStyle(color: AppColors.primary, fontSize: 12.5),
            textAlign: TextAlign.center,
          ),
        ],
        if (AppSession.isLoggedIn) ...[
          const SizedBox(height: 4),
          Text(
            'Logged in as ${AppSession.displayName ?? AppSession.email}',
            style: const TextStyle(color: AppColors.muted, fontSize: 11.5),
            textAlign: TextAlign.center,
          ),
        ],
        if (_latestEmotion != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Detected mood: $_latestEmotion',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.55)),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "I hope you're fine in my community. If in today to be real, "
                "you just vent to me. I'll ask it carefully, it will disappear. "
                "Just assure you're okay. You can do this.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  height: 1.32,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Expanded(
                    child: _PlaylistPreview(
                      title: 'Christian song\nplaylist',
                      imageTint: Color(0xFF7D552A),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _PlaylistPreview(
                      title: 'TRUSTING\nGOD',
                      imageTint: Color(0xFF425E70),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.border.withOpacity(0.7)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'I feel...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              IconButton(
                onPressed: _isSubmittingMood ? null : _submitMood,
                icon: _isSubmittingMood
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : const Icon(
                        Icons.send_outlined,
                        color: AppColors.primary,
                      ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Future<void> _submitMood() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter how you feel first.')),
      );
      return;
    }

    setState(() => _isSubmittingMood = true);
    try {
      final mood = await ApiService.analyzeMood(
        text: text,
        userEmail: AppSession.email,
      );
      final emotion = (mood['emotion'] ?? 'mixed').toString();

      final recommendations = await ApiService.generateRecommendations(
        text: text,
        emotion: emotion,
        userEmail: AppSession.email,
      );

      final tracks = (recommendations['tracks'] as List<dynamic>? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      AppSession.lastMoodText = text;
      AppSession.lastEmotion = emotion;
      AppSession.lastTracks = tracks;

      setState(() => _latestEmotion = emotion);

      if (!mounted) return;
      Navigator.pushNamed(context, '/recommendations');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingMood = false);
      }
    }
  }
}

class _PlaylistPreview extends StatelessWidget {
  final String title;
  final Color imageTint;

  const _PlaylistPreview({
    required this.title,
    required this.imageTint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [imageTint.withOpacity(0.9), AppColors.card],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.bottomLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
