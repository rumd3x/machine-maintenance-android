import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/machine_provider.dart';
import '../widgets/machine_card.dart';
import '../utils/app_theme.dart';
import 'add_machine_screen.dart';
import 'machine_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load machines when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MachineProvider>().loadMachines();
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
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.cardBackground,
                    child: Icon(
                      Icons.person,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WELCOME BACK',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'My Garage',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // TODO: Implement notifications
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

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: provider.machines.length,
                    itemBuilder: (context, index) {
                      final machine = provider.machines[index];
                      return MachineCard(
                        machine: machine,
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
}
