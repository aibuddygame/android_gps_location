import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/services/permission_handler.dart';
import '../../domain/entities/mock_location_session.dart';
import '../controllers/mvp_controller.dart';
import '../widgets/log_console.dart';
import '../widgets/search_results_list.dart';
import '../widgets/status_strip.dart';
import '../widgets/technical_panel.dart';
import 'consent_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _accuracyController = TextEditingController();
  final _speedController = TextEditingController();
  final _bearingController = TextEditingController();
  final _intervalController = TextEditingController();
  bool _consentPushed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.watch<MvpController>();
    _syncFields(controller.session);
    if (controller.searchQuery.isNotEmpty &&
        _searchController.text != controller.searchQuery) {
      _searchController.text = controller.searchQuery;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && controller.requiresConsent && !_consentPushed) {
        _consentPushed = true;
        Navigator.of(context).pushNamed(ConsentScreen.routeName).then((_) {
          _consentPushed = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _accuracyController.dispose();
    _speedController.dispose();
    _bearingController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MvpController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.pushNamed(context, SettingsScreen.routeName);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings & About'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  StatusStrip(
                    session: controller.session,
                    locationName: controller.selectedPlaceLabel,
                  ),
                  const SizedBox(height: 16),
                  if (controller.errorMessage != null)
                    _MessageStrip(
                      label: 'ERROR',
                      message: controller.errorMessage!,
                      color: const Color(0xFFFF5E7A),
                    ),
                  if (controller.statusMessage != null)
                    _MessageStrip(
                      label: 'INFO',
                      message: controller.statusMessage!,
                      color: const Color(0xFF15D8FF),
                    ),
                  TechnicalPanel(
                    title: 'Input & Control',
                    subtitle:
                        'Search by place text, tune coordinates, then start or stop the foreground injector.',
                    trailing: _ReadinessBadge(
                      permissionStatus: controller.permissionStatus,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: controller.searchPlaces,
                            decoration: InputDecoration(
                              labelText: 'Location Search',
                              hintText: 'Search with Google Places',
                              suffixIcon: controller.isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox.square(
                                        dimension: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.search),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SearchResultsList(
                            results: controller.searchResults,
                            onSelected: (item) async {
                              await controller.applySearchResult(item);
                              _syncFields(controller.session);
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _latitudeController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                                  decoration: const InputDecoration(
                                      labelText: 'Latitude'),
                                  validator: _validateLatitude,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _longitudeController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Longitude',
                                  ),
                                  validator: _validateLongitude,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: controller.isMutating
                                      ? null
                                      : () => _start(controller),
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: const Text('Start'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: controller.isMutating ||
                                          !controller.session.isActive
                                      ? null
                                      : controller.stopMock,
                                  icon: const Icon(Icons.stop_rounded),
                                  label: const Text('Stop'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ExpansionTile(
                            initiallyExpanded: controller.advancedExpanded,
                            onExpansionChanged: controller.setAdvancedExpanded,
                            tilePadding: EdgeInsets.zero,
                            title: const Text('Advanced Parameters'),
                            subtitle: const Text(
                              'Accuracy, speed, bearing, and injection interval.',
                            ),
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _accuracyController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Accuracy (m)',
                                      ),
                                      validator: _validateNonNegative,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _speedController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Speed (m/s)',
                                      ),
                                      validator: _validateNonNegative,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _bearingController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Bearing (deg)',
                                      ),
                                      validator: _validateNonNegative,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _intervalController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Interval (ms)',
                                      ),
                                      validator: _validateInterval,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _ReadinessActions(controller: controller),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TechnicalPanel(
                    title: 'Output & Debug',
                    subtitle:
                        'Session health, last injection clock, log stream, and monetization slot.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _DebugMetric(
                              label: 'Last Injection',
                              value: formatClock(
                                controller.session.lastUpdateAt,
                              ),
                            ),
                            _DebugMetric(
                              label: 'Session Status',
                              value: controller.session.isActive
                                  ? 'running'
                                  : 'stopped',
                            ),
                            _DebugMetric(
                              label: 'Background',
                              value: controller.session.isBackgroundCapable
                                  ? 'enabled'
                                  : 'unknown',
                            ),
                            _DebugMetric(
                              label: 'Ad Layer',
                              value: controller.bannerSlot.label.toLowerCase(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LogConsole(logs: controller.logs),
                        if (controller.bannerSlot.visible) ...[
                          const SizedBox(height: 12),
                          _BannerSlot(
                            label: controller.bannerSlot.label,
                            message: controller.bannerSlot.message,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _start(MvpController controller) async {
    if (!_formKey.currentState!.validate()) return;
    final next = MockLocationSession(
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      accuracy: double.parse(_accuracyController.text.trim()),
      speed: double.parse(_speedController.text.trim()),
      bearing: double.parse(_bearingController.text.trim()),
      intervalMs: int.parse(_intervalController.text.trim()),
      isBackgroundCapable: controller.session.isBackgroundCapable,
    );
    await controller.updateDraft(next);
    await controller.startMock(
      latitude: next.latitude,
      longitude: next.longitude,
      accuracy: next.accuracy,
      speed: next.speed,
      bearing: next.bearing,
      intervalMs: next.intervalMs,
    );
  }

  void _syncFields(MockLocationSession session) {
    _latitudeController.text = formatCoordinate(session.latitude);
    _longitudeController.text = formatCoordinate(session.longitude);
    _accuracyController.text = session.accuracy.toStringAsFixed(1);
    _speedController.text = session.speed.toStringAsFixed(1);
    _bearingController.text = session.bearing.toStringAsFixed(1);
    _intervalController.text = session.intervalMs.toString();
  }

  String? _validateLatitude(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed < -90 || parsed > 90) {
      return 'Enter latitude between -90 and 90.';
    }
    return null;
  }

  String? _validateLongitude(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed < -180 || parsed > 180) {
      return 'Enter longitude between -180 and 180.';
    }
    return null;
  }

  String? _validateNonNegative(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) return 'Enter 0 or higher.';
    return null;
  }

  String? _validateInterval(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null ||
        parsed < AppConstants.minIntervalMs ||
        parsed > AppConstants.maxIntervalMs) {
      return 'Use ${AppConstants.minIntervalMs}-${AppConstants.maxIntervalMs} ms.';
    }
    return null;
  }
}

class _MessageStrip extends StatelessWidget {
  const _MessageStrip({
    required this.label,
    required this.message,
    required this.color,
  });

  final String label;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          color: color.withValues(alpha: 0.08),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                  ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _ReadinessBadge extends StatelessWidget {
  const _ReadinessBadge({required this.permissionStatus});

  final PermissionStatusSnapshot? permissionStatus;

  @override
  Widget build(BuildContext context) {
    final ready = permissionStatus?.ready == true;
    return Chip(label: Text(ready ? 'READY' : 'SETUP REQUIRED'));
  }
}

class _ReadinessActions extends StatelessWidget {
  const _ReadinessActions({required this.controller});

  final MvpController controller;

  @override
  Widget build(BuildContext context) {
    final status = controller.permissionStatus;
    final hasPermission = status?.hasLocationPermission == true;
    final locationEnabled = status?.locationServiceEnabled == true;
    final mockEnabled = status?.mockLocationEnabled == true;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton(
          onPressed:
              hasPermission ? null : controller.requestLocationPermission,
          child: Text(hasPermission ? 'Permission OK' : 'Grant Permission'),
        ),
        OutlinedButton(
          onPressed: locationEnabled ? null : controller.requestLocationService,
          child: Text(locationEnabled ? 'Location ON' : 'Enable Location'),
        ),
        OutlinedButton(
          onPressed: mockEnabled ? null : controller.openDeveloperOptions,
          child: Text(mockEnabled ? 'Mock App Set' : 'Open Dev Options'),
        ),
      ],
    );
  }
}

class _DebugMetric extends StatelessWidget {
  const _DebugMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
        color: const Color(0xFF11161A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF8A9BA6),
                ),
          ),
          const SizedBox(height: 4),
          Text(value, style: monoTextStyle(context, size: 12)),
        ],
      ),
    );
  }
}

class _BannerSlot extends StatelessWidget {
  const _BannerSlot({required this.label, required this.message});

  final String label;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        color: const Color(0xFF121A1F),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: const Color(0xFF15D8FF).withValues(alpha: 0.14),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF15D8FF),
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
