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
  
  // Form fields
  String? _imagePath;
  String _type = machineTypeVehicle;
  String _brand = '';
  String _model = '';
  String? _nickname;
  String? _year;
  String? _serialNumber;
  String? _sparkPlugType;
  String? _oilType;
  double _currentOdometer = 0;
  String _odometerUnit = odometerUnitKm;
  double? _tankSize;
  
  bool _isLoading = false;

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
              decoration: const InputDecoration(
                labelText: 'Brand *',
                hintText: 'e.g., Suzuki, Honda, Yamaha',
                prefixIcon: Icon(Icons.business),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Brand is required';
                }
                return null;
              },
              onSaved: (value) => _brand = value!,
            ),
            const SizedBox(height: 16),
            
            // Model (Required)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Model *',
                hintText: 'e.g., Intruder 125, CG 160',
                prefixIcon: Icon(Icons.motorcycle),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Model is required';
                }
                return null;
              },
              onSaved: (value) => _model = value!,
            ),
            const SizedBox(height: 16),
            
            // Nickname (Optional)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nickname',
                hintText: 'e.g., My Bike, Work Car',
                prefixIcon: Icon(Icons.label),
              ),
              textCapitalization: TextCapitalization.words,
              onSaved: (value) => _nickname = value?.isNotEmpty == true ? value : null,
            ),
            const SizedBox(height: 16),
            
            // Year (Optional)
            TextFormField(
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
              onSaved: (value) => _year = value?.isNotEmpty == true ? value : null,
            ),
            const SizedBox(height: 16),
            
            // Serial Number (Optional)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Serial Number',
                hintText: 'VIN or chassis number',
                prefixIcon: Icon(Icons.numbers),
              ),
              textCapitalization: TextCapitalization.characters,
              onSaved: (value) => _serialNumber = value?.isNotEmpty == true ? value : null,
            ),
            const SizedBox(height: 16),
            
            // Spark Plug Type (Optional)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Spark Plug Type',
                hintText: 'e.g., NGK CR7HSA',
                prefixIcon: Icon(Icons.electrical_services),
              ),
              textCapitalization: TextCapitalization.characters,
              onSaved: (value) => _sparkPlugType = value?.isNotEmpty == true ? value : null,
            ),
            const SizedBox(height: 16),
            
            // Oil Type (Optional)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Oil Type',
                hintText: 'e.g., 10W-40, 20W-50',
                prefixIcon: Icon(Icons.water_drop),
              ),
              textCapitalization: TextCapitalization.characters,
              onSaved: (value) => _oilType = value?.isNotEmpty == true ? value : null,
            ),
            const SizedBox(height: 16),
            
            // Current Odometer
            _buildOdometerInput(),
            const SizedBox(height: 16),
            
            // Tank Size (Optional)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Tank Size (Liters)',
                hintText: 'e.g., 10.0',
                prefixIcon: Icon(Icons.local_gas_station),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onSaved: (value) {
                if (value != null && value.isNotEmpty) {
                  _tankSize = double.tryParse(value);
                }
              },
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
            initialValue: '0',
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
            onSaved: (value) => _currentOdometer = double.parse(value!),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _odometerUnit,
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

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final machine = Machine(
        type: _type,
        brand: _brand,
        model: _model,
        nickname: _nickname,
        year: _year,
        serialNumber: _serialNumber,
        sparkPlugType: _sparkPlugType,
        oilType: _oilType,
        currentOdometer: _currentOdometer,
        odometerUnit: _odometerUnit,
        tankSize: _tankSize,
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
