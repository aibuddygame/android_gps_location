import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/date_time_extensions.dart';
import '../../data/models/location_history_model.dart';
import '../providers/dashboard_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: provider.refreshHistory,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Clear history',
            onPressed:
                provider.history.isEmpty ? null : () => _confirmClear(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: provider.history.isEmpty
          ? const Center(child: Text('No mock locations yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _HistoryTile(item: provider.history[index]);
              },
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final provider = context.read<DashboardProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history'),
        content: const Text('Remove all saved mock locations?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) await provider.clearHistory();
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final LocationHistoryModel item;

  @override
  Widget build(BuildContext context) {
    final title = item.locationName?.trim();

    return Card(
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(title == null || title.isEmpty ? item.coordinates : title),
        subtitle: Text(
          '${item.coordinates}\n'
          'Used ${item.useCount} time${item.useCount == 1 ? '' : 's'} '
          'last at ${item.lastUsedAt.toDebugTime()}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.north_west),
        onTap: () async {
          await context.read<DashboardProvider>().useHistoryLocation(item);
          if (context.mounted) {
            Navigator.pop<LocationHistoryModel>(context, item);
          }
        },
      ),
    );
  }
}
