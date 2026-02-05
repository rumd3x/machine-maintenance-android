import 'package:flutter/material.dart';
import 'dart:io';
import '../models/machine.dart';
import '../models/maintenance_status.dart';
import '../utils/app_theme.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Machine Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  _buildImage(),
                  if (overallStatus != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildStatusBadge(),
                    ),
                ],
              ),
            ),
            
            // Machine Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Machine Name
                  Text(
                    machine.displayName,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  
                  // Brand and Model
                  Text(
                    '${machine.year ?? ''} ${machine.brand} ${machine.model}'.trim(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Odometer and Tank Info
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'ODOMETER',
                          '${machine.currentOdometer.toStringAsFixed(0)} ${machine.odometerUnit}',
                        ),
                      ),
                      if (machine.tankSize != null)
                        Expanded(
                          child: _buildInfoItem(
                            context,
                            'FUEL CAPACITY',
                            '${machine.tankSize!.toStringAsFixed(1)} Liters',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (machine.imagePath != null && File(machine.imagePath!).existsSync()) {
      return Image.file(
        File(machine.imagePath!),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accentBlue,
              AppTheme.cardBackground,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(
          Icons.directions_car,
          size: 80,
          color: AppTheme.textSecondary,
        ),
      );
    }
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    IconData icon;
    
    switch (overallStatus!) {
      case MaintenanceStatusType.optimal:
        badgeColor = AppTheme.statusOptimal;
        icon = Icons.check_circle;
        break;
      case MaintenanceStatusType.checkSoon:
        badgeColor = AppTheme.statusWarning;
        icon = Icons.warning;
        break;
      case MaintenanceStatusType.overdue:
        badgeColor = AppTheme.statusOverdue;
        icon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
