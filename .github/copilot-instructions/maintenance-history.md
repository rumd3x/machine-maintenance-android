# Maintenance History Feature

**Date**: 5 de fevereiro de 2026

## Overview

The Maintenance History feature provides a comprehensive view of all maintenance records for a specific machine, with the ability to view detailed notes and delete incorrect records. This feature ensures users can manage their maintenance history and correct mistakes.

## Purpose

- View complete maintenance history for a machine (not just the recent 5)
- See maintenance notes that were recorded during service
- Delete wrongfully inserted maintenance records
- Automatically recalculate maintenance statuses after deletion
- Provide better visibility into maintenance patterns

## Implementation

### Files Created

**`lib/screens/maintenance_history_screen.dart`** (320 lines)
- Full-screen maintenance history viewer
- Delete functionality with confirmation
- Notes display
- Date formatting (absolute + relative)
- Empty state handling
- Icon mapping for maintenance types

### Files Modified

**`lib/services/machine_provider.dart`**
- Added `deleteMaintenanceRecord(int recordId)` method
- Fetches record before deletion to get machine ID
- Deletes record from database
- Recalculates maintenance statuses
- Reschedules notifications for affected machine
- Notifies listeners to update UI

**`lib/screens/machine_detail_screen.dart`**
- Added import for `MaintenanceHistoryScreen`
- Connected "View All" button to navigate to history screen
- Added `.then((_) => _loadData())` to refresh data after returning from history

## User Flow

1. User opens Machine Detail Screen
2. User sees "Recent Activity" section with last 5 maintenance records
3. User clicks "View All" button (only visible if records exist)
4. Navigation to Maintenance History Screen
5. User sees full list of maintenance records
6. User can:
   - View all details including notes
   - Tap delete button on any record
   - Confirm deletion in dialog
   - See success message
   - Automatically return to updated list
7. User presses back button
8. Returns to Machine Detail Screen with refreshed data

## UI Components

### Record Card Structure

```
┌─────────────────────────────────────────────┐
│ ⚫ Oil Change                          🗑️   │
│    Feb 5, 2026 • 2 hours ago               │
│    5000 km                                  │
│    Fuel: 10.5 L                            │
├─────────────────────────────────────────────┤
│ Notes                                       │
│ Used synthetic oil, filter replaced        │
└─────────────────────────────────────────────┘
```

### Empty State

```
         ⏱️
   (large icon)
   
No maintenance records yet

Add a maintenance record to get started
```

## Date Formatting

Uses two date formats:
1. **Absolute**: `MMM d, y` (e.g., "Feb 5, 2026")
2. **Relative**: Human-readable time ago
   - Just now (< 1 hour)
   - X hours ago (< 1 day)
   - X days ago (< 1 week)
   - X weeks ago (< 1 month)
   - X months ago (< 1 year)
   - X years ago (≥ 1 year)

Both formats displayed together: "Feb 5, 2026 • 2 hours ago"

## Delete Functionality

### Process Flow

1. User taps delete button (🗑️ icon)
2. Confirmation dialog appears:
   ```
   Delete Maintenance Record
   
   Are you sure you want to delete this
   [Maintenance Type] record?
   
   [Cancel]  [Delete]
   ```
3. If confirmed:
   - Call `MachineProvider.deleteMaintenanceRecord(recordId)`
   - Show success snackbar (green)
   - Reload records list
4. If cancelled:
   - No action taken

### Backend Process (MachineProvider)

```dart
Future<void> deleteMaintenanceRecord(int recordId) async {
  // 1. Fetch record to get machineId
  // 2. Delete from database
  // 3. Notify listeners (UI updates)
  // 4. Get machine object
  // 5. Get updated intervals and records
  // 6. Calculate all statuses
  // 7. Reschedule notifications
}
```

### Why Recalculation is Critical

When a maintenance record is deleted:
- Last service date may change (now an older record)
- Maintenance may become due/overdue
- Notifications need to be scheduled if status changed to overdue
- Status indicators need to update on all screens

## Icon Mapping

Maintenance types use consistent icons across the app:

| Type | Constant | Icon |
|------|----------|------|
| Oil Change | `maintenanceTypeOilChange` | `Icons.water_drop` |
| Spark Plug | `maintenanceTypeSparkPlug` | `Icons.electrical_services` |
| Fuel | `maintenanceTypeFuel` | `Icons.local_gas_station` |
| Filter Cleaning | `maintenanceTypeFilterCleaning` | `Icons.air` |
| Brake Fluid | `maintenanceTypeBrakeFluid` | `Icons.opacity` |
| Coolant | `maintenanceTypeCoolant` | `Icons.ac_unit` |
| Chain Oiling | `maintenanceTypeChainOiling` | `Icons.settings` |
| Brake Inspection | `maintenanceTypeBrakeInspection` | `Icons.car_repair` |
| General Service | `maintenanceTypeGeneral` | `Icons.build_circle` |
| Default | - | `Icons.build` |

## Dependencies

- `intl: ^0.18.1` - For date formatting (`DateFormat`)
- Already present in project

## Best Practices

### When Working with This Feature

1. **Always recalculate statuses after deletion**
   - Don't just delete and refresh the list
   - Must call status calculation to update UI everywhere

2. **Always reschedule notifications after deletion**
   - Deleting a record might make maintenance overdue
   - Notifications need to be triggered

3. **Use confirmation dialogs**
   - Deletion is permanent
   - User should confirm before deleting

4. **Show feedback**
   - Success snackbar after deletion
   - Error snackbar if deletion fails

5. **Refresh data after returning**
   - Machine detail screen should reload data when returning from history
   - Use `.then((_) => _loadData())` pattern

### Error Handling

All database operations wrapped in try-catch:
```dart
try {
  await provider.deleteMaintenanceRecord(record.id!);
  // Success feedback
} catch (e) {
  // Error feedback with message
}
```

## Common Pitfalls

❌ **Don't forget to recalculate statuses after delete**
- Forgetting this leaves stale data in UI
- Status indicators won't update

❌ **Don't delete without confirmation**
- Accidental deletions are frustrating
- Always show confirmation dialog

❌ **Don't use switch statements with runtime constants**
- Maintenance type constants are not compile-time constants
- Use if-else chains instead

❌ **Don't forget to refresh parent screen**
- Use `.then((_) => _loadData())` when navigating
- Otherwise machine detail shows stale data

## Future Enhancements

Potential improvements for this feature:

1. **Edit functionality**
   - Allow editing records instead of just deleting
   - Update notes, date, odometer values

2. **Filter/Sort**
   - Filter by maintenance type
   - Sort by date or type
   - Search in notes

3. **Export history**
   - Export to CSV/PDF
   - Email maintenance report

4. **Statistics**
   - Average time between services
   - Total cost (if cost tracking added)
   - Most frequent maintenance types

5. **Batch operations**
   - Select multiple records
   - Delete multiple at once
   - Bulk export

## Testing Checklist

- [ ] Can view all maintenance records
- [ ] Notes are displayed when present
- [ ] Notes section hidden when no notes
- [ ] Delete button shows confirmation dialog
- [ ] Confirmation dialog has correct maintenance type name
- [ ] Successful deletion shows success message
- [ ] List refreshes after deletion
- [ ] Machine detail screen refreshes when returning
- [ ] Status indicators update after deletion
- [ ] Notifications are rescheduled after deletion
- [ ] Empty state shows when no records
- [ ] Back button returns to machine detail
- [ ] Dates format correctly (absolute + relative)
- [ ] Icons match maintenance types
- [ ] Fuel amount shows for fuel maintenance types
- [ ] Odometer values display with correct unit (km/hours)

---

**Remember**: This feature directly impacts maintenance calculations. Always test status recalculation after any changes.
