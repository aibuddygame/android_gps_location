import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  static const routeName = '/consent';

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _acceptedSafety = false;
  bool _allowSearch = true;
  bool _allowAds = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.cyan.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Phase 1 Privacy &\nSafety',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Description
                      const Text(
                        'This MVP stores your draft session locally, can query OpenStreetMap when enabled, and reserves a modular banner slot for Phase 1 monetization. Use it only on devices you control for QA or development work.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Checkboxes
                      _CheckboxItem(
                        value: _acceptedSafety,
                        onChanged: (v) => setState(() => _acceptedSafety = v ?? false),
                        title: 'I accept the safety and testing-only notice',
                      ),
                      const SizedBox(height: 16),
                      _CheckboxItem(
                        value: _allowSearch,
                        onChanged: (v) => setState(() => _allowSearch = v ?? true),
                        title: 'Allow OpenStreetMap requests for search autocomplete',
                      ),
                      const SizedBox(height: 16),
                      _CheckboxItem(
                        value: _allowAds,
                        onChanged: (v) => setState(() => _allowAds = v ?? true),
                        title: 'Allow a lightweight banner monetization slot',
                      ),
                      const SizedBox(height: 32),
                      // Privacy Policy button
                      _OutlineButton(
                        onPressed: () {
                          // Show privacy policy
                          _showPrivacyPolicy(context);
                        },
                        label: 'Privacy Policy',
                      ),
                      const SizedBox(height: 12),
                      // Safety button
                      _OutlineButton(
                        onPressed: () {
                          // Show safety info
                          _showSafetyInfo(context);
                        },
                        label: 'Safety',
                      ),
                      const SizedBox(height: 20),
                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _acceptedSafety
                                ? AppTheme.cyan
                                : AppTheme.greyDark,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _acceptedSafety
                                  ? () async {
                                      final provider = context.read<DashboardProvider>();
                                      await provider.saveConsent(
                                        acceptedSafety: _acceptedSafety,
                                        allowSearch: _allowSearch,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: Text(
                                  'Continue to Console',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _acceptedSafety
                                        ? AppTheme.background
                                        : AppTheme.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Privacy Policy', style: TextStyle(color: AppTheme.white)),
        content: const Text(
          'GPS Location Changer processes all data locally on your device. '
          'Location searches use OpenStreetMap API without sending personal data. '
          'No location history or personal information is collected or transmitted.',
          style: TextStyle(color: AppTheme.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.cyan)),
          ),
        ],
      ),
    );
  }

  void _showSafetyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Safety Information', style: TextStyle(color: AppTheme.white)),
        content: const Text(
          'This app is a developer tool for QA and testing purposes only. '
          'Use it only on devices you own or have explicit permission to test. '
          'Do not use for deceptive purposes or to circumvent location-based security.',
          style: TextStyle(color: AppTheme.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.cyan)),
          ),
        ],
      ),
    );
  }
}

class _CheckboxItem extends StatelessWidget {
  const _CheckboxItem({
    required this.value,
    required this.onChanged,
    required this.title,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: value ? AppTheme.cyan : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? AppTheme.cyan : AppTheme.greyDark,
                width: 2,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: AppTheme.background,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: value ? AppTheme.white : AppTheme.grey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.onPressed,
    required this.label,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.greyDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
