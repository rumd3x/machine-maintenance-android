import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/machine.dart';
import '../models/maintenance_record.dart';
import '../services/machine_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class MaintenanceHistoryScreen extends StatefulWidget {
  final Machine machine;

  const MaintenanceHistoryScreen({
    super.key,
    required this.machine,
  });

  @override
  State<MaintenanceHistoryScreen> createState() => _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  List<MaintenanceRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    
    _records = await context.read<MachineProvider>().getMaintenanceRecords(
      widget.machine.id!,
    );
    
    setState(() => _isLoading = false);
  }

  Future<void> _deleteRecord(MaintenanceRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Maintenance Record'),
        content: Text(
          'Are you sure you want to delete this ${maintenanceTypeNames[record.maintenanceType] ?? record.maintenanceType} record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<MachineProvider>().deleteMaintenanceRecord(record.id!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maintenance record deleted'),
              backgroundColor: AppTheme.statusOptimal,
            ),
          );
          
          // Reload records after deletion
          await _loadRecords();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting record: $e'),
              backgroundColor: AppTheme.statusOverdue,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Just now';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  IconData _getMaintenanceIcon(String type) {
    if (type == maintenanceTypeOilChange) {
      return Icons.water_drop;
    } else if (type == maintenanceTypeSparkPlug) {
      return Icons.electrical_services;
    } else if (type == maintenanceTypeFuel) {
      return Icons.local_gas_station;
    } else if (type == maintenanceTypeFilterCleaning) {
      return Icons.air;
    } else if (type == maintenanceTypeBrakeFluid) {
      return Icons.opacity;
    } else if (type == maintenanceTypeCoolant) {
      return Icons.ac_unit;
    } else if (type == maintenanceTypeChainOiling) {
      return Icons.settings;
    } else if (type == maintenanceTypeBrakeInspection) {
      return Icons.car_repair;
    } else if (type == maintenanceTypeGeneral) {
      return Icons.build_circle;
    } else {
      return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Maintenance History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    return _buildRecordCard(_records[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No maintenance records yet',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a maintenance record to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(MaintenanceRecord record) {
    final maintenanceName = maintenanceTypeNames[record.maintenanceType] ?? 
                           record.maintenanceType.replaceAll('_', ' ');
    final timeAgo = _getTimeAgo(record.date);
    final formattedDate = _formatDate(record.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.accentBlue,
              child: Icon(
                _getMaintenanceIcon(record.maintenanceType),
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
            title: Text(
              maintenanceName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$formattedDate • $timeAgo',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.odometerAtService.toStringAsFixed(0)} ${widget.machine.odometerUnit}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (record.fuelAmount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Fuel: ${record.fuelAmount!.toStringAsFixed(1)} L',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: () => _deleteRecord(record),
              tooltip: 'Delete',
            ),
          ),
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
