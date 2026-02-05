import 'package:flutter/material.dart';

class MachineDetailScreen extends StatelessWidget {
  final int machineId;

  const MachineDetailScreen({
    Key? key,
    required this.machineId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machine Details'),
      ),
      body: const Center(
        child: Text('Machine Detail View - Coming Soon'),
      ),
    );
  }
}
