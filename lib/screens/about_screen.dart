import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../utils/app_theme.dart';
import '../services/database_service.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const String appVersion = '1.0.0';
  static const String authorName = 'Rumd3x';
  static const String authorWebsite = 'edmurcardoso.com.br';
  static const String websiteUrl = 'https://edmurcardoso.com.br';
  static const String githubUrl = 'https://github.com/rumd3x/machine-maintenance-android';

  final DatabaseService _databaseService = DatabaseService();
  bool _isExporting = false;
  bool _isImporting = false;

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
            const SizedBox(height: 32),
            
            // Data Management Section
            _buildDataManagement(context),
            
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
            const SizedBox(height: 12),
            
            // GitHub Repository Link
            InkWell(
              onTap: _launchGitHub,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.textSecondary.withAlpha((0.3 * 255).round()),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.code,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'View on GitHub',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.open_in_new,
                      color: AppTheme.textSecondary,
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

  Widget _buildDataManagement(BuildContext context) {
    return Column(
      children: [
        Text(
          'DATA MANAGEMENT',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Backup and restore your maintenance data',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isExporting || _isImporting ? null : _exportDatabase,
                icon: _isExporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(_isExporting ? 'Exporting...' : 'Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isExporting || _isImporting ? null : _importDatabase,
                icon: _isImporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(_isImporting ? 'Importing...' : 'Import'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.statusOptimal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
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

  Future<void> _launchGitHub() async {
    final uri = Uri.parse(githubUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchWebsite() async {
    final uri = Uri.parse(websiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _exportDatabase() async {
    setState(() => _isExporting = true);

    try {
      // Get Downloads directory (or Documents on older Android versions)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Navigate to a user-accessible folder
          final List<String> paths = directory.path.split('/');
          final int index = paths.indexWhere((element) => element == 'Android');
          if (index != -1) {
            directory = Directory(paths.sublist(0, index).join('/') + '/Download');
          }
        }
      }
      directory ??= await getApplicationDocumentsDirectory();

      // Ensure directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final exportPath = await _databaseService.exportDatabase(directory.path);

      if (exportPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database exported to:\n${exportPath.split('/').last}'),
            backgroundColor: AppTheme.statusOptimal,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.statusOverdue,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _importDatabase() async {
    try {
      // Show warning dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Database'),
          content: const Text(
            'This will replace all your current data with the imported backup. '
            'This action cannot be undone.\n\n'
            'Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusWarning,
              ),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() => _isImporting = true);

      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isImporting = false);
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('Could not access selected file');
      }

      // Import database
      final success = await _databaseService.importDatabase(filePath);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database imported successfully! Please restart the app.'),
            backgroundColor: AppTheme.statusOptimal,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: AppTheme.statusOverdue,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }
}
