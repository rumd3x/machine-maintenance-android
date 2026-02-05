import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/machine.dart';
import '../services/machine_provider.dart';
import '../utils/app_theme.dart';

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
  late final TextEditingController _sparkPlugTypeController;
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
    _sparkPlugTypeController = TextEditingController(text: widget.machine.sparkPlugType ?? '');
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
    _sparkPlugTypeController.dispose();
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
        oilType: _oilTypeController.text.trim().isEmpty
            ? null
            : _oilTypeController.text.trim(),
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
                hintText: 'e.g., Honda, Toyota, Yamaha',
                prefixIcon: Icon(Icons.business),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a brand';
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
                hintText: 'e.g., Civic EX, F-150',
                prefixIcon: Icon(Icons.category),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a model';
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
                hintText: 'e.g., My Daily Driver',
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
                hintText: 'e.g., 2020',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),

            // Serial Number
            TextFormField(
              controller: _serialNumberController,
              decoration: const InputDecoration(
                labelText: 'Serial Number / VIN',
                hintText: 'e.g., 1HGBH41JXMN109186',
                prefixIcon: Icon(Icons.qr_code),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Oil Type
            TextFormField(
              controller: _oilTypeController,
              decoration: const InputDecoration(
                labelText: 'Oil Type',
                hintText: 'e.g., 5W-30, 10W-40',
                prefixIcon: Icon(Icons.water_drop),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Spark Plug Type
            TextFormField(
              controller: _sparkPlugTypeController,
              decoration: const InputDecoration(
                labelText: 'Spark Plug Type',
                hintText: 'e.g., NGK BKR6E',
                prefixIcon: Icon(Icons.electric_bolt),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Tank Size
            TextFormField(
              controller: _tankSizeController,
              decoration: const InputDecoration(
                labelText: 'Tank Size',
                hintText: 'e.g., 50',
                prefixIcon: Icon(Icons.local_gas_station),
                suffixText: 'L',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final tank = double.tryParse(value);
                  if (tank == null || tank <= 0) {
                    return 'Please enter a valid tank size';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Odometer Unit Selector
            _buildOdometerUnitSelector(),
            const SizedBox(height: 16),

            // Current Odometer (required)
            TextFormField(
              controller: _odometerController,
              decoration: InputDecoration(
                labelText: 'Current Odometer *',
                hintText: 'e.g., 50000',
                prefixIcon: const Icon(Icons.speed),
                suffixText: _selectedOdometerUnit,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter current odometer';
                }
                final odometer = double.tryParse(value);
                if (odometer == null || odometer < 0) {
                  return 'Please enter a valid odometer reading';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Info text
            const Text(
              '* Required fields',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
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
    final types = ['vehicle', 'machine'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((type) {
            final isSelected = _selectedType == type;
            return ChoiceChip(
              label: Text(type.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = type;
                  // Auto-switch odometer unit based on type
                  if (type == 'vehicle') {
                    _selectedOdometerUnit = 'km';
                  } else {
                    _selectedOdometerUnit = 'hours';
                  }
                });
              },
              selectedColor: AppTheme.textAccent,
              backgroundColor: AppTheme.cardBackground,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.textAccent
                    : AppTheme.textSecondary.withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOdometerUnitSelector() {
    final units = ['km', 'hours'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Odometer Unit *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: units.map((unit) {
            final isSelected = _selectedOdometerUnit == unit;
            return ChoiceChip(
              label: Text(unit.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedOdometerUnit = unit;
                });
              },
              selectedColor: AppTheme.textAccent,
              backgroundColor: AppTheme.cardBackground,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.textAccent
                    : AppTheme.textSecondary.withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
