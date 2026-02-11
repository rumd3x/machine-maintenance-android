import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/machine.dart';
import '../models/maintenance_status.dart';
import '../services/machine_provider.dart';
import '../services/maintenance_calculator.dart';
import '../services/notification_provider.dart';
import '../widgets/machine_card.dart';
import '../utils/app_theme.dart';
import 'add_machine_screen.dart';
import 'machine_detail_screen.dart';
import 'about_screen.dart';
import 'notification_history_screen.dart';

enum SortOption {
  status,
  name,
  dateAdded,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _calculator = MaintenanceCalculator();
  SortOption _currentSort = SortOption.dateAdded;

  @override
  void initState() {
    super.initState();
    // Load machines when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<MachineProvider>().loadMachines();
      await context.read<NotificationProvider>().loadNotifications();
      
      // Schedule/check notifications for all machines
      if (mounted) {
        await context.read<MachineProvider>().rescheduleAllNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'WELCOME BACK',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'MY GARAGE',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: _showSortOptions,
                  ),
                  Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, child) {
                      final hasUnread = notificationProvider.unreadCount > 0;
                      
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationHistoryScreen(),
                                ),
                              );
                            },
                          ),
                          if (hasUnread)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Machine List
            Expanded(
              child: Consumer<MachineProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (provider.machines.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.garage,
                            size: 80,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Machines Yet',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first vehicle or machine',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return FutureBuilder<List<_MachineWithStatus>>(
                    future: _getSortedMachines(provider),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final sortedMachines = snapshot.data!;

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: sortedMachines.length,
                        itemBuilder: (context, index) {
                          final machineWithStatus = sortedMachines[index];
                          final machine = machineWithStatus.machine;
                          
                          return MachineCard(
                            machine: machine,
                            overallStatus: machineWithStatus.status,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MachineDetailScreen(
                                    machineId: machine.id!,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMachineScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Machine'),
      ),
    );
  }

  Future<MaintenanceStatusType> _calculateOverallStatus(
    MachineProvider provider,
    Machine machine,
  ) async {
    try {
      final intervals = await provider.getMaintenanceIntervals(machine.id!);
      final records = await provider.getMaintenanceRecords(machine.id!);
      
      final statuses = await _calculator.calculateAllStatuses(
        machine: machine,
        intervals: intervals,
        records: records,
      );
      
      return _calculator.getOverallStatus(statuses);
    } catch (e) {
      return MaintenanceStatusType.optimal;
    }
  }

  Future<List<_MachineWithStatus>> _getSortedMachines(MachineProvider provider) async {
    // Calculate status for all machines
    final machinesWithStatus = <_MachineWithStatus>[];
    
    for (final machine in provider.machines) {
      final status = await _calculateOverallStatus(provider, machine);
      machinesWithStatus.add(_MachineWithStatus(machine, status));
    }

    // Sort based on current sort option
    switch (_currentSort) {
      case SortOption.status:
        machinesWithStatus.sort((a, b) {
          // Order: overdue > checkSoon > optimal
          final aValue = a.status == MaintenanceStatusType.overdue ? 0 : 
                         a.status == MaintenanceStatusType.checkSoon ? 1 : 2;
          final bValue = b.status == MaintenanceStatusType.overdue ? 0 :
                         b.status == MaintenanceStatusType.checkSoon ? 1 : 2;
          return aValue.compareTo(bValue);
        });
        break;
      case SortOption.name:
        machinesWithStatus.sort((a, b) {
          final aName = _getDisplayName(a.machine);
          final bName = _getDisplayName(b.machine);
          return aName.toLowerCase().compareTo(bName.toLowerCase());
        });
        break;
      case SortOption.dateAdded:
        machinesWithStatus.sort((a, b) {
          return b.machine.createdAt.compareTo(a.machine.createdAt); // Newest first
        });
        break;
    }

    return machinesWithStatus;
  }

  String _getDisplayName(Machine machine) {
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Sort By',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.warning_amber),
                title: const Text('Status'),
                trailing: _currentSort == SortOption.status
                    ? Icon(Icons.check, color: AppTheme.accentBlue)
                    : null,
                onTap: () {
                  setState(() {
                    _currentSort = SortOption.status;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Name'),
                trailing: _currentSort == SortOption.name
                    ? Icon(Icons.check, color: AppTheme.accentBlue)
                    : null,
                onTap: () {
                  setState(() {
                    _currentSort = SortOption.name;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date Added'),
                trailing: _currentSort == SortOption.dateAdded
                    ? Icon(Icons.check, color: AppTheme.accentBlue)
                    : null,
                onTap: () {
                  setState(() {
                    _currentSort = SortOption.dateAdded;
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _MachineWithStatus {
  final Machine machine;
  final MaintenanceStatusType status;

  _MachineWithStatus(this.machine, this.status);
}
