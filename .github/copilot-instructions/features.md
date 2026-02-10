# Features and Functionality

**Date**: 9 de fevereiro de 2026

## Core Features

### 1. Machine Management ("Garage")

#### Add Machine/Vehicle
Users can add machines to their personal garage with the following information:

**Required Fields:**
- Type (Vehicle/Machine)
- Brand/Model

**Optional Fields:**
- Machine picture
- Nickname
- Year
- Serial number
- Spark plug type (e.g., "NGK CR7HSA")
- Spark plug gap (e.g., "0.8", "0.7-0.9" mm)
- Oil type (e.g., "10W-40", "20W-50")
- Oil capacity (e.g., "1.2L", "4 Liters")
- Fuel type (e.g., "Gasoline", "Diesel", "Ethanol")
- Tank size (liters)
- Front tires size (e.g., "205/55 R16")
- Rear tires size (e.g., "225/50 R17")
- Front tire pressure (e.g., "32", "30-32" PSI)
- Rear tire pressure (e.g., "36", "34-36" PSI)
- Battery voltage (e.g., "12", "12.6" V)
- Battery capacity (e.g., "50", "100" Ah)
- Maintenance interval type:
  - For **vehicles**: km run OR time interval
  - For **machines**: hours run OR time interval
- Current odometer:
  - For **vehicles**: km
  - For **machines**: hours

### 2. Overview Dashboard (Initial Page)
- Display all machines in the garage
- Show key status indicators for each machine
- Visual overview of maintenance status

### 3. Machine Detail View
When clicking on a machine, users can:

#### View Information
- Detailed machine specifications
- Current odometer/hours
- Maintenance history
- Status indicators for various maintenance items

#### Update Odometer
- Update current km (vehicles)
- Update current hours (machines)

#### Add Maintenance Records
Record maintenance activities with:
- Date performed (DD/MM/YYYY format)
- Type of maintenance (oil change, filter cleaning, etc.)
- Any relevant notes

#### Maintenance Alerts/Reminders
Based on last maintenance and intervals, show alerts for:
- Oil change
- Filter cleaning
- Chain oiling (motorcycles)
- Brake fluid change
- Coolant change
- Spark plug change
- Brake inspection
- General service
- Fuel
- Front tires
- Rear tires
- Belts/Chains
- Battery

### 4. Maintenance Tracking System
- Calculate when maintenance is due based on:
  - Time elapsed since last service
  - Distance/hours since last service
  - Configured maintenance intervals
- Visual indicators showing:
  - Optimal status (green)
  - Check soon (yellow/warning)
  - Overdue (red)

### 5. Maintenance History

#### Full History View
- Comprehensive list of all maintenance records for a machine
- Accessible via "View All" button in machine detail screen
- Chronologically ordered (newest first)

#### Record Details
- Maintenance type with appropriate icon
- Date performed (formatted: "MMM d, y")
- Time ago relative format (e.g., "2 days ago", "3 weeks ago")
- Odometer reading at time of service
- Fuel amount (for fuel maintenance types)
- Service notes (displayed when provided)

#### Delete Records
- Delete button on each record
- Confirmation dialog to prevent accidental deletion
- Automatic recalculation of maintenance statuses after deletion
- Automatic rescheduling of notifications after deletion
- Success/error feedback to user
- Immediate UI refresh after deletion

### 6. Database Backup and Restore

#### Export Database
- Manual database backup functionality
- Exports to user-accessible Downloads folder
- Timestamped backup files for easy identification
- Format: `machine_maintenance_backup_YYYY-MM-DDTHH-MM-SS.db`

#### Import Database
- Restore from previously exported backup
- Confirmation dialog to prevent accidental data loss
- Validates file before import
- Automatic backup of current data before import
- Supports device migration and data recovery

### 7. About Screen

#### Information Display
- App version and description
- Developer credits and website link
- Feature list
- Copyright information

#### GitHub Repository Link
- Direct link to source code repository
- Opens in external browser
- Clean, professional styling

#### Data Management
- Export and Import buttons
- Loading indicators during operations
- Success/error feedback messages