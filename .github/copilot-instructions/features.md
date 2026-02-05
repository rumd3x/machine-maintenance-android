# Features and Functionality

**Date**: 4 de fevereiro de 2026

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
- Serial number
- Spark plug type
- Oil type
- Maintenance interval type:
  - For **vehicles**: km run OR time interval
  - For **machines**: hours run OR time interval
- Current odometer:
  - For **vehicles**: km
  - For **machines**: hours
- Tank size

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
- Cooling fluid change
- Other scheduled maintenance items

### 4. Maintenance Tracking System
- Calculate when maintenance is due based on:
  - Time elapsed since last service
  - Distance/hours since last service
  - Configured maintenance intervals
- Visual indicators showing:
  - Optimal status (green)
  - Check soon (yellow/warning)
  - Overdue (red)
