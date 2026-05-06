# Data Model: Ecosystem Statistics

## EcosystemStats

Represents a snapshot of the platform's health and growth.

| Field | Type | Description |
|-------|------|-------------|
| totalProperties | int | Total number of properties in the system (all statuses except deleted) |
| verifiedProperties | int | Number of properties with status `verified` |
| totalOwners | int | Total number of users with role `owner` |
| totalStudents | int | Total number of users with role `student` |
| lastUpdated | DateTime | When the stats were last aggregated |

## State Transitions

- **Aggregated**: Stats are computed on-demand or periodically.
- **Refreshed**: Stats are updated when the admin manually triggers a refresh or on dashboard load.
