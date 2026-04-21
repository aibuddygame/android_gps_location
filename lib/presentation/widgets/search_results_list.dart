import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../modules/search/models/place_suggestion.dart';

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({
    super.key,
    required this.results,
    required this.onSelected,
  });

  final List<PlaceSuggestion> results;
  final ValueChanged<PlaceSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();
    final colors = Theme.of(context).dividerColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors),
        color: const Color(0xFF11161A),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: results.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: colors),
        itemBuilder: (context, index) {
          final item = results[index];
          return ListTile(
            dense: true,
            onTap: () => onSelected(item),
            title: Text(item.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(item.subtitle),
                const SizedBox(height: 4),
                Text(
                  '${formatCoordinate(item.latitude)} / ${formatCoordinate(item.longitude)}',
                  style: monoTextStyle(
                    context,
                    size: 11,
                    color: const Color(0xFF15D8FF),
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          );
        },
      ),
    );
  }
}
