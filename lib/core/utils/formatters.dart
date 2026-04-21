import 'package:flutter/material.dart';

String formatCoordinate(double value) => value.toStringAsFixed(6);

String formatCoordinatePair(double latitude, double longitude) {
  return '${formatCoordinate(latitude)}, ${formatCoordinate(longitude)}';
}

String formatRelativeTimestamp(DateTime? value) {
  if (value == null) return 'No injection yet';
  final now = DateTime.now();
  final delta = now.difference(value);
  if (delta.inSeconds < 5) return 'just now';
  if (delta.inMinutes < 1) return '${delta.inSeconds}s ago';
  if (delta.inHours < 1) return '${delta.inMinutes}m ago';
  return '${delta.inHours}h ago';
}

String formatClock(DateTime? value) {
  if (value == null) return '--:--:--';
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final second = value.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}

TextStyle monoTextStyle(BuildContext context, {Color? color, double? size}) {
  return Theme.of(context).textTheme.bodyMedium!.copyWith(
    fontFamily: 'monospace',
    color: color,
    fontSize: size,
    letterSpacing: 0.2,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
