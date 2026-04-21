import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../controllers/mvp_controller.dart';

class LogConsole extends StatelessWidget {
  const LogConsole({super.key, required this.logs});

  final List<AppLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    final style = monoTextStyle(context, size: 11);
    if (logs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0E10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text('No log entries yet.', style: style),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Theme.of(context).dividerColor),
        itemBuilder: (context, index) {
          final item = logs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              '[${formatClock(item.timestamp)}] ${item.level.padRight(7)} ${item.message}',
              style: style,
            ),
          );
        },
      ),
    );
  }
}
