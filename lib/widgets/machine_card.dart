import 'package:flutter/material.dart';
import 'dart:io';
import '../models/machine.dart';
import '../models/maintenance_status.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class MachineCard extends StatelessWidget {
  final Machine machine;
  final VoidCallback onTap;
  final MaintenanceStatusType? overallStatus;

  const MachineCard({
    Key? key,
    required this.machine,
    required this.onTap,
    this.overallStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Machine Image/Icon on the left
              _buildImageOrIcon(),
              const SizedBox(width: 12),
              
              // Machine Info in the center
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getDisplayTitle(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.textSecondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            machineTypeNames[machine.type] ?? machine.type,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${machine.currentOdometer.toStringAsFixed(0)} ${machine.odometerUnit}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Status indicator on the right
              if (overallStatus != null) _buildStatusIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisplayTitle() {
    if (machine.nickname != null && machine.nickname!.isNotEmpty) {
      return machine.nickname!;
    }
    
    final parts = <String>[];
    if (machine.year != null && machine.year!.isNotEmpty) {
      parts.add(machine.year!);
    }
    parts.add(machine.brand);
    parts.add(machine.model);
    
    return parts.join(' ');
  }

  Widget _buildImageOrIcon() {
    if (machine.imagePath != null && File(machine.imagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(machine.imagePath!),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.textSecondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          _getMachineTypeIcon(),
          size: 32,
          color: AppTheme.textSecondary,
        ),
      );
    }
  }

  IconData _getMachineTypeIcon() {
    switch (machine.type) {
      case machineTypeVehicle:
        return Icons.directions_car;
      case machineTypeMotorcycle:
        return Icons.motorcycle;
      case machineTypeGenerator:
        return Icons.power;
      case machineTypeMachine:
        return Icons.precision_manufacturing;
      default:
        return Icons.build;
    }
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    IconData icon;
    
    switch (overallStatus!) {
      case MaintenanceStatusType.optimal:
        statusColor = AppTheme.statusOptimal;
        icon = Icons.check;
        break;
      case MaintenanceStatusType.checkSoon:
      case MaintenanceStatusType.overdue:
        statusColor = AppTheme.statusWarning;
        icon = Icons.priority_high;
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: statusColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
