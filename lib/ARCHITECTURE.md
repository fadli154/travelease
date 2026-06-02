# TravelEase — Project Structure

```
lib/
├── main.dart                    # App entry, Firebase init, providers
├── ARCHITECTURE.md              # This file
│
├── core/
│   └── constants/
│       └── firestore_collections.dart
│
├── models/
│   ├── destination_model.dart
│   ├── favorite_model.dart
│   └── user_model.dart
│
├── providers/
│   └── auth_provider.dart       # Auth state + role (admin/user)
│
├── services/
│   ├── auth_service.dart        # Firebase Auth + users collection
│   ├── firebase_service.dart    # Firestore + Storage (destinations, favorites)
│   └── onboarding_prefs.dart    # Splash seen flag
│
├── theme/
│   ├── app_theme.dart
│   ├── app_theme_controller.dart
│   ├── app_colors.dart
│   └── app_spacing.dart
│
├── utils/
│   ├── destination_sections.dart
│   └── location_geocoder.dart
│
├── widgets/                     # Shared UI components
│   ├── animated_favorite_button.dart
│   ├── cached_destination_image.dart
│   ├── destination_card.dart
│   ├── destination_map_card.dart
│   ├── empty_state.dart
│   ├── featured_destination_card.dart
│   ├── hero_destination_banner.dart
│   ├── search_result_tile.dart
│   ├── section_header.dart
│   ├── skeleton_loaders.dart
│   └── theme_toggle_button.dart
│
└── screens/
    ├── app_entry.dart           # Splash → Auth gate → role routing
    ├── main_shell.dart          # User bottom navigation
    │
    ├── splash/
    │   └── splash_screen.dart
    │
    ├── auth/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    │
    ├── home/
    │   └── home_screen.dart
    ├── search/
    │   └── search_screen.dart
    ├── detail/
    │   └── destination_detail_screen.dart
    ├── favorite/
    │   └── favorites_screen.dart
    ├── profile/
    │   └── profile_screen.dart
    │
    └── admin/
        ├── admin_shell.dart
        ├── admin_dashboard_screen.dart
        ├── destination_management_screen.dart
        ├── add_destination_screen.dart
        └── edit_destination_screen.dart
```

## Firestore collections

| Collection     | Fields |
|----------------|--------|
| `users`        | uid, name, email, role (`admin` \| `user`) |
| `destinations` | name, location, description, imageUrl, rating, ticketPrice, category, createdAt |
| `favorites`    | userId, destinationId, createdAt (optional) |

## Role routing

- **Not logged in** → Login (guest optional → User shell read-only favorites)
- **role: user** → `MainShell` (Home, Search, Favorites, Profile)
- **role: admin** → `AdminShell` (Dashboard, Destinations)

## Setup admin user

After first register, set in Firestore Console:

`users/{uid}` → `role: "admin"`
