import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../controllers/mvp_controller.dart';
import '../widgets/technical_panel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MvpController>();
    final privacy = controller.privacy;
    final settings = controller.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & About')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TechnicalPanel(
              title: 'Privacy',
              subtitle: 'Review and change consent choices.',
              child: Column(
                children: [
                  SwitchListTile(
                    value: privacy.allowPlacesSearch,
                    onChanged: (value) => controller.updatePrivacy(
                      privacy.copyWith(allowPlacesSearch: value),
                    ),
                    title: const Text('Allow Google Places search'),
                  ),
                  SwitchListTile(
                    value: privacy.allowBannerAds,
                    onChanged: (value) => controller.updatePrivacy(
                      privacy.copyWith(allowBannerAds: value),
                    ),
                    title: const Text('Allow banner monetization slot'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TechnicalPanel(
              title: 'Interface',
              subtitle: 'Compact diagnostics and MVP shell settings.',
              child: Column(
                children: [
                  SwitchListTile(
                    value: settings.showVerboseLogs,
                    onChanged: (value) => controller.updateSettings(
                      settings.copyWith(showVerboseLogs: value),
                    ),
                    title: const Text('Verbose session logs'),
                  ),
                  SwitchListTile(
                    value: settings.showBannerSlot,
                    onChanged: (value) => controller.updateSettings(
                      settings.copyWith(showBannerSlot: value),
                    ),
                    title: const Text('Show banner slot'),
                  ),
                  SwitchListTile(
                    value: settings.keepAdvancedCollapsed,
                    onChanged: (value) => controller.updateSettings(
                      settings.copyWith(keepAdvancedCollapsed: value),
                    ),
                    title: const Text('Keep advanced block collapsed'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TechnicalPanel(
              title: 'About',
              subtitle: 'Links, version, and contact.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Version ${AppConstants.appVersion}'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => _copyLink(
                          context,
                          'Privacy Policy',
                          AppConstants.privacyPolicyUrl,
                        ),
                        child: const Text('Privacy Policy'),
                      ),
                      OutlinedButton(
                        onPressed: () => _copyLink(
                          context,
                          'Safety',
                          AppConstants.safetyUrl,
                        ),
                        child: const Text('Safety'),
                      ),
                      OutlinedButton(
                        onPressed: () => _copyLink(
                          context,
                          'Contact',
                          AppConstants.contactUrl,
                        ),
                        child: const Text('Contact'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Support: ${AppConstants.supportEmail}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyLink(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label link copied: $value')),
    );
  }
}
