import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/health_record.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'edit_health_screen.dart';

class DetailScreen extends StatelessWidget {
  final HealthRecord record;

  const DetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.tryParse(record.date);
    final date = parsedDate == null
        ? record.date
        : DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(parsedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Data')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppTheme.softShadow(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.monitor_heart_rounded,
                        color: Colors.white, size: 44),
                    const SizedBox(height: 18),
                    Text(
                      'Ringkasan Kesehatan',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      date,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  boxShadow: AppTheme.softShadow(context),
                ),
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.monitor_weight_rounded,
                      label: 'Berat Badan',
                      value: '${record.weight.toStringAsFixed(1)} kg',
                    ),
                    _InfoTile(
                      icon: Icons.height_rounded,
                      label: 'Tinggi Badan',
                      value: '${record.height.toStringAsFixed(0)} cm',
                    ),
                    _InfoTile(
                      icon: Icons.bloodtype_rounded,
                      label: 'Tekanan Darah',
                      value: '${record.bloodPressure} mmHg',
                    ),
                    _InfoTile(
                      icon: Icons.favorite_rounded,
                      label: 'Detak Jantung',
                      value: '${record.heartRate} bpm',
                    ),
                    _InfoTile(
                      icon: Icons.notes_rounded,
                      label: 'Catatan',
                      value: record.notes.isEmpty
                          ? 'Tidak ada catatan'
                          : record.notes,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Edit Data',
                icon: Icons.edit_rounded,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditHealthScreen(record: record)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: isLast ? 0 : 2),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
