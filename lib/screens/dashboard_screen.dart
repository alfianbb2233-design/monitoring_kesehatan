import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/health_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/health_card.dart';
import '../widgets/statistic_card.dart';
import 'about_screen.dart';
import 'add_health_screen.dart';
import 'detail_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadDashboardData();
    });
  }

  Future<void> _openAddScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddHealthScreen()),
    );
    if (!mounted) return;
    await context.read<HealthProvider>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final today =
        DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddScreen,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HealthProvider>().loadDashboardData(),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              today,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            AppTheme.primaryColor.withOpacity(0.12),
                        child: const Icon(Icons.person_rounded,
                            color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Consumer<HealthProvider>(
                    builder: (context, provider, _) {
                      final latest = provider.latestRecord;
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 520;
                          return GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide ? 3 : 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: isWide ? 1.45 : 1.05,
                            ),
                            children: [
                              StatisticCard(
                                title: 'Total Data Kesehatan',
                                value: provider.totalRecords.toString(),
                                icon: Icons.folder_copy_rounded,
                                color: AppTheme.primaryColor,
                              ),
                              StatisticCard(
                                title: 'Berat Badan Terakhir',
                                value: latest == null
                                    ? '-'
                                    : '${latest.weight.toStringAsFixed(1)} kg',
                                icon: Icons.monitor_weight_rounded,
                                color: AppTheme.secondaryColor,
                              ),
                              StatisticCard(
                                title: 'Tekanan Darah Terakhir',
                                value:
                                    latest == null ? '-' : latest.bloodPressure,
                                icon: Icons.bloodtype_rounded,
                                color: const Color(0xFFEF4444),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle(title: 'Quick Menu'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickMenuItem(
                              icon: Icons.add_circle_rounded,
                              label: 'Tambah Data',
                              color: AppTheme.primaryColor,
                              onTap: _openAddScreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickMenuItem(
                              icon: Icons.history_rounded,
                              label: 'Riwayat Data',
                              color: AppTheme.secondaryColor,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HistoryScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickMenuItem(
                              icon: Icons.info_rounded,
                              label: 'Tentang',
                              color: const Color(0xFFF59E0B),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AboutScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                sliver: Consumer<HealthProvider>(
                  builder: (context, provider, _) {
                    if (provider.isDashboardLoading) {
                      return const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()));
                    }

                    final records = provider.recentRecords;
                    return SliverList.list(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                                child: _SectionTitle(title: 'Recent Activity')),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HistoryScreen()),
                              ),
                              child: const Text('Lihat Semua'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (records.isEmpty)
                          const _EmptyState()
                        else
                          ...records.map(
                            (record) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: HealthCard(
                                record: record,
                                onDetail: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          DetailScreen(record: record)),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
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
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _QuickMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: AppTheme.softShadow(context),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        children: [
          Icon(Icons.health_and_safety_rounded,
              size: 46, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            'Belum ada data kesehatan',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan data harian pertama untuk mulai memantau kesehatan.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
