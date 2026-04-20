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
                  : IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => provider.deletePreset(preset.id),
                    ),
              onTap: () => Navigator.pop<LocationPreset>(context, preset),
            ),
          );
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
