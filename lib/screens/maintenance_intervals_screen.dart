import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/machine.dart';
import '../models/maintenance_interval.dart';
import '../services/machine_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class MaintenanceIntervalsScreen extends StatefulWidget {
  final Machine machine;

  const MaintenanceIntervalsScreen({
    super.key,
    required this.machine,
  });

  @override
  State<MaintenanceIntervalsScreen> createState() => _MaintenanceIntervalsScreenState();
}

class _MaintenanceIntervalsScreenState extends State<MaintenanceIntervalsScreen> {
  List<MaintenanceInterval> _intervals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIntervals();
  }

  Future<void> _loadIntervals() async {
    setState(() => _isLoading = true);
    
    _intervals = await context.read<MachineProvider>().getMaintenanceIntervals(
      widget.machine.id!,
    );
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Intervals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewInterval,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _intervals.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _intervals.length,
                  itemBuilder: (context, index) {
                    return _buildIntervalCard(_intervals[index]);
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
            Icons.schedule,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No maintenance intervals',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add intervals to track maintenance',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewInterval,
            icon: const Icon(Icons.add),
            label: const Text('Add Interval'),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalCard(MaintenanceInterval interval) {
    final maintenanceName = maintenanceTypeNames[interval.maintenanceType] ?? 
                           interval.maintenanceType.replaceAll('_', ' ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          SwitchListTile(
            value: interval.enabled,
            onChanged: (value) => _toggleEnabled(interval, value),
            title: Text(
              maintenanceName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: _buildIntervalSubtitle(interval),
            secondary: Icon(
              _getMaintenanceIcon(interval.maintenanceType),
              color: interval.enabled ? AppTheme.textAccent : AppTheme.textSecondary,
            ),
          ),
          if (interval.enabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editInterval(interval),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _deleteInterval(interval),
                    icon: const Icon(Icons.delete, size: 16, color: AppTheme.statusOverdue),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: AppTheme.statusOverdue),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIntervalSubtitle(MaintenanceInterval interval) {
    final parts = <String>[];
    
    if (interval.intervalDistance != null) {
      parts.add('${interval.intervalDistance!.toStringAsFixed(0)} ${widget.machine.odometerUnit}');
    }
    
    if (interval.intervalDays != null) {
      final days = interval.intervalDays!;
      if (days >= 365) {
        final years = (days / 365).round();
        parts.add('$years ${years == 1 ? 'year' : 'years'}');
      } else if (days >= 30) {
        final months = (days / 30).round();
        parts.add('$months ${months == 1 ? 'month' : 'months'}');
      } else {
        parts.add('$days ${days == 1 ? 'day' : 'days'}');
      }
    }
    
    if (!interval.enabled) {
      parts.add('(Disabled)');
    }
    
    return Text(
      parts.isEmpty ? 'No interval set' : parts.join(' or '),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: interval.enabled ? AppTheme.textSecondary : AppTheme.textSecondary.withOpacity(0.5),
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
      case maintenanceTypeFuel:
        return Icons.local_gas_station;
      default:
        return Icons.build;
    }
  }

  Future<void> _toggleEnabled(MaintenanceInterval interval, bool enabled) async {
    final updated = interval.copyWith(enabled: enabled);
    await context.read<MachineProvider>().saveMaintenanceInterval(updated);
    await _loadIntervals();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enabled ? 'Interval enabled' : 'Interval disabled'),
          backgroundColor: AppTheme.statusOptimal,
        ),
      );
    }
  }

  void _editInterval(MaintenanceInterval interval) {
    showDialog(
      context: context,
      builder: (context) => _IntervalEditDialog(
        interval: interval,
        machine: widget.machine,
      ),
    ).then((saved) {
      if (saved == true) {
        _loadIntervals();
      }
    });
  }

  void _addNewInterval() {
    showDialog(
      context: context,
      builder: (context) => _IntervalEditDialog(
        machine: widget.machine,
      ),
    ).then((saved) {
      if (saved == true) {
        _loadIntervals();
      }
    });
  }

  Future<void> _deleteInterval(MaintenanceInterval interval) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Interval'),
        content: Text(
          'Are you sure you want to delete this maintenance interval?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.statusOverdue),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<MachineProvider>().saveMaintenanceInterval(
        interval.copyWith(enabled: false),
      );
      await _loadIntervals();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interval deleted'),
            backgroundColor: AppTheme.statusOptimal,
          ),
        );
      }
    }
  }
}

// Dialog for editing/creating intervals
class _IntervalEditDialog extends StatefulWidget {
  final MaintenanceInterval? interval;
  final Machine machine;

  const _IntervalEditDialog({
    this.interval,
    required this.machine,
  });

  @override
  State<_IntervalEditDialog> createState() => _IntervalEditDialogState();
}

class _IntervalEditDialogState extends State<_IntervalEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedType;
  late TextEditingController _distanceController;
  late TextEditingController _daysController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.interval?.maintenanceType ?? maintenanceTypeOilChange;
    _distanceController = TextEditingController(
      text: widget.interval?.intervalDistance?.toStringAsFixed(0) ?? '',
    );
    _daysController = TextEditingController(
      text: widget.interval?.intervalDays?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.interval == null ? 'Add Interval' : 'Edit Interval'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Maintenance Type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Maintenance Type',
                ),
                items: maintenanceTypeNames.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: widget.interval == null
                    ? (value) => setState(() => _selectedType = value!)
                    : null, // Can't change type when editing
              ),
              const SizedBox(height: 16),
              
              // Distance Interval
              TextFormField(
                controller: _distanceController,
                decoration: InputDecoration(
                  labelText: 'Distance Interval (optional)',
                  hintText: 'e.g., 5000',
                  suffixText: widget.machine.odometerUnit,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = double.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Enter a valid positive number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Time Interval
              TextFormField(
                controller: _daysController,
                decoration: const InputDecoration(
                  labelText: 'Time Interval in Days (optional)',
                  hintText: 'e.g., 180 (6 months)',
                  helperText: '30=month, 90=3mo, 180=6mo, 365=year',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Enter a valid positive number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              
              Text(
                'At least one interval (distance or time) is recommended',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final distance = _distanceController.text.isNotEmpty
        ? double.tryParse(_distanceController.text)
        : null;
    
    final days = _daysController.text.isNotEmpty
        ? int.tryParse(_daysController.text)
        : null;

    if (distance == null && days == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set at least one interval (distance or time)'),
          backgroundColor: AppTheme.statusWarning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final interval = MaintenanceInterval(
        id: widget.interval?.id,
        machineId: widget.machine.id!,
        maintenanceType: _selectedType,
        intervalDistance: distance,
        intervalDays: days,
        enabled: widget.interval?.enabled ?? true,
      );

      await context.read<MachineProvider>().saveMaintenanceInterval(interval);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interval saved'),
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
