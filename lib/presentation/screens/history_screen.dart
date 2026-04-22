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

class _HistoryTile extends StatefulWidget {
  const _HistoryTile({required this.item});

  final LocationHistoryModel item;

  @override
  State<_HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<_HistoryTile> {
  late final TextEditingController _nameController;
  bool _isEditing = false;
  bool _isSaving = false;

  LocationHistoryModel get item => widget.item;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: item.locationName ?? '');
  }

  @override
  void didUpdateWidget(covariant _HistoryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && oldWidget.item.locationName != item.locationName) {
      _nameController.text = item.locationName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = item.locationName?.trim();

    return Card(
      child: InkWell(
        onTap: _isEditing
            ? null
            : () async {
                await context.read<DashboardProvider>().useHistoryLocation(
                      item,
                    );
                if (context.mounted) {
                  Navigator.pop<LocationHistoryModel>(context, item);
                }
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.history),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditing)
                      TextField(
                        controller: _nameController,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Location name',
                          hintText: 'Custom name',
                          isDense: true,
                        ),
                        onSubmitted: (_) => _saveName(context),
                      )
                    else
                      Text(
                        title == null || title.isEmpty
                            ? item.coordinates
                            : title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.coordinates}\n'
                      'Used ${item.useCount} '
                      'time${item.useCount == 1 ? '' : 's'} '
                      'last at ${item.lastUsedAt.toDebugTime()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_isEditing) ...[
                IconButton(
                  tooltip: 'Cancel',
                  onPressed: _isSaving ? null : _cancelEdit,
                  icon: const Icon(Icons.close),
                ),
                IconButton(
                  tooltip: 'Save',
                  onPressed: _isSaving ? null : () => _saveName(context),
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                ),
              ] else ...[
                IconButton(
                  tooltip: 'Edit name',
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                      _nameController.text = item.locationName ?? '';
                      _nameController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _nameController.text.length),
                      );
                    });
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Save to preset',
                  onPressed: () => _saveToPreset(context),
                  icon: const Icon(Icons.bookmark_add_outlined),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(Icons.north_west),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _cancelEdit() {
    setState(() {
      _nameController.text = item.locationName ?? '';
      _isEditing = false;
    });
  }

  Future<void> _saveName(BuildContext context) async {
    setState(() => _isSaving = true);
    try {
      await context.read<DashboardProvider>().updateHistoryLocationName(
            item,
            _nameController.text,
          );
      if (!mounted) return;
      setState(() => _isEditing = false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveToPreset(BuildContext context) async {
    final provider = context.read<DashboardProvider>();
    final nameController = TextEditingController(
      text: item.locationName ?? item.coordinates,
    );
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save to Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Save this location to your presets?'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Preset name',
                hintText: 'Enter a name for this preset',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      await provider.savePreset(
        name: nameController.text.trim(),
        latitude: item.latitude,
        longitude: item.longitude,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to presets')),
        );
      }
    }
    nameController.dispose();
  }
}
