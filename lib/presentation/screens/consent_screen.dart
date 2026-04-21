import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../modules/privacy/models/privacy_preferences.dart';
import '../controllers/mvp_controller.dart';

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
    final controller = context.watch<MvpController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phase 1 Privacy & Safety',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This MVP stores your draft session locally, can query Google Places when enabled, and reserves a modular banner slot for Phase 1 monetization. Use it only on devices you control for QA or development work.',
                      ),
                      const SizedBox(height: 20),
                      CheckboxListTile(
                        value: _acceptedSafety,
                        onChanged: (value) {
                          setState(() => _acceptedSafety = value ?? false);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                            'I accept the safety and testing-only notice'),
                      ),
                      CheckboxListTile(
                        value: _allowSearch,
                        onChanged: (value) {
                          setState(() => _allowSearch = value ?? true);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                            'Allow Google Places requests for search autocomplete'),
                      ),
                      CheckboxListTile(
                        value: _allowAds,
                        onChanged: (value) {
                          setState(() => _allowAds = value ?? true);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                            'Allow a lightweight banner monetization slot'),
                      ),
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
                        ],
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: !_acceptedSafety
                            ? null
                            : () async {
                                await controller.saveConsent(
                                  PrivacyPreferences(
                                    hasCompletedConsent: true,
                                    acceptedSafetyNotice: _acceptedSafety,
                                    allowPlacesSearch: _allowSearch,
                                    allowBannerAds: _allowAds,
                                  ),
                                );
                                if (!mounted) return;
                                Navigator.of(this.context).pop();
                              },
                        child: const Text('Continue to Console'),
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

  void _copyLink(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label link copied: $value')),
    );
  }
}
