# Tech Stack & Tools

- **Frontend:** Flutter Web (Dart 3.x)
- **Backend:** Supabase (BaaS)
- **Database:** PostgreSQL (Relational, real-time via `.stream()`)
- **Authentication:** Supabase Auth (GoTrue - Email/Password)
- **Storage:** Supabase Storage (property/room images)
- **Hosting:** Supabase Hosting / Vercel / Netlify (SSL, global CDN)
- **AI Integration:** Gemini API (room description generation, content moderation) - *[Post-MVP]*

> [!IMPORTANT]
> **Strict Budget Constraint:** The project utilizes the Supabase **Free Tier** ($0/month). All architectural decisions must respect the limits of the free plan (e.g., 500MB database size, 5GB bandwidth).

## Project Structure
```
vacansee/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── models/           # Type-safe models (Property, Room, User)
│   ├── providers/        # State management (Provider)
│   ├── services/         # Supabase repositories, API calls
│   ├── screens/          # Page widgets (Feature-based organization)
│   ├── widgets/          # Reusable UI components
│   └── utils/            # Helpers, constants, styling
├── test/                 # Unit and Widget tests
├── web/
├── schema.sql            # Master SQL schema for Supabase
├── seed.sql              # Initial data for development
└── pubspec.yaml
```

## Key Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.x      # Primary Backend
  provider: ^6.x              # State Management
  cached_network_image: ^3.x  # Image Caching
  image_picker: ^1.x          # Media Uploads
  flutter_dotenv: ^6.x        # Environment Configuration
  shimmer: ^3.x               # Premium Loading States
```

## Error Handling Pattern (Repository)
```dart
// Repository pattern using Supabase relational queries
class PropertyRepository {
  final SupabaseClient _supabase;

  PropertyRepository(this._supabase);

  Future<List<Property>> getPropertiesByFilter({
    required String genderOrientation,
    required int maxPrice,
  }) async {
    try {
      final response = await _supabase
          .from('properties')
          .select('*, rooms(*)') // Relational join
          .eq('gender_orientation', genderOrientation)
          .lte('price_range->max', maxPrice)
          .eq('is_verified', true);
      
      return (response as List)
          .map((data) => Property.fromJson(data))
          .toList();
    } on PostgrestException catch (e) {
      throw PropertyException('Database error: ${e.message}');
    } catch (e) {
      throw PropertyException('Unexpected error: $e');
    }
  }
}
```

## Styling & Component Examples
```dart
// RoomCard widget showing real-time vacancy status
class RoomCard extends StatelessWidget {
  final Room room;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Shimmer loading handled in parent view
          CachedNetworkImage(imageUrl: room.images.first),
          
          Row(
            children: [
              Text('₱${room.monthlyRate}'),
              Chip(label: Text(room.status.toString().split('.').last)),
            ],
          ),
          
          // Vacancy badge (Utilizing real-time stream updates)
          Badge(
            label: Text(room.status == RoomStatus.vacant ? 'Live' : 'Occupied'),
            backgroundColor: room.status == RoomStatus.vacant ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
```

## Naming Conventions
- **Files:** snake_case (e.g., `property_card.dart`)
- **Classes:** PascalCase (e.g., `PropertyCard`)
- **Variables:** camelCase (e.g., `propertyList`)
- **Database Tables/Columns:** snake_case (e.g., `owner_id`, `is_verified`)
