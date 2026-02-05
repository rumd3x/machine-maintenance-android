import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appVersion = '1.0.0';
  static const String authorName = 'Rumd3x';
  static const String authorWebsite = 'edmurcardoso.com.br';
  static const String websiteUrl = 'https://edmurcardoso.com.br';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            
            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.accentBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.build_circle,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // App Name
            Text(
              'Machine Maintenance Tracker',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Version
            Text(
              'Version $appVersion',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            
            // Description
            Text(
              'A local, offline-first application for tracking vehicle and machine maintenance.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Divider
            const Divider(),
            const SizedBox(height: 32),
            
            // Credits Section
            Text(
              'DEVELOPED BY',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            
            // Author Name
            Text(
              authorName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            
            // Website Link
            InkWell(
              onTap: _launchWebsite,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentBlue,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language,
                      color: AppTheme.accentBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      authorWebsite,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.accentBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.open_in_new,
                      color: AppTheme.accentBlue,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            
            // Features List
            _buildFeaturesList(context),
            
            const SizedBox(height: 32),
            
            // Copyright
            Text(
              '© ${DateTime.now().year} $authorName',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All rights reserved',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      '100% Offline - No cloud required',
      'Track multiple machines',
      'Maintenance reminders',
      'Maintenance history',
      'Photo storage',
      'Customizable intervals',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'FEATURES',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppTheme.statusOptimal,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        )),
      ],
    );
  }

  Future<void> _launchWebsite() async {
    final uri = Uri.parse(websiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
