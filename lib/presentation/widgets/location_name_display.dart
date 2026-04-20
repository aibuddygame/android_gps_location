import 'package:flutter/material.dart';

class LocationNameDisplay extends StatelessWidget {
  const LocationNameDisplay({
    super.key,
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.isLoading = false,
  });

  final double latitude;
  final double longitude;
  final String? locationName;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = locationName?.trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.place_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoading
                        ? 'Resolving location'
                        : (name == null || name.isEmpty
                            ? 'Unknown place'
                            : name),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${latitude.toStringAsFixed(7)}, '
                    '${longitude.toStringAsFixed(7)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }
}
