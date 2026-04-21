import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/mock_location_session.dart';

class StatusStrip extends StatelessWidget {
  const StatusStrip({
    super.key,
    required this.session,
    required this.locationName,
  });

  final MockLocationSession session;
  final String? locationName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final mono = monoTextStyle(context, size: 12);
    final statusColor = session.isActive ? colors.success : colors.danger;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StripChip(
                  label: session.isActive ? 'ACTIVE' : 'INACTIVE',
                  value: session.isActive ? 'injecting' : 'idle',
                  valueColor: statusColor,
                ),
                _StripChip(
                  label: 'COORDS',
                  value: formatCoordinatePair(
                    session.latitude,
                    session.longitude,
                  ),
                  monospace: true,
                ),
                _StripChip(
                  label: 'INTERVAL',
                  value: '${session.intervalMs} ms',
                  monospace: true,
                ),
                _StripChip(
                  label: 'LAST PUSH',
                  value: formatRelativeTimestamp(session.lastUpdateAt),
                ),
              ],
            ),
            if (locationName != null && locationName!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                locationName!,
                style: mono.copyWith(color: const Color(0xFF8A9BA6)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StripChip extends StatelessWidget {
  const _StripChip({
    required this.label,
    required this.value,
    this.monospace = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool monospace;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final bodyStyle = monospace
        ? monoTextStyle(context, size: 12).copyWith(color: valueColor)
        : Theme.of(context).textTheme.bodySmall?.copyWith(color: valueColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF8A9BA6),
                ),
          ),
          const SizedBox(height: 2),
          Text(value, style: bodyStyle),
        ],
      ),
    );
  }
}
