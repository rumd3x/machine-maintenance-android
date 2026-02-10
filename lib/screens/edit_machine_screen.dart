import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/machine.dart';
import '../services/machine_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class EditMachineScreen extends StatefulWidget {
  final Machine machine;

  const EditMachineScreen({
    super.key,
    required this.machine,
  });

  @override
  State<EditMachineScreen> createState() => _EditMachineScreenState();
}

class _EditMachineScreenState extends State<EditMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _serialNumberController;
  late final TextEditingController _oilTypeController;
  late final TextEditingController _oilCapacityController;
  late final TextEditingController _sparkPlugTypeController;
  late final TextEditingController _sparkPlugGapController;
  late final TextEditingController _fuelTypeController;
  late final TextEditingController _frontTiresSizeController;
  late final TextEditingController _rearTiresSizeController;
  late final TextEditingController _frontTirePressureController;
  late final TextEditingController _rearTirePressureController;
  late final TextEditingController _batteryVoltageController;
  late final TextEditingController _batteryCapacityController;
  late final TextEditingController _batteryTypeController;
  late final TextEditingController _tankSizeController;
  late final TextEditingController _odometerController;

  late String _selectedType;
  late String _selectedOdometerUnit;
  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current machine data
    _nicknameController = TextEditingController(text: widget.machine.nickname ?? '');
    _brandController = TextEditingController(text: widget.machine.brand);
    _modelController = TextEditingController(text: widget.machine.model);
    _yearController = TextEditingController(text: widget.machine.year ?? '');
    _serialNumberController = TextEditingController(text: widget.machine.serialNumber ?? '');
    _oilTypeController = TextEditingController(text: widget.machine.oilType ?? '');
    _oilCapacityController = TextEditingController(text: widget.machine.oilCapacity ?? '');
    _sparkPlugTypeController = TextEditingController(text: widget.machine.sparkPlugType ?? '');
    _sparkPlugGapController = TextEditingController(text: widget.machine.sparkPlugGap ?? '');
    _fuelTypeController = TextEditingController(text: widget.machine.fuelType ?? '');
    _frontTiresSizeController = TextEditingController(text: widget.machine.frontTiresSize ?? '');
    _rearTiresSizeController = TextEditingController(text: widget.machine.rearTiresSize ?? '');
    _frontTirePressureController = TextEditingController(text: widget.machine.frontTirePressure ?? '');
    _rearTirePressureController = TextEditingController(text: widget.machine.rearTirePressure ?? '');
    _batteryVoltageController = TextEditingController(text: widget.machine.batteryVoltage ?? '');
    _batteryCapacityController = TextEditingController(text: widget.machine.batteryCapacity ?? '');
    _batteryTypeController = TextEditingController(text: widget.machine.batteryType ?? '');
    _tankSizeController = TextEditingController(
      text: widget.machine.tankSize?.toStringAsFixed(1) ?? '',
    );
    _odometerController = TextEditingController(
      text: widget.machine.currentOdometer.toStringAsFixed(1),
    );
    _selectedType = widget.machine.type;
    _selectedOdometerUnit = widget.machine.odometerUnit;
    _imagePath = widget.machine.imagePath;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _serialNumberController.dispose();
    _oilTypeController.dispose();
    _oilCapacityController.dispose();
    _sparkPlugTypeController.dispose();
    _sparkPlugGapController.dispose();
    _fuelTypeController.dispose();
    _frontTiresSizeController.dispose();
    _rearTiresSizeController.dispose();
    _frontTirePressureController.dispose();
    _rearTirePressureController.dispose();
    _batteryVoltageController.dispose();
    _batteryCapacityController.dispose();
    _batteryTypeController.dispose();
    _tankSizeController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final navigator = Navigator.of(context);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
      navigator.pop(); // Close bottom sheet
    } catch (e) {
      navigator.pop(); // Close bottom sheet
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera, color: AppTheme.textAccent),
              title: const Text('Take Photo'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.textAccent),
              title: const Text('Choose from Gallery'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.statusOverdue),
                title: const Text('Remove Photo'),
                onTap: () {
                  setState(() {
                    _imagePath = null;
                  });
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.close, color: AppTheme.textSecondary),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<MachineProvider>();
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      final updatedMachine = widget.machine.copyWith(
        type: _selectedType,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        nickname: _nicknameController.text.trim().isEmpty
            ? null
            : _nicknameController.text.trim(),
        year: _yearController.text.trim().isEmpty
            ? null
            : _yearController.text.trim(),
        serialNumber: _serialNumberController.text.trim().isEmpty
            ? null
            : _serialNumberController.text.trim(),
        sparkPlugType: _sparkPlugTypeController.text.trim().isEmpty
            ? null
            : _sparkPlugTypeController.text.trim(),
        sparkPlugGap: _sparkPlugGapController.text.trim().isEmpty
            ? null
            : _sparkPlugGapController.text.trim(),
        oilType: _oilTypeController.text.trim().isEmpty
            ? null
            : _oilTypeController.text.trim(),
        oilCapacity: _oilCapacityController.text.trim().isEmpty
            ? null
            : _oilCapacityController.text.trim(),
        fuelType: _fuelTypeController.text.trim().isEmpty
            ? null
            : _fuelTypeController.text.trim(),
        frontTiresSize: _frontTiresSizeController.text.trim().isEmpty
            ? null
            : _frontTiresSizeController.text.trim(),
        rearTiresSize: _rearTiresSizeController.text.trim().isEmpty
            ? null
            : _rearTiresSizeController.text.trim(),
        frontTirePressure: _frontTirePressureController.text.trim().isEmpty
            ? null
            : _frontTirePressureController.text.trim(),
        rearTirePressure: _rearTirePressureController.text.trim().isEmpty
            ? null
            : _rearTirePressureController.text.trim(),
        batteryVoltage: _batteryVoltageController.text.trim().isEmpty
            ? null
            : _batteryVoltageController.text.trim(),
        batteryCapacity: _batteryCapacityController.text.trim().isEmpty
            ? null
            : _batteryCapacityController.text.trim(),
        tankSize: _tankSizeController.text.trim().isEmpty
            ? null
            : double.tryParse(_tankSizeController.text.trim()),
        imagePath: _imagePath,
        currentOdometer: double.parse(_odometerController.text.trim()),
        odometerUnit: _selectedOdometerUnit,
        updatedAt: DateTime.now(),
      );

      await provider.updateMachine(updatedMachine);

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Machine updated successfully!'),
          backgroundColor: AppTheme.statusOptimal,
        ),
      );

      navigator.pop(true); // Return true to indicate changes were saved
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update machine: $e'),
          backgroundColor: AppTheme.statusOverdue,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Edit Machine'),
        backgroundColor: AppTheme.cardBackground,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textAccent),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveChanges,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Section
            _buildImageSection(),
            const SizedBox(height: 24),

            // Machine Type
            _buildTypeSelector(),
            const SizedBox(height: 24),

            // Brand (required)
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand *',
                hintText: 'e.g., Suzuki, Honda, Yamaha',
                prefixIcon: Icon(Icons.business),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Brand is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Model (required)
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model *',
                hintText: 'e.g., Intruder 125, CG 160',
                prefixIcon: Icon(Icons.motorcycle),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Model is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nickname (optional)
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nickname',
                hintText: 'e.g., My Bike, Work Car',
                prefixIcon: Icon(Icons.label),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Year
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                hintText: 'e.g., 2008',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
            const SizedBox(height: 16),

            // Current Odometer
            _buildOdometerInput(),
            const SizedBox(height: 16),

            // Serial Number
            TextFormField(
              controller: _serialNumberController,
              decoration: const InputDecoration(
                labelText: 'Serial Number',
                hintText: 'VIN or chassis number',
                prefixIcon: Icon(Icons.numbers),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Spark Plug (Type + Gap)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _sparkPlugTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Spark Plug Type',
                      hintText: 'e.g., NGK CR7HSA',
                      prefixIcon: Icon(Icons.electrical_services),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _sparkPlugGapController,
                    decoration: const InputDecoration(
                      labelText: 'Gap',
                      hintText: 'e.g., 0.8',
                      suffixText: 'mm',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Oil (Type + Capacity)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _oilTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Oil Type',
                      hintText: 'e.g., 10W-40, 20W-50',
                      prefixIcon: Icon(Icons.water_drop),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _oilCapacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      hintText: 'e.g., 1.2',
                      suffixText: 'L',
                      prefixIcon: Icon(Icons.water_drop),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fuel (Type + Tank Size)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _fuelTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Fuel Type',
                      hintText: 'e.g., Gasoline, Diesel',
                      prefixIcon: Icon(Icons.local_gas_station),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _tankSizeController,
                    decoration: const InputDecoration(
                      labelText: 'Tank Size',
                      hintText: 'e.g., 10',
                      suffixText: 'L',
                      prefixIcon: Icon(Icons.local_gas_station),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Front Tires (Size + Pressure) - Only for Vehicle/Motorcycle
            if (_selectedType == machineTypeVehicle || _selectedType == machineTypeMotorcycle) ...[            
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _frontTiresSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Front Tires Size',
                        hintText: 'e.g., 205/55 R16',
                        prefixIcon: Icon(Icons.circle_outlined),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _frontTirePressureController,
                      decoration: const InputDecoration(
                        labelText: 'Pressure',
                        hintText: 'e.g., 32',
                        suffixText: 'PSI',
                        prefixIcon: Icon(Icons.speed),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Rear Tires (Size + Pressure)
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _rearTiresSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Rear Tires Size',
                        hintText: 'e.g., 225/50 R17',
                        prefixIcon: Icon(Icons.circle_outlined),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _rearTirePressureController,
                      decoration: const InputDecoration(
                        labelText: 'Pressure',
                        hintText: 'e.g., 36',
                        suffixText: 'PSI',
                        prefixIcon: Icon(Icons.speed),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Battery (Voltage + Capacity)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _batteryVoltageController,
                    decoration: const InputDecoration(
                      labelText: 'Battery Voltage',
                      hintText: 'e.g., 12',
                      suffixText: 'V',
                      prefixIcon: Icon(Icons.battery_charging_full),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _batteryCapacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      hintText: 'e.g., 50',
                      suffixText: 'Ah',
                      prefixIcon: Icon(Icons.battery_std),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Battery Type/Model
            TextFormField(
              controller: _batteryTypeController,
              decoration: const InputDecoration(
                labelText: 'Battery Type/Model',
                hintText: 'e.g., HTZ7L',
                prefixIcon: Icon(Icons.battery_full),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 32),

            // Required fields note
            Text(
              '* Required fields',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showImagePicker,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: _imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: CircleAvatar(
                            backgroundColor: AppTheme.textAccent,
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 48,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add photo',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Machine Type *',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildTypeChip('Vehicle', machineTypeVehicle, Icons.directions_car),
            _buildTypeChip('Motorcycle', machineTypeMotorcycle, Icons.motorcycle),
            _buildTypeChip('Generator', machineTypeGenerator, Icons.power),
            _buildTypeChip('Machine', machineTypeMachine, Icons.precision_manufacturing),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, String value, IconData icon) {
    final isSelected = _selectedType == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = value;
          // Update odometer unit based on type
          if (value == machineTypeGenerator || value == machineTypeMachine) {
            _selectedOdometerUnit = odometerUnitHours;
          } else {
            _selectedOdometerUnit = odometerUnitKm;
          }
        });
      },
      selectedColor: AppTheme.accentBlue,
      checkmarkColor: AppTheme.textPrimary,
    );
  }

  Widget _buildOdometerInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _odometerController,
            decoration: InputDecoration(
              labelText: 'Current Odometer *',
              hintText: '0',
              prefixIcon: const Icon(Icons.speed),
              suffixText: _selectedOdometerUnit,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Odometer is required';
              }
              final number = double.tryParse(value);
              if (number == null || number < 0) {
                return 'Enter a valid number';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedOdometerUnit,
            decoration: const InputDecoration(
              labelText: 'Unit',
            ),
            items: const [
              DropdownMenuItem(
                value: odometerUnitKm,
                child: Text('km'),
              ),
              DropdownMenuItem(
                value: odometerUnitHours,
                child: Text('hours'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedOdometerUnit = value!;
              });
            },
          ),
        ),
      ],
    );
  }
}
