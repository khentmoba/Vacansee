# Research: UI Inconsistencies Fix

## UI Alignment and Header Tabs
- **Decision:** Use `TabBar` with a customized `indicator` and identical typography for selected/unselected states to prevent vertical layout shifting.
- **Rationale:** Standard Flutter `TabBar` provides a clean underline indicator without vertical shifting if configured correctly (e.g. `labelStyle` and `unselectedLabelStyle` having the exact same font size and weight). This addresses FR-001 and FR-002.
- **Alternatives considered:** Building a custom animated container navigation bar (rejected as over-engineered for simple tabs, violating Performant Simplicity).

## Mobile UI Alignment (Admin Dashboard)
- **Decision:** Enforce consistent constraints (`ConstrainedBox`, `SizedBox`) and padding (`EdgeInsets.symmetric`) on `admin_dashboard.dart` and related widgets (`admin_user_card.dart`, `admin_property_card.dart`). Enforce `TextOverflow.ellipsis` for long text elements.
- **Rationale:** Aligns with the Mobile-First Excellence principle. Ellipsis prevents widgets from breaking constraints or increasing row height unexpectedly. This addresses FR-003 and the edge case for long text.
- **Alternatives considered:** Auto-scaling font size via `FittedBox` (rejected as it can lead to unreadable microscopic text on small devices).

## Compact Data Tables with Overflow
- **Decision:** Wrap data lists/tables inside a centered `ConstrainedBox` with a specific `maxWidth` (e.g., 1200px) for web/desktop. Wrap the inner table/row content with `SingleChildScrollView(scrollDirection: Axis.horizontal)`.
- **Rationale:** Ensures compact readability on wide screens (FR-004) while preserving full data formatting via horizontal scroll for overflow columns.
- **Alternatives considered:** Truncating column data (rejected as administrative data often requires full visibility).

## Admin Profile Permissions Checklist
- **Decision:** Refactor the permission assignment UI in the Admin Profile to use standard `CheckboxListTile` widgets instead of custom buttons.
- **Rationale:** Checklists are a universal, recognizable pattern for assigning multiple permissions/roles, reducing cognitive load and simplifying the interface (FR-005).
- **Alternatives considered:** Multi-select dropdown (rejected as checklists provide better visibility of all available permissions at a glance).
