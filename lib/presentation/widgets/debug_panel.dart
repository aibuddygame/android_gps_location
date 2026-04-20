import 'package:flutter/material.dart';

import '../../core/extensions/date_time_extensions.dart';
import '../../domain/entities/mock_location_session.dart';

class DebugPanel extends StatelessWidget {
  const DebugPanel({super.key, required this.session});

  final MockLocationSession? session;

  @override
  Widget build(BuildContext context) {
    final value = session;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live debug', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _Row('Status', value?.isActive == true ? 'Active' : 'Inactive'),
            _Row('Latitude', value?.latitude.toStringAsFixed(7) ?? '-'),
            _Row('Longitude', value?.longitude.toStringAsFixed(7) ?? '-'),
            _Row('Update interval', '${value?.intervalMs ?? '-'} ms'),
            _Row('Accuracy', '${value?.accuracy.toStringAsFixed(1) ?? '-'} m'),
            _Row('Speed', '${value?.speed.toStringAsFixed(1) ?? '-'} m/s'),
            _Row('Bearing', '${value?.bearing.toStringAsFixed(1) ?? '-'} deg'),
            _Row(
              'Background mode',
              value?.isBackgroundCapable == true ? 'Foreground service' : 'Off',
            ),
            _Row('Last update', value?.lastUpdateAt?.toDebugTime() ?? '-'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
