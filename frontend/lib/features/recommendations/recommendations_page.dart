import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_service.dart';
import '../../core/app_colors.dart';
import '../../core/app_session.dart';

class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key});

  Future<void> _openSpotifyLink(BuildContext context, String url) async {
    if (url.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open Spotify link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracks = AppSession.lastTracks;
    final emotion = AppSession.lastEmotion;
    final moodText = AppSession.lastMoodText;

    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (emotion != null) ...[
              Text(
                'Mood: $emotion',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (moodText != null && moodText.isNotEmpty) ...[
              Text(
                'You said: "$moodText"',
                style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
              ),
              const SizedBox(height: 12),
            ],
            if (tracks.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: tracks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final track = tracks[index];
                    final imageUrl = (track['album_image_url'] ?? '').toString();
                    final trackName = (track['track_name'] ?? '').toString();
                    final artistName = (track['artist_name'] ?? '').toString();
                    final spotifyUrl = (track['spotify_url'] ?? '').toString();

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: spotifyUrl.isEmpty
                          ? null
                          : () => _openSpotifyLink(context, spotifyUrl),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border.withOpacity(0.45)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl.isEmpty
                                  ? Container(
                                      width: 54,
                                      height: 54,
                                      color: AppColors.border.withOpacity(0.25),
                                      child: const Icon(
                                        Icons.music_note_rounded,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Image.network(
                                      imageUrl,
                                      width: 54,
                                      height: 54,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trackName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    artistName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (spotifyUrl.isNotEmpty)
                              const Icon(
                                Icons.open_in_new_rounded,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: ApiService.recommendationHistory(userEmail: AppSession.email),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          snapshot.error.toString().replaceFirst('Exception: ', ''),
                        ),
                      );
                    }
                    final sessions =
                        (snapshot.data?['sessions'] as List<dynamic>? ?? []);
                    if (sessions.isEmpty) {
                      return const Center(child: Text('No recommendations yet.'));
                    }
                    return ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = Map<String, dynamic>.from(
                          sessions[index] as Map,
                        );
                        final sessionEmotion = (session['emotion'] ?? '').toString();
                        final createdAt = (session['created_at'] ?? '').toString();
                        return ListTile(
                          title: Text('Mood: $sessionEmotion'),
                          subtitle: Text(createdAt),
                          trailing: const Icon(Icons.chevron_right),
                        );
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
