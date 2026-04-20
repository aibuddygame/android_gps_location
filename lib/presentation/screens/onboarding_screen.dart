import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/setup';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final status = provider.permissionStatus;
    return Scaffold(
      appBar: AppBar(title: const Text('Setup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Prepare this test device',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _SetupTile(
            title: 'Location permission',
            subtitle: 'Required so Android allows mock location updates.',
            done: status?.hasLocationPermission == true,
            actionLabel: 'Grant',
            onPressed: provider.requestPermission,
          ),
          _SetupTile(
            title: 'Device location',
            subtitle: 'Turn on system location services.',
            done: status?.locationServiceEnabled == true,
            actionLabel: 'Enable',
            onPressed: provider.requestLocationService,
          ),
          _SetupTile(
            title: 'Mock location app',
            subtitle: 'Select this app in Developer Options.',
            done: status?.mockLocationEnabled == true,
            actionLabel: 'Open',
            onPressed: provider.openDeveloperOptions,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await provider.refreshChecks();
              await provider.completeOnboarding();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _SetupTile extends StatelessWidget {
  const _SetupTile({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final bool done;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(done ? Icons.check_circle : Icons.info_outline),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: TextButton(
          onPressed: done ? null : onPressed,
          child: Text(done ? 'Ready' : actionLabel),
        ),
      ),
    );
  }
}
