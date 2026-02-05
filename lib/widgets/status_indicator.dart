import 'package:flutter/material.dart';
import '../models/maintenance_status.dart';
import '../utils/app_theme.dart';
import 'dart:math' as math;

class StatusIndicator extends StatelessWidget {
  final String label;
  final MaintenanceStatusType status;
  final IconData icon;
  final double size;

  const StatusIndicator({
    super.key,
    required this.label,
    required this.status,
    required this.icon,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final progress = _getProgress();

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.cardBackground.withOpacity(0.3),
                  ),
                ),
              ),
              // Progress circle
              SizedBox(
                width: size,
                height: size,
                child: Transform.rotate(
                  angle: -math.pi / 2,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
              // Icon
              Container(
                width: size * 0.5,
                height: size * 0.5,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: size * 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          _getStatusText(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case MaintenanceStatusType.optimal:
        return AppTheme.statusOptimal;
      case MaintenanceStatusType.checkSoon:
        return AppTheme.statusWarning;
      case MaintenanceStatusType.overdue:
        return AppTheme.statusOverdue;
    }
  }

  double _getProgress() {
    switch (status) {
      case MaintenanceStatusType.optimal:
        return 1.0;
      case MaintenanceStatusType.checkSoon:
        return 0.5;
      case MaintenanceStatusType.overdue:
        return 0.2;
    }
  }

  String _getStatusText() {
    switch (status) {
      case MaintenanceStatusType.optimal:
        return 'Optimal';
      case MaintenanceStatusType.checkSoon:
        return 'Check Soon';
      case MaintenanceStatusType.overdue:
        return 'Overdue';
    }
  }
}
