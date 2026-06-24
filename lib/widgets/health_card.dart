import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/health_record.dart';
import '../theme/app_theme.dart';

class HealthCard extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback? onDetail;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HealthCard({
    super.key,
    required this.record,
    this.onDetail,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final date = DateTime.tryParse(record.date);
    final formattedDate = date == null
        ? record.date
        : DateFormat('dd MMMM yyyy', 'id_ID').format(date);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.monitor_heart_rounded,
                    color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${record.bloodPressure} mmHg',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(
                  label: 'Berat',
                  value: '${record.weight.toStringAsFixed(1)} kg'),
              _MetricChip(
                  label: 'Tinggi',
                  value: '${record.height.toStringAsFixed(0)} cm'),
              _MetricChip(label: 'Detak', value: '${record.heartRate} bpm'),
            ],
          ),
          if (onDetail != null || onEdit != null || onDelete != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDetail != null)
                  TextButton.icon(
                    onPressed: onDetail,
                    icon: const Icon(Icons.visibility_rounded, size: 18),
                    label: const Text('Detail'),
                  ),
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit'),
                  ),
                if (onDelete != null)
                  IconButton(
                    tooltip: 'Hapus',
                    onPressed: onDelete,
                    color: colorScheme.error,
                    icon: const Icon(Icons.delete_rounded),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
