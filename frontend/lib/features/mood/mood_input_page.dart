import 'package:flutter/material.dart';

import '../../core/api_service.dart';
import '../../core/app_colors.dart';
import '../../core/app_session.dart';
import '../../core/spotify_session.dart';
import '../../widgets/emotune_logo.dart';
import '../favorites/favorites_tab_page.dart';
import '../journal/journal_tab_page.dart';
import '../notifications/notifications_tab_page.dart';
import '../profile/profile_tab_page.dart';

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
  String? _latestFeedback;

  @override
  void initState() {
    super.initState();
    _latestEmotion = AppSession.lastEmotion;
    _latestFeedback = AppSession.lastAiFeedback;
  }

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
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final previewTracks = AppSession.lastTracks.take(2).toList(growable: false);
    final feedbackText = (_latestFeedback ?? AppSession.lastAiFeedback ?? '').trim().isEmpty
        ? 'Share how you feel so I can suggest a playlist and give supportive feedback.'
        : (_latestFeedback ?? AppSession.lastAiFeedback ?? '').trim();

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
                'Recommended playlist',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (previewTracks.isEmpty)
                const _PlaylistPlaceholder()
              else
                Row(
                  children: [
                    for (int i = 0; i < previewTracks.length; i++) ...[
                      Expanded(
                        child: _PlaylistPreview(
                          title: (previewTracks[i]['track_name'] ?? 'Untitled Track').toString(),
                          subtitle: (previewTracks[i]['artist_name'] ?? 'Unknown Artist').toString(),
                          imageTint: i.isEven ? const Color(0xFF7D552A) : const Color(0xFF425E70),
                        ),
                      ),
                      if (i != previewTracks.length - 1) const SizedBox(width: 8),
                    ],
                    if (previewTracks.length == 1) ...[
                      const SizedBox(width: 8),
                      const Expanded(child: _PlaylistPlaceholder(compact: true)),
                      ],
                  ],
                ),
              const SizedBox(height: 12),
              const Text(
                'AI feedback',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                feedbackText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  height: 1.32,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
        spotifyAccessToken: SpotifySession.accessToken,
      );

      final tracks = (recommendations['tracks'] as List<dynamic>? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      final aiFeedback = (recommendations['ai_feedback'] ?? '').toString().trim();

      AppSession.lastMoodText = text;
      AppSession.lastEmotion = emotion;
      AppSession.lastTracks = tracks;
      AppSession.lastAiFeedback = aiFeedback;

      setState(() {
        _latestEmotion = emotion;
        _latestFeedback = aiFeedback.isEmpty ? null : aiFeedback;
      });
      _controller.clear();

      final warning = (recommendations['warning'] ?? '').toString();
      if (warning.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(warning)),
        );
      }
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
  final String subtitle;
  final Color imageTint;

  const _PlaylistPreview({
    required this.title,
    required this.subtitle,
    required this.imageTint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [imageTint.withOpacity(0.9), AppColors.card],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistPlaceholder extends StatelessWidget {
  final bool compact;

  const _PlaylistPlaceholder({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 94 : 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        color: Colors.white.withOpacity(0.04),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Playlist will appear here',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: Colors.white70,
        ),
      ),
    );
  }
}
