import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class FavoritesTabPage extends StatelessWidget {
  const FavoritesTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = <Map<String, String>>[
      {'title': 'Calm Night', 'artist': 'Ethereal Waves'},
      {'title': 'Hopeful Morning', 'artist': 'Soulfield'},
      {'title': 'Breathe Again', 'artist': 'Ocean Hymns'},
      {'title': 'Steady Heart', 'artist': 'Lumen Choir'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Favorites',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your liked songs and saved recommendations',
          style: TextStyle(color: AppColors.muted, fontSize: 12.5),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.separated(
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final item = favorites[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withOpacity(0.45)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            item['artist'] ?? '',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
