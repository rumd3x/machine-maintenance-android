import 'package:flutter/material.dart';

class AddMachineScreen extends StatefulWidget {
  const AddMachineScreen({Key? key}) : super(key: key);

  @override
  State<AddMachineScreen> createState() => _AddMachineScreenState();
}

class _AddMachineScreenState extends State<AddMachineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Machine'),
      ),
      body: const Center(
        child: Text('Add Machine Form - Coming Soon'),
      ),
    );
  }
}
