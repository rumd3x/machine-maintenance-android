# UI/UX Design Reference

**Date**: 5 de fevereiro de 2026

## Design Inspiration

Reference screenshot provided showing a dark-themed motorcycle maintenance app.

## Design Elements Observed

### Color Scheme
- Dark background (dark blue/black)
- High contrast text (white)
- Status colors:
  - Green for optimal/good status
  - Yellow/orange for warnings
  - Red for critical/overdue

### Header Section
- Welcome message with user name
- Profile picture (circular avatar)
- Notification bell icon

### Machine Card Display
- Large hero image of the machine
- Machine name/nickname prominently displayed
- Machine model/year subtitle
- Connection status indicator
- Key metrics displayed:
  - Odometer reading
  - Fuel capacity
- Next maintenance info card with info icon

### Status Indicators (Circular Progress)
Three circular status indicators with icons:
1. **SYSTEMS** - Optimal (green checkmark)
2. **BRAKES** - Check Soon (yellow warning triangle)
3. **OIL LIFE** - Overdue (red oil drop)

### Recent Activity Section
- List of recent maintenance activities
- Timestamps (e.g., "2 hours ago")
- Icons for activity type
- "View All" link

### Navigation
- Bottom navigation bar with three icons visible

## Design Principles to Follow
- Dark theme as primary
- Card-based layout
- Clear status visualization
- Easy-to-read typography
- Icon-driven interface
- Prominent imagery for each machine
## Implemented Screens

### Maintenance History Screen
**Purpose**: Display complete maintenance history with delete capability

**Layout**:
- AppBar with title "Maintenance History"
- Back button for navigation
- Full-screen list of maintenance records

**Record Cards**:
- Leading: Circular avatar with maintenance type icon (colored blue)
- Title: Maintenance type name (e.g., "Oil Change")
- Subtitle: 
  - Date with relative time (e.g., "Feb 5, 2026 • 2 hours ago")
  - Odometer value with unit (e.g., "5000 km")
  - Fuel amount if applicable (e.g., "Fuel: 10.5 L")
- Trailing: Delete icon button (red)
- Bottom section (if notes present):
  - Divider line
  - "Notes" label
  - Note text content

**Empty State**:
- Large history icon (gray)
- "No maintenance records yet" message
- "Add a maintenance record to get started" subtitle
- Centered vertically

**Interactions**:
- Tap delete button → Confirmation dialog
- Confirm deletion → Delete record, recalculate statuses, show snackbar, refresh list
- Cancel deletion → No action
- Back button → Return to machine detail screen with data refresh

**Icons Used**:
- Oil Change: `Icons.water_drop`
- Spark Plug: `Icons.electrical_services`
- Fuel: `Icons.local_gas_station`
- Filter Cleaning: `Icons.air`
- Brake Fluid: `Icons.opacity`
- Coolant: `Icons.ac_unit`
- Chain Oiling: `Icons.settings`
- Brake Inspection: `Icons.car_repair`
- General Service: `Icons.build_circle`
- Default: `Icons.build`