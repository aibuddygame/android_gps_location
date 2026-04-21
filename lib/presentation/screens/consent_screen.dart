import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
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

  @override
  Widget build(BuildContext context) {
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
                        'Privacy & Safety',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'GPS Location Changer is a developer tool for QA and testing. '
                        'Please read and accept the following before using the app.',
                      ),
                      const SizedBox(height: 20),
                      CheckboxListTile(
                        value: _acceptedSafety,
                        onChanged: (v) => setState(() => _acceptedSafety = v ?? false),
                        title: const Text('I understand this is a QA/testing tool'),
                        subtitle: const Text(
                          'I will only use this app on devices I control for legitimate '
                          'development or testing purposes.',
                        ),
                      ),
                      const Divider(),
                      CheckboxListTile(
                        value: _allowSearch,
                        onChanged: (v) => setState(() => _allowSearch = v ?? true),
                        title: const Text('Enable location search'),
                        subtitle: const Text(
                          'Allow the app to query OpenStreetMap for place searches. '
                          'No personal data is sent.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
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
                          child: const Text('Continue'),
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
}
