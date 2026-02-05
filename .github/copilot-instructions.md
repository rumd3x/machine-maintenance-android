# GitHub Copilot Instructions

## Project-Specific Guidelines

### Form Screen Consistency

**CRITICAL**: The Add Machine and Edit Machine screens must maintain identical field structures.

When modifying either `add_machine_screen.dart` or `edit_machine_screen.dart`, **ALWAYS** update both files to ensure they remain synchronized.

#### Required Field Consistency Checklist:

1. **Machine Type Selector**
   - Must have 4 types: Vehicle, Motorcycle, Generator, Machine
   - Each type must have an icon: `directions_car`, `motorcycle`, `power`, `precision_manufacturing`
   - Use `FilterChip` with icons (not `ChoiceChip` without icons)
   - Auto-switch odometer unit: Generator/Machine → hours, Vehicle/Motorcycle → km

2. **Field Order** (must be identical):
   1. Image Picker
   2. Machine Type
   3. Brand (required)
   4. Model (required)
   5. Nickname (optional)
   6. Year (optional)
   7. Serial Number (optional)
   8. Spark Plug Type (optional)
   9. Oil Type (optional)
   10. Fuel Type (optional)
   11. Current Odometer (required)
   12. Tank Size (optional)

3. **Field Properties** (must match exactly):
   - **Icons**: 
     - Brand: `Icons.business`
     - Model: `Icons.motorcycle`
     - Nickname: `Icons.label`
     - Year: `Icons.calendar_today`
     - Serial Number: `Icons.numbers`
     - Spark Plug: `Icons.electrical_services`
     - Oil Type: `Icons.water_drop`
     - Fuel Type: `Icons.local_gas_station`
     - Odometer: `Icons.speed`
     - Tank Size: `Icons.local_gas_station`
   
   - **Hints**:
     - Brand: `'e.g., Suzuki, Honda, Yamaha'`
     - Model: `'e.g., Intruder 125, CG 160'`
     - Nickname: `'e.g., My Bike, Work Car'`
     - Year: `'e.g., 2008'`
     - Serial Number: `'VIN or chassis number'`
     - Spark Plug: `'e.g., NGK CR7HSA'`
     - Oil Type: `'e.g., 10W-40, 20W-50'`
     - Fuel Type: `'e.g., Gasoline, Diesel, Ethanol'`
     - Odometer: `'0'`
     - Tank Size: `'e.g., 10.0'`
   
   - **Validators**: Use identical error messages
     - Brand: `'Brand is required'`
     - Model: `'Model is required'`
     - Odometer: `'Odometer is required'` and `'Enter a valid number'`

4. **Input Formatters** (must be identical):
   - Year: digits only, max 4 characters
   - Odometer: decimal with max 2 decimal places
   - Tank Size: decimal with max 2 decimal places

5. **Odometer Input Structure**:
   - Must use `Row` with TextField (flex: 2) + DropdownButton (flex: 1)
   - Dropdown options: `odometerUnitKm` and `odometerUnitHours`
   - Combined in single `_buildOdometerInput()` method

6. **Text Capitalization**:
   - Brand, Model, Nickname, Fuel Type: `TextCapitalization.words`
   - Serial Number, Spark Plug, Oil Type: `TextCapitalization.characters`

### When Making Changes:

1. **Before editing**: Read both files completely
2. **After editing**: Verify both files match the checklist above
3. **Test**: Ensure both screens render identically
4. **Document**: Note any intentional differences with clear justification

### Constants Usage:

Always import and use constants from `lib/utils/constants.dart`:
- `machineTypeVehicle`, `machineTypeMotorcycle`, `machineTypeGenerator`, `machineTypeMachine`
- `odometerUnitKm`, `odometerUnitHours`

### Import Order:

Both screens should have the same import structure:
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/machine.dart';
import '../services/machine_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
```
