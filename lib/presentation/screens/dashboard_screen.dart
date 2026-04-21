import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/location_validator.dart';
import '../../domain/entities/location_preset.dart';
import '../../domain/entities/mock_location_session.dart';
import '../../services/openstreetmap_service.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/debug_panel.dart';
import '../widgets/location_name_display.dart';
import '../widgets/status_pill.dart';
import 'history_screen.dart';
import 'onboarding_screen.dart';
import 'presets_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _accuracy = TextEditingController();
  final _speed = TextEditingController();
  final _bearing = TextEditingController();
  final _interval = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<DashboardProvider>();
    final session = provider.session;
    if (session != null && _latitude.text.isEmpty) {
      _applySession(session);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!provider.hasSeenOnboarding && mounted) {
        Navigator.pushNamed(context, OnboardingScreen.routeName);
      }
    });
  }

  @override
  void dispose() {
    _latitude.dispose();
    _longitude.dispose();
    _accuracy.dispose();
    _speed.dispose();
    _bearing.dispose();
    _interval.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final active = provider.session?.isActive == true;
    if (_latitude.text.isEmpty && provider.session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _latitude.text.isEmpty) {
          _applySession(provider.session!);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Setup',
            onPressed: () =>
                Navigator.pushNamed(context, OnboardingScreen.routeName),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                StatusPill(
                  active: active,
                  label: active ? 'Active' : 'Inactive',
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _openHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
                TextButton.icon(
                  onPressed: _openPresets,
                  icon: const Icon(Icons.bookmarks_outlined),
                  label: const Text('Presets'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.errorMessage != null)
              _MessageBox(
                message: provider.errorMessage!,
                color: Colors.red.shade700,
              ),
            if (provider.infoMessage != null)
              _MessageBox(
                message: provider.infoMessage!,
                color: Colors.green.shade700,
              ),
            _SetupBanner(provider: provider),
            _SearchField(
              controller: _searchController,
              onChanged: provider.searchLocation,
              isSearching: provider.isSearching,
              results: provider.searchResults,
              onResultSelected: (result) {
                _latitude.text = result.lat.toString();
                _longitude.text = result.lon.toString();
                provider.applySearchResult(result);
              },
              onClear: () {
                _searchController.clear();
                provider.clearSearch();
              },
            ),
            if (provider.session != null) ...[
              LocationNameDisplay(
                latitude: provider.session!.latitude,
                longitude: provider.session!.longitude,
                locationName: provider.currentLocationName,
                isLoading: provider.isResolvingLocationName,
              ),
              const SizedBox(height: 16),
            ],
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitude,
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          validator: (value) =>
                              LocationValidator.validateLatitude(value ?? ''),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _longitude,
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          validator: (value) =>
                              LocationValidator.validateLongitude(value ?? ''),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _accuracy,
                          decoration: const InputDecoration(
                            labelText: 'Accuracy m',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) =>
                              LocationValidator.validateNonNegative(
                            value ?? '',
                            'Accuracy',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _speed,
                          decoration: const InputDecoration(
                            labelText: 'Speed m/s',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) =>
                              LocationValidator.validateNonNegative(
                            value ?? '',
                            'Speed',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _bearing,
                          decoration: const InputDecoration(
                            labelText: 'Bearing deg',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) =>
                              LocationValidator.validateNonNegative(
                            value ?? '',
                            'Bearing',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _interval,
                          decoration: const InputDecoration(
                            labelText: 'Interval ms',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              LocationValidator.validateInterval(
                            value ?? '',
                            AppConstants.minIntervalMs,
                            AppConstants.maxIntervalMs,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: provider.isBusy || active ? null : _start,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start mock'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              provider.isBusy || !active ? null : provider.stop,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DebugPanel(session: provider.session),
          ],
        ),
      ),
    );
  }

  Future<void> _openHistory() async {
    await Navigator.pushNamed(context, HistoryScreen.routeName);
    if (!mounted) return;
    final session = context.read<DashboardProvider>().session;
    if (session != null) _applySession(session);
  }

  Future<void> _openPresets() async {
    final preset = await Navigator.pushNamed<LocationPreset>(
      context,
      PresetsScreen.routeName,
    );
    if (preset == null) return;
    _latitude.text = preset.latitude.toStringAsFixed(7);
    _longitude.text = preset.longitude.toStringAsFixed(7);
    await _persistDraft();
  }

  Future<void> _start() async {
    if (!_formKey.currentState!.validate()) return;
    await _persistDraft();
    if (!mounted) return;
    await context.read<DashboardProvider>().start(
          latitude: double.parse(_latitude.text.trim()),
          longitude: double.parse(_longitude.text.trim()),
          accuracy: _parseDouble(
            _accuracy.text,
            AppConstants.defaultAccuracyMeters,
          ),
          speed: _parseDouble(_speed.text, 0),
          bearing: _parseDouble(_bearing.text, 0),
          intervalMs: int.parse(_interval.text.trim()),
        );
  }

  Future<void> _persistDraft() {
    return context.read<DashboardProvider>().persistDraft(
          MockLocationSession(
            latitude: double.parse(_latitude.text.trim()),
            longitude: double.parse(_longitude.text.trim()),
            accuracy: _parseDouble(
              _accuracy.text,
              AppConstants.defaultAccuracyMeters,
            ),
            speed: _parseDouble(_speed.text, 0),
            bearing: _parseDouble(_bearing.text, 0),
            intervalMs: int.tryParse(_interval.text.trim()) ??
                AppConstants.defaultIntervalMs,
          ),
        );
  }

  void _applySession(MockLocationSession session) {
    _latitude.text = session.latitude.toStringAsFixed(7);
    _longitude.text = session.longitude.toStringAsFixed(7);
    _accuracy.text = session.accuracy.toStringAsFixed(1);
    _speed.text = session.speed.toStringAsFixed(1);
    _bearing.text = session.bearing.toStringAsFixed(1);
    _interval.text = session.intervalMs.toString();
  }

  double _parseDouble(String value, double fallback) {
    return double.tryParse(value.trim()) ?? fallback;
  }
}

class _SetupBanner extends StatelessWidget {
  const _SetupBanner({required this.provider});

  final DashboardProvider provider;

  @override
  Widget build(BuildContext context) {
    final status = provider.permissionStatus;
    if (status?.ready == true) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Setup required',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Grant location permission, enable device location, and select this app as the mock-location app.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: provider.refreshChecks,
                  child: const Text('Recheck'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, OnboardingScreen.routeName),
                  child: const Text('Setup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(message, style: TextStyle(color: color)),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.isSearching,
    required this.results,
    required this.onResultSelected,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isSearching;
  final List<OSMSearchResult> results;
  final ValueChanged<OSMSearchResult> onResultSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: 'Search Location',
            hintText: 'Type place name (e.g., Tokyo Station)',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: onClear,
                      )
                    : null,
          ),
        ),
        if (results.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final result = results[index];
                return ListTile(
                  dense: true,
                  title: Text(result.name),
                  subtitle: Text(
                    '${result.displayName.substring(0, result.displayName.length > 50 ? 50 : result.displayName.length)}...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${result.lat.toStringAsFixed(4)}, ${result.lon.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () => onResultSelected(result),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
