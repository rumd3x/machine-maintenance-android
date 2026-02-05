import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../models/machine.dart';
import '../services/machine_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class AddMachineScreen extends StatefulWidget {
  const AddMachineScreen({super.key});

  @override
  State<AddMachineScreen> createState() => _AddMachineScreenState();
}

class _AddMachineScreenState extends State<AddMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _yearController;
  late final TextEditingController _serialNumberController;
  late final TextEditingController _sparkPlugTypeController;
  late final TextEditingController _oilTypeController;
  late final TextEditingController _fuelTypeController;
  late final TextEditingController _odometerController;
  late final TextEditingController _tankSizeController;
  
  // Form fields
  String? _imagePath;
  String _type = machineTypeVehicle;
  String _odometerUnit = odometerUnitKm;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _nicknameController = TextEditingController();
    _yearController = TextEditingController();
    _serialNumberController = TextEditingController();
    _sparkPlugTypeController = TextEditingController();
    _oilTypeController = TextEditingController();
    _fuelTypeController = TextEditingController();
    _odometerController = TextEditingController(text: '0');
    _tankSizeController = TextEditingController();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _nicknameController.dispose();
    _yearController.dispose();
    _serialNumberController.dispose();
    _sparkPlugTypeController.dispose();
    _oilTypeController.dispose();
    _fuelTypeController.dispose();
    _odometerController.dispose();
    _tankSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Machine'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMachine,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'SAVE',
                    style: TextStyle(
                      color: AppTheme.textAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Picker
            _buildImagePicker(),
            const SizedBox(height: 24),
            
            // Machine Type
            _buildTypeSelector(),
            const SizedBox(height: 16),
            
            // Brand (Required)
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
            
            // Model (Required)
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
            
            // Nickname (Optional)
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
            
            // Year (Optional)
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
            
            // Serial Number (Optional)
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
            
            // Spark Plug Type (Optional)
            TextFormField(
              controller: _sparkPlugTypeController,
              decoration: const InputDecoration(
                labelText: 'Spark Plug Type',
                hintText: 'e.g., NGK CR7HSA',
                prefixIcon: Icon(Icons.electrical_services),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            
            // Oil Type (Optional)
            TextFormField(
              controller: _oilTypeController,
              decoration: const InputDecoration(
                labelText: 'Oil Type',
                hintText: 'e.g., 10W-40, 20W-50',
                prefixIcon: Icon(Icons.water_drop),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            
            // Fuel Type (Optional)
            TextFormField(
              controller: _fuelTypeController,
              decoration: const InputDecoration(
                labelText: 'Fuel Type',
                hintText: 'e.g., Gasoline, Diesel, Ethanol',
                prefixIcon: Icon(Icons.local_gas_station),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            
            // Current Odometer
            _buildOdometerInput(),
            const SizedBox(height: 16),
            
            // Tank Size (Optional)
            TextFormField(
              controller: _tankSizeController,
              decoration: const InputDecoration(
                labelText: 'Tank Size (Liters)',
                hintText: 'e.g., 10.0',
                prefixIcon: Icon(Icons.local_gas_station),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
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

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.accentBlue,
            width: 2,
          ),
        ),
        child: _imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(_imagePath!),
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add Photo',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to select from gallery or camera',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
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
    final isSelected = _type == value;
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
          _type = value;
          // Update odometer unit based on type
          if (value == machineTypeGenerator || value == machineTypeMachine) {
            _odometerUnit = odometerUnitHours;
          } else {
            _odometerUnit = odometerUnitKm;
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
              suffixText: _odometerUnit,
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
            initialValue: _odometerUnit,
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
                _odometerUnit = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.statusOverdue),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imagePath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Copy image to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final savedImage = await File(image.path).copy('${appDir.path}/$fileName');

        setState(() {
          _imagePath = savedImage.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppTheme.statusOverdue,
          ),
        );
      }
    }
  }

  Future<void> _saveMachine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final machine = Machine(
        type: _type,
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
        oilType: _oilTypeController.text.trim().isEmpty
            ? null
            : _oilTypeController.text.trim(),
        fuelType: _fuelTypeController.text.trim().isEmpty
            ? null
            : _fuelTypeController.text.trim(),
        currentOdometer: double.parse(_odometerController.text.trim()),
        odometerUnit: _odometerUnit,
        tankSize: _tankSizeController.text.trim().isEmpty
            ? null
            : double.tryParse(_tankSizeController.text.trim()),
        imagePath: _imagePath,
      );

      await context.read<MachineProvider>().addMachine(machine);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Machine added successfully!'),
            backgroundColor: AppTheme.statusOptimal,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving machine: $e'),
            backgroundColor: AppTheme.statusOverdue,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
