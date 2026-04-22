import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/location_validator.dart';
import '../../domain/entities/location_preset.dart';
import '../providers/dashboard_provider.dart';

class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  static const routeName = '/presets';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Presets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPresetEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Save'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.presets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final preset = provider.presets[index];
          return _PresetTile(preset: preset);
        },
      ),
    );
  }

  void _showPresetEditor(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final provider = context.read<DashboardProvider>();
    final session = provider.session;
    final name = TextEditingController();
    final latitude = TextEditingController(
      text: session?.latitude.toStringAsFixed(7) ?? '',
    );
    final longitude = TextEditingController(
      text: session?.longitude.toStringAsFixed(7) ?? '',
    );

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save preset'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: latitude,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                validator: (value) =>
                    LocationValidator.validateLatitude(value ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: longitude,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                validator: (value) =>
                    LocationValidator.validateLongitude(value ?? ''),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await provider.savePreset(
                name: name.text,
                latitude: double.parse(latitude.text.trim()),
                longitude: double.parse(longitude.text.trim()),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _PresetTile extends StatefulWidget {
  const _PresetTile({required this.preset});

  final LocationPreset preset;

  @override
  State<_PresetTile> createState() => _PresetTileState();
}

class _PresetTileState extends State<_PresetTile> {
  late final TextEditingController _nameController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  bool _isEditing = false;

  LocationPreset get preset => widget.preset;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: preset.name);
    _latController = TextEditingController(text: preset.latitude.toStringAsFixed(7));
    _lngController = TextEditingController(text: preset.longitude.toStringAsFixed(7));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DashboardProvider>();

    if (_isEditing) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  isDense: true,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _lngController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() => _isEditing = false);
                      _nameController.text = preset.name;
                      _latController.text = preset.latitude.toStringAsFixed(7);
                      _lngController.text = preset.longitude.toStringAsFixed(7);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      final latError = LocationValidator.validateLatitude(_latController.text);
                      final lngError = LocationValidator.validateLongitude(_lngController.text);
                      if (latError != null || lngError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(latError ?? lngError!),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      // Delete old preset and create new one
                      await provider.deletePreset(preset.id);
                      await provider.savePreset(
                        name: _nameController.text.trim().isEmpty
                            ? preset.name
                            : _nameController.text.trim(),
                        latitude: double.parse(_latController.text.trim()),
                        longitude: double.parse(_lngController.text.trim()),
                      );
                      if (mounted) setState(() => _isEditing = false);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: ListTile(
        title: Text(preset.name),
        subtitle: Text(
          '${preset.latitude.toStringAsFixed(7)}, '
          '${preset.longitude.toStringAsFixed(7)}',
        ),
        leading: Icon(preset.isBuiltIn ? Icons.place : Icons.bookmark),
        trailing: preset.isBuiltIn
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => setState(() => _isEditing = true),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context),
                    tooltip: 'Delete',
                  ),
                ],
              ),
        onTap: () => Navigator.pop<LocationPreset>(context, preset),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<DashboardProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Delete "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deletePreset(preset.id);
    }
  }
}
