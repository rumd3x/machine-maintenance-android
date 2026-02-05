import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/machine.dart';
import '../models/maintenance_record.dart';
import '../models/maintenance_status.dart';
import '../services/machine_provider.dart';
import '../widgets/status_indicator.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class MachineDetailScreen extends StatefulWidget {
  final int machineId;

  const MachineDetailScreen({
    super.key,
    required this.machineId,
  });

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen> {
  Machine? _machine;
  List<MaintenanceRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final provider = context.read<MachineProvider>();
    _machine = provider.getMachine(widget.machineId);
    
    if (_machine != null) {
      _records = await provider.getMaintenanceRecords(widget.machineId);
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_machine == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Machine not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroImage(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editMachine,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteMachine,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Machine Info Card
                _buildInfoCard(),
                
                const SizedBox(height: 16),
                
                // Status Indicators
                _buildStatusSection(),
                
                const SizedBox(height: 24),
                
                // Recent Activity
                _buildRecentActivity(),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'update_odometer',
            onPressed: _updateOdometer,
            child: const Icon(Icons.speed),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add_maintenance',
            onPressed: _addMaintenance,
            icon: const Icon(Icons.build),
            label: const Text('Add Service'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    if (_machine!.imagePath != null && File(_machine!.imagePath!).existsSync()) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(_machine!.imagePath!),
            fit: BoxFit.cover,
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.primaryBackground.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.accentBlue, AppTheme.primaryBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(
          Icons.directions_car,
          size: 120,
          color: AppTheme.textSecondary,
        ),
      );
    }
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Machine Name
            Text(
              _machine!.displayName,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 4),
            
            // Brand and Model
            Text(
              '${_machine!.year ?? ''} ${_machine!.brand} ${_machine!.model}'.trim(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textAccent,
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Key Metrics Row
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    'ODOMETER',
                    '${_machine!.currentOdometer.toStringAsFixed(0)} ${_machine!.odometerUnit}',
                    Icons.speed,
                  ),
                ),
                if (_machine!.tankSize != null)
                  Expanded(
                    child: _buildMetric(
                      'FUEL CAPACITY',
                      '${_machine!.tankSize!.toStringAsFixed(1)} Liters',
                      Icons.local_gas_station,
                    ),
                  ),
              ],
            ),
            
            if (_machine!.serialNumber != null || _machine!.oilType != null || _machine!.sparkPlugType != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Additional Details
              if (_machine!.serialNumber != null)
                _buildDetailRow('Serial Number', _machine!.serialNumber!),
              if (_machine!.oilType != null)
                _buildDetailRow('Oil Type', _machine!.oilType!),
              if (_machine!.sparkPlugType != null)
                _buildDetailRow('Spark Plug', _machine!.sparkPlugType!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    // TODO: Calculate actual status from maintenance intervals
    // For now, showing example statuses
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Maintenance Status',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatusIndicator(
                label: 'Systems',
                status: MaintenanceStatusType.optimal,
                icon: Icons.check_circle,
              ),
              StatusIndicator(
                label: 'Oil Life',
                status: MaintenanceStatusType.checkSoon,
                icon: Icons.water_drop,
              ),
              StatusIndicator(
                label: 'Brakes',
                status: MaintenanceStatusType.overdue,
                icon: Icons.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              if (_records.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full maintenance history
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_records.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No maintenance records yet',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ..._records.take(5).map((record) => _buildActivityItem(record)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(MaintenanceRecord record) {
    final timeAgo = _getTimeAgo(record.date);
    final maintenanceName = maintenanceTypeNames[record.maintenanceType] ?? 
                           record.maintenanceType.replaceAll('_', ' ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
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
        subtitle: Text(
          timeAgo,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Text(
          '${record.odometerAtService.toStringAsFixed(0)} ${_machine!.odometerUnit}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  IconData _getMaintenanceIcon(String type) {
    switch (type) {
      case maintenanceTypeOilChange:
        return Icons.water_drop;
      case maintenanceTypeFilterCleaning:
        return Icons.filter_alt;
      case maintenanceTypeChainOiling:
        return Icons.link;
      case maintenanceTypeBrakeFluid:
      case maintenanceTypeBrakeInspection:
        return Icons.car_repair;
      case maintenanceTypeCoolant:
        return Icons.ac_unit;
      case maintenanceTypeSparkPlug:
        return Icons.electrical_services;
      default:
        return Icons.build;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  void _updateOdometer() {
    showDialog(
      context: context,
      builder: (context) => _UpdateOdometerDialog(machine: _machine!),
    ).then((updated) {
      if (updated == true) {
        _loadData();
      }
    });
  }

  void _addMaintenance() {
    showDialog(
      context: context,
      builder: (context) => _AddMaintenanceDialog(machine: _machine!),
    ).then((added) {
      if (added == true) {
        _loadData();
      }
    });
  }

  void _editMachine() {
    // TODO: Navigate to edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon')),
    );
  }

  void _deleteMachine() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Machine'),
        content: Text('Are you sure you want to delete ${_machine!.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              await context.read<MachineProvider>().deleteMachine(widget.machineId);
              if (mounted) {
                navigator.pop(); // Close dialog
                navigator.pop(); // Return to home
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Machine deleted'),
                    backgroundColor: AppTheme.statusOptimal,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.statusOverdue),
            ),
          ),
        ],
      ),
    );
  }
}

// Update Odometer Dialog
class _UpdateOdometerDialog extends StatefulWidget {
  final Machine machine;

  const _UpdateOdometerDialog({required this.machine});

  @override
  State<_UpdateOdometerDialog> createState() => _UpdateOdometerDialogState();
}

class _UpdateOdometerDialogState extends State<_UpdateOdometerDialog> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.machine.currentOdometer.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Odometer'),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Current ${widget.machine.odometerUnit}',
          suffixText: widget.machine.odometerUnit,
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final value = double.tryParse(_controller.text);
    if (value == null || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number'),
          backgroundColor: AppTheme.statusOverdue,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedMachine = widget.machine.copyWith(
        currentOdometer: value,
        updatedAt: DateTime.now(),
      );
      await context.read<MachineProvider>().updateMachine(updatedMachine);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Odometer updated'),
            backgroundColor: AppTheme.statusOptimal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.statusOverdue,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Add Maintenance Dialog
class _AddMaintenanceDialog extends StatefulWidget {
  final Machine machine;

  const _AddMaintenanceDialog({required this.machine});

  @override
  State<_AddMaintenanceDialog> createState() => _AddMaintenanceDialogState();
}

class _AddMaintenanceDialogState extends State<_AddMaintenanceDialog> {
  String _selectedType = maintenanceTypeOilChange;
  late TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Maintenance'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Maintenance Type'),
              items: maintenanceTypeNames.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Add any notes about this service',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);

    try {
      final record = MaintenanceRecord(
        machineId: widget.machine.id!,
        maintenanceType: _selectedType,
        date: DateTime.now(),
        odometerAtService: widget.machine.currentOdometer,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      
      await context.read<MachineProvider>().addMaintenanceRecord(record);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maintenance record added'),
            backgroundColor: AppTheme.statusOptimal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.statusOverdue,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
