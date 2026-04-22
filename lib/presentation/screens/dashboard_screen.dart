import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/location_validator.dart';
import '../../domain/entities/location_preset.dart';
import '../../domain/entities/mock_location_session.dart';
import '../../services/openstreetmap_service.dart';
import '../providers/dashboard_provider.dart';
import 'consent_screen.dart';
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
  bool _consentChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<DashboardProvider>();
    final session = provider.session;
    if (session != null && _latitude.text.isEmpty) {
      _applySession(session);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_consentChecked && mounted) {
        _consentChecked = true;
        if (!provider.hasAcceptedConsent) {
          Navigator.pushNamed(context, ConsentScreen.routeName);
        } else if (!provider.hasSeenOnboarding) {
          Navigator.pushNamed(context, OnboardingScreen.routeName);
        }
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
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppTheme.cyan, AppTheme.purple],
          ).createShader(bounds),
          child: const Text(
            AppConstants.appName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        actions: [
          _IconButton(
            icon: Icons.history,
            onPressed: _openHistory,
          ),
          _IconButton(
            icon: Icons.bookmarks_outlined,
            onPressed: _openPresets,
          ),
          _IconButton(
            icon: Icons.settings_outlined,
            onPressed: () => Navigator.pushNamed(context, OnboardingScreen.routeName),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Status Card
              _StatusCard(active: active),
              const SizedBox(height: 24),
              // Search
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
              const SizedBox(height: 20),
              // Location Display
              if (provider.currentLocationName != null || provider.session != null)
                _LocationCard(
                  name: provider.currentLocationName ?? 'Custom Location',
                  lat: double.tryParse(_latitude.text) ?? provider.session?.latitude ?? 0,
                  lng: double.tryParse(_longitude.text) ?? provider.session?.longitude ?? 0,
                ),
              const SizedBox(height: 24),
              // Hidden form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Editable Coordinates
                    Row(
                      children: [
                        Expanded(
                          child: _CoordinateField(
                            controller: _latitude,
                            label: 'Latitude',
                            validator: (v) => LocationValidator.validateLatitude(v ?? ''),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CoordinateField(
                            controller: _longitude,
                            label: 'Longitude',
                            validator: (v) => LocationValidator.validateLongitude(v ?? ''),
                          ),
                        ),
                      ],
                    ),
                    _AdvancedParameters(
                      accuracyController: _accuracy,
                      speedController: _speed,
                      bearingController: _bearing,
                      intervalController: _interval,
                    ),
                    const SizedBox(height: 24),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _GradientButton(
                            onPressed: provider.isBusy || active ? null : _start,
                            gradient: AppTheme.cyan,
                            icon: Icons.play_arrow_rounded,
                            label: 'START',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _GradientButton(
                            onPressed: provider.isBusy || !active ? null : provider.stop,
                            gradient: AppTheme.purple,
                            icon: Icons.stop_rounded,
                            label: 'STOP',
                            isSecondary: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Messages
              if (provider.errorMessage != null)
                _MessageBox(
                  message: provider.errorMessage!,
                  isError: true,
                ),
              if (provider.infoMessage != null)
                _MessageBox(
                  message: provider.infoMessage!,
                  isError: false,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _applySession(MockLocationSession session) {
    _latitude.text = session.latitude.toString();
    _longitude.text = session.longitude.toString();
    _accuracy.text = session.accuracy.toString();
    _speed.text = session.speed.toString();
    _bearing.text = session.bearing.toString();
    _interval.text = session.intervalMs.toString();
  }

  Future<void> _start() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<DashboardProvider>();
    await provider.start(
      latitude: double.parse(_latitude.text),
      longitude: double.parse(_longitude.text),
      accuracy: double.tryParse(_accuracy.text) ?? AppConstants.defaultAccuracyMeters,
      speed: double.tryParse(_speed.text) ?? 0,
      bearing: double.tryParse(_bearing.text) ?? 0,
      intervalMs: int.tryParse(_interval.text) ?? AppConstants.defaultIntervalMs,
    );
  }

  void _openHistory() => Navigator.pushNamed(context, HistoryScreen.routeName);
  void _openPresets() => Navigator.pushNamed(context, PresetsScreen.routeName);
}

// Modern UI Components

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppTheme.cyan, size: 20),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: active
            ? LinearGradient(
                colors: [
                  AppTheme.green.withOpacity(0.2),
                  AppTheme.cyan.withOpacity(0.1),
                ],
              )
            : null,
        color: active ? null : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? AppTheme.green.withOpacity(0.5) : AppTheme.greyDark,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppTheme.green : AppTheme.grey,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppTheme.green.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                active ? 'MOCK ACTIVE' : 'READY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? AppTheme.green : AppTheme.grey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                active
                    ? 'Injecting location data'
                    : 'Select location to begin',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.grey,
                ),
              ),
            ],
          ),
        ],
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
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.cyan.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: AppTheme.white),
            decoration: InputDecoration(
              hintText: 'Try: "Tokyo, Japan" or "Central Park, New York"',
              hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.7)),
              prefixIcon: const Icon(Icons.search, color: AppTheme.cyan),
              suffixIcon: isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppTheme.cyan),
                        ),
                      ),
                    )
                  : controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.grey),
                          onPressed: onClear,
                        )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
        if (results.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.cyan.withOpacity(0.2),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppTheme.greyDark.withOpacity(0.5),
              ),
              itemBuilder: (context, index) {
                final result = results[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    result.name,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    result.displayName.length > 40
                        ? '${result.displayName.substring(0, 40)}...'
                        : result.displayName,
                    style: const TextStyle(color: AppTheme.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${result.lat.toStringAsFixed(3)}, ${result.lon.toStringAsFixed(3)}',
                      style: const TextStyle(
                        color: AppTheme.cyan,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  onTap: () => onResultSelected(result),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.name,
    required this.lat,
    required this.lng,
  });

  final String name;
  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.purple.withOpacity(0.2),
            AppTheme.cyan.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.purple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppTheme.pink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'SELECTED LOCATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.pink,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.grey,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HiddenTextField extends StatelessWidget {
  const _HiddenTextField({
    required this.controller,
    required this.validator,
  });

  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0,
      child: SizedBox(
        height: 0,
        child: TextFormField(
          controller: controller,
          validator: validator,
        ),
      ),
    );
  }
}

class _CoordinateField extends StatelessWidget {
  const _CoordinateField({
    required this.controller,
    required this.label,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.grey.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.cyan.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            style: const TextStyle(
              color: AppTheme.white,
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(
              hintText: label == 'Latitude' ? '35.6762' : '139.6503',
              hintStyle: TextStyle(
                color: AppTheme.grey.withOpacity(0.4),
                fontFamily: 'monospace',
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdvancedParameters extends StatefulWidget {
  const _AdvancedParameters({
    required this.accuracyController,
    required this.speedController,
    required this.bearingController,
    required this.intervalController,
  });

  final TextEditingController accuracyController;
  final TextEditingController speedController;
  final TextEditingController bearingController;
  final TextEditingController intervalController;

  @override
  State<_AdvancedParameters> createState() => _AdvancedParametersState();
}

class _AdvancedParametersState extends State<_AdvancedParameters> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => setState(() => _expanded = !_expanded),
          icon: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
            color: AppTheme.grey,
          ),
          label: Text(
            _expanded ? 'Hide advanced' : 'Advanced parameters',
            style: const TextStyle(color: AppTheme.grey),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _AdvancedField(
                  controller: widget.accuracyController,
                  label: 'Accuracy (m)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AdvancedField(
                  controller: widget.speedController,
                  label: 'Speed (m/s)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AdvancedField(
                  controller: widget.bearingController,
                  label: 'Bearing (°)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AdvancedField(
                  controller: widget.intervalController,
                  label: 'Interval (ms)',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AdvancedField extends StatelessWidget {
  const _AdvancedField({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppTheme.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.grey, fontSize: 12),
        filled: true,
        fillColor: AppTheme.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.onPressed,
    required this.gradient,
    required this.icon,
    required this.label,
    this.isSecondary = false,
  });

  final VoidCallback? onPressed;
  final Color gradient;
  final IconData icon;
  final String label;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: onPressed == null
          ? BoxDecoration(
              color: AppTheme.greyDark,
              borderRadius: BorderRadius.circular(16),
            )
          : BoxDecoration(
              color: gradient,
              borderRadius: BorderRadius.circular(16),
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: isSecondary && onPressed != null
                ? BoxDecoration(
                    color: AppTheme.background.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError
            ? AppTheme.pink.withOpacity(0.1)
            : AppTheme.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? AppTheme.pink.withOpacity(0.3)
              : AppTheme.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? AppTheme.pink : AppTheme.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? AppTheme.pink : AppTheme.green,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
