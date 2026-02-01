# Copilot Instructions for AI Agents

## Project Overview
This is a Flutter/Dart mobile app for pet care management, supporting both pet owners and veterinary clinics. The app centralizes pet profiles, medical records, reminders, activity tracking, and clinic management. Firebase (Authentication, Firestore, Storage) is used for backend services.

## Architecture & Key Components
- **lib/**: Main Dart source code.
  - **bottom_navigation/**: Navigation widgets for owners and clinics.
  - **clinic_dashboard/**: Clinic-side features (appointments, medical records, schedule).
  - **create_account/**: Account creation for clinics and owners.
  - **login/**: Authentication UI and logic.
  - **models/**: Data models (e.g., appointment, user, pet).
  - **owner_homescreen/**: Owner dashboard, pet management, appointments.
  - **profile_screen/**: Profile management for owners and clinics.
  - **reminders/**: Reminder and notification logic.
  - **services/**: Service classes for Firebase and business logic (e.g., auth_service.dart).
  - **vet_finder/**: Find nearby clinics.
- **firebase.json, firestore.rules**: Firebase configuration and security rules.
- **pubspec.yaml**: Declares dependencies (Firebase, Flutter packages).

## Developer Workflows
- **Build/Run:**
  - Use `flutter run` for development.
  - Use `flutter build apk` or `flutter build ios` for production builds.
- **Testing:**
  - Place widget and integration tests in `test/`.
  - Run tests with `flutter test`.
- **Firebase Setup:**
  - Ensure `google-services.json` (Android) and proper iOS setup for Firebase.
  - Update `firebase_options.dart` using `flutterfire configure` if Firebase config changes.

## Project Conventions
- **Navigation:**
  - Use bottom navigation widgets for role-based home screens (see `bottom_navigation/`).
- **State Management:**
  - Follows standard Flutter setState and provider patterns; no custom state management library detected.
- **Models:**
  - All data models are in `lib/models/` and use explicit fields for serialization.
- **Services:**
  - All Firebase and business logic is in `lib/services/`.
- **Reminders/Notifications:**
  - Logic is in `lib/reminders/` and integrates with Firebase for scheduling.

## Integration Points
- **Firebase:**
  - Authentication, Firestore, and Storage are used throughout. See `lib/services/auth_service.dart` and related files.
- **External Packages:**
  - All dependencies are declared in `pubspec.yaml`.

## Patterns & Examples
- **Adding a new feature:**
  - Create a new directory in `lib/` (e.g., `lib/feature_name/`).
  - Add UI, models, and service logic as needed.
- **Modifying navigation:**
  - Update the relevant widget in `lib/bottom_navigation/`.
- **Updating models:**
  - Edit or add files in `lib/models/` and update serialization logic.

## References
- See `README.md` for high-level project goals, features, and diagrams.
- Firebase setup: `firebase.json`, `firestore.rules`, `google-services.json`, `firebase_options.dart`.

---
For more details, review the directory structure and referenced files. If a pattern or workflow is unclear, ask for clarification or check the `README.md` for context.
