import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/health_record.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/health_card.dart';
import 'add_health_screen.dart';
import 'detail_screen.dart';
import 'edit_health_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadRecords();
    });
  }

  Future<void> _openAddScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddHealthScreen()),
    );
    if (!mounted) return;
    await context.read<HealthProvider>().loadRecords();
  }

  Future<void> _confirmDelete(BuildContext context, HealthRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data?'),
        content:
            const Text('Data kesehatan yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted && record.id != null) {
      await context.read<HealthProvider>().deleteRecord(record.id!);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data kesehatan berhasil dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kesehatan')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddScreen,
        tooltip: 'Tambah Data',
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Consumer<HealthProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.records.isEmpty) {
              return const _HistoryEmptyState();
            }

            return RefreshIndicator(
              onRefresh: provider.loadRecords,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: provider.records.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final record = provider.records[index];
                  return HealthCard(
                    record: record,
                    onDetail: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DetailScreen(record: record)),
                    ),
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EditHealthScreen(record: record)),
                    ),
                    onDelete: () => _confirmDelete(context, record),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.assignment_rounded,
                  size: 44, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 18),
            Text(
              'Riwayat masih kosong',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Data kesehatan yang disimpan akan tampil di halaman ini.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
