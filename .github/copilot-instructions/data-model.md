# Data Model

**Date**: 4 de fevereiro de 2026

## Entity: Machine/Vehicle

### Core Attributes

#### Required
- `id`: Unique identifier
- `type`: ENUM (Vehicle, Machine, Generator, etc.)
- `brand`: String
- `model`: String

#### Optional
- `picture`: Image/Photo
- `nickname`: String
- `serialNumber`: String
- `year`: Integer
- `sparkPlugType`: String
- `oilType`: String
- `tankSize`: Float (liters)

#### Odometer/Usage Tracking
- `currentOdometer`: Float
  - For vehicles: kilometers
  - For machines: hours
- `odometerUnit`: ENUM (km, hours)

#### Maintenance Interval Configuration
- `maintenanceIntervalType`: ENUM (distance, time, both)
- `maintenanceIntervals`: JSON/Object storing intervals for different maintenance types

### Metadata
- `createdAt`: DateTime
- `updatedAt`: DateTime

## Entity: Maintenance Record

### Attributes
- `id`: Unique identifier
- `machineId`: Foreign key to Machine
- `date`: Date
- `maintenanceType`: ENUM (oil_change, filter_cleaning, chain_oiling, brake_fluid_change, coolant_change, spark_plug_change, etc.)
- `odometerAtService`: Float (km or hours at time of service)
- `notes`: String (optional)
- `createdAt`: DateTime

## Entity: Maintenance Type Configuration

### Attributes
- `id`: Unique identifier
- `machineId`: Foreign key to Machine
- `maintenanceType`: String (oil, brakes, chain, etc.)
- `intervalDistance`: Float (km or hours, nullable)
- `intervalTime`: Integer (days, nullable)
- `lastServiceDate`: Date (nullable)
- `lastServiceOdometer`: Float (nullable)
- `enabled`: Boolean

## Storage Strategy
- **Local SQLite database** for structured data
- **Local file storage** for images
- No network/cloud sync
- Backup strategy: TBD (future consideration)
