import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class JournalTabPage extends StatelessWidget {
  const JournalTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = <Map<String, String>>[
      {'day': 'Today', 'mood': 'Calm', 'note': 'Felt more focused after study playlist.'},
      {'day': 'Yesterday', 'mood': 'Stressed', 'note': 'Needed softer songs before sleep.'},
      {'day': 'Last Week', 'mood': 'Motivational', 'note': 'Workout mix helped energy.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Journal',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Track mood patterns and notes',
          style: TextStyle(color: AppColors.muted, fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Write a quick mood note...',
            suffixIcon: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.send_outlined, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final entry = entries[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withOpacity(0.45)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry['day'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            entry['mood'] ?? '',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry['note'] ?? '',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
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
