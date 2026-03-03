import 'package:flutter/material.dart';

import '../../core/api_service.dart';
import '../../core/app_colors.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.adminDashboard(),
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

          final data = snapshot.data ?? {};
          final activeUsers = data['active_users'] ?? 0;
          final totalUsers = data['total_users'] ?? 0;
          final playlistsThisMonth = data['playlists_generated_this_month'] ?? 0;
          final topMoods = (data['top_moods'] as List<dynamic>? ?? []);

          return Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetricCard(title: 'Active Users', value: '$activeUsers'),
                const SizedBox(height: 10),
                _MetricCard(title: 'Total Users', value: '$totalUsers'),
                const SizedBox(height: 10),
                _MetricCard(
                  title: 'Playlists This Month',
                  value: '$playlistsThisMonth',
                ),
                const SizedBox(height: 14),
                const Text(
                  'Top Moods',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: topMoods.isEmpty
                      ? const Center(child: Text('No mood analytics yet.'))
                      : ListView.separated(
                          itemCount: topMoods.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final mood = Map<String, dynamic>.from(
                              topMoods[index] as Map,
                            );
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.border.withOpacity(0.45),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    (mood['emotion'] ?? '').toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text('Count: ${(mood['count'] ?? 0)}'),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
