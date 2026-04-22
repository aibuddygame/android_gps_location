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
          const SizedBox(height: 24),
          // Policy Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _showPrivacyPolicy(context),
                child: const Text('Privacy Policy'),
              ),
              const Text('•', style: TextStyle(color: Colors.grey)),
              TextButton(
                onPressed: () => _showTermsOfService(context),
                child: const Text('Terms of Service'),
              ),
              const Text('•', style: TextStyle(color: Colors.grey)),
              TextButton(
                onPressed: () => _showSafetyNotice(context),
                child: const Text('Safety'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'GPS Fake processes all data locally on your device. '
            'Location searches use OpenStreetMap API without sending personal data. '
            'No location history or personal information is collected, transmitted, or stored on external servers. '
            'All mock location settings and history remain on your device only.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'GPS Fake is a developer tool designed for QA testing and development purposes only.\n\n'
            'By using this app, you agree to:\n'
            '• Use it only on devices you own or have explicit permission to test\n'
            '• Not use it for deceptive purposes or to circumvent location-based security\n'
            '• Accept full responsibility for how you use this tool\n\n'
            'This app is provided "as is" without warranties of any kind.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSafetyNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Safety Notice'),
        content: const SingleChildScrollView(
          child: Text(
            'Important Safety Information:\n\n'
            '• This app is for QA testing and development only\n'
            '• Use only on devices you control\n'
            '• Do not use to deceive location-based services\n'
            '• Do not use to circumvent security or safety systems\n'
            '• Always comply with local laws and regulations\n\n'
            'Misuse of mock location tools may violate terms of service '
            'or local laws in your jurisdiction.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
