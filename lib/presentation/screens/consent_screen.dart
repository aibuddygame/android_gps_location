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
  int _currentPage = 0;

  final List<_ConsentPage> _pages = const [
    _ConsentPage(
      icon: Icons.warning_amber_rounded,
      iconColor: AppTheme.yellow,
      title: 'Important Notice',
      description:
          'GPS Location Changer is a developer tool designed for QA testing, '
          'app development, and location-based service testing ONLY.',
    ),
    _ConsentPage(
      icon: Icons.shield_outlined,
      iconColor: AppTheme.cyan,
      title: 'Responsible Use',
      description:
          'This app should only be used on devices you own or have explicit '
          'permission to test. Do not use for deceptive purposes.',
    ),
    _ConsentPage(
      icon: Icons.privacy_tip_outlined,
      iconColor: AppTheme.purple,
      title: 'Privacy',
      description:
          'Location data is processed locally. OpenStreetMap queries are '
          'anonymous. No personal data is collected or stored.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // App Icon/Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.cyanGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.cyanGlow,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 40,
                    color: AppTheme.background,
                  ),
                ),
                const SizedBox(height: 24),
                // App Name
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.cyan,
                  ),
                ),
                const SizedBox(height: 40),
                // Page Content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.cyan.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Page indicator
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length + 1,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == _currentPage
                                      ? AppTheme.cyan
                                      : AppTheme.greyDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _currentPage < _pages.length
                                ? _buildInfoPage(_pages[_currentPage])
                                : _buildConsentPage(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Navigation buttons
                if (_currentPage < _pages.length)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _GradientButton(
                      onPressed: () => setState(() => _currentPage++),
                      label: 'Next',
                      icon: Icons.arrow_forward,
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _GradientButton(
                      onPressed: _acceptedSafety
                          ? () {
                              final provider = context.read<DashboardProvider>();
                              provider.saveConsent(
                                acceptedSafety: _acceptedSafety,
                                allowSearch: _allowSearch,
                              );
                              Navigator.pop(context);
                            }
                          : null,
                      label: 'Get Started',
                      icon: Icons.check,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPage(_ConsentPage page) {
    return Padding(
      key: ValueKey(page.title),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: page.iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 40,
              color: page.iconColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConsentPage() {
    return Padding(
      key: const ValueKey('consent'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Before You Start',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 24),
          _ConsentCheckbox(
            value: _acceptedSafety,
            onChanged: (v) => setState(() => _acceptedSafety = v ?? false),
            title: 'I understand this is a QA/testing tool',
            subtitle:
                'I will only use this app on devices I control for legitimate '
                'development or testing purposes.',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _ConsentCheckbox(
            value: _allowSearch,
            onChanged: (v) => setState(() => _allowSearch = v ?? true),
            title: 'Enable location search',
            subtitle:
                'Allow the app to query OpenStreetMap for place searches. '
                'No personal data is sent.',
            isRequired: false,
          ),
          const Spacer(),
          if (!_acceptedSafety)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.pink,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please accept the terms to continue',
                      style: TextStyle(
                        color: AppTheme.pink,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ConsentPage {
  const _ConsentPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
}

class _ConsentCheckbox extends StatelessWidget {
  const _ConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    required this.isRequired,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String title;
  final String subtitle;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? AppTheme.cyan.withOpacity(0.1)
            : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? AppTheme.cyan.withOpacity(0.5)
              : AppTheme.greyDark,
        ),
      ),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: value ? AppTheme.cyan : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: value ? AppTheme.cyan : AppTheme.grey,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: value ? AppTheme.white : AppTheme.grey,
                            ),
                          ),
                        ),
                        if (isRequired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.pink.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Required',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.pink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: onPressed == null
          ? BoxDecoration(
              color: AppTheme.greyDark,
              borderRadius: BorderRadius.circular(16),
            )
          : BoxDecoration(
              gradient: AppTheme.cyanGradient,
              borderRadius: BorderRadius.circular(16),
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.background,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                color: AppTheme.background,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
