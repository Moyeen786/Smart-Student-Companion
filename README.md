# Smart Student Companion

AI-powered academic and parent management platform for students, teachers, parents, and administrators.

## Project overview

Smart Student Companion is a Flutter-based academic platform that unifies academic records, attendance, assignments, announcements, and role-aware dashboard experiences into a single institutional application. It is designed to replace fragmented portals with a cleaner, mobile-first experience for modern colleges and universities.

## Features

- Role-based access for students, faculty, parents, and administrators
- Academic dashboards with attendance, CGPA, assignments, and announcements
- Teacher attendance and assignment workflows
- Parent read-only monitoring flows
- Admin dashboards for users, announcements, analytics, and utilities
- Centralized theme and responsive Flutter UI
- Firebase-ready architecture with a demo repository for local UI work

## Tech stack

- Flutter 3.47.2
- Dart 3.13.2
- Riverpod for state management
- GoRouter for navigation
- Firebase Core, Firebase Auth, and Cloud Firestore (ready for integration)

## Architecture

The app follows a repository-driven layered design:

UI -> Riverpod provider -> Repository -> Data source -> Firebase / mock data

## Folder structure

```text
lib/
├── app/
│   ├── app.dart
│   ├── app_providers.dart
│   └── router.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── app_strings.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_card.dart
│       ├── app_text_field.dart
│       ├── section_header.dart
│       ├── stat_card.dart
│       └── empty_state.dart
├── features/
│   ├── auth/
│   ├── student/
│   ├── teacher/
│   ├── parent/
│   └── admin/
├── models/
│   └── user_model.dart
├── main.dart
└── test/
```

## Authentication flow

1. Splash screen loads.
2. Application routes to the central login portal.
3. User logs in using email and password.
4. New members select a role and complete role-specific registration.
5. Role is determined from the authenticated profile, never from the login form.
6. User is redirected to the role-specific dashboard.

## Role system

Supported roles:

- student
- faculty
- parent
- admin

The role is represented by the `UserRole` enum and converted safely to Firestore values through type-safe helper methods.

## Firebase setup instructions

1. Install FlutterFire CLI.
2. Run `flutterfire configure` in the project root.
3. Add generated configuration in `lib/firebase_options.dart`.
4. Change `authRepositoryProvider` in `lib/app/app_providers.dart` to return `FirebaseAuthRepository`.
5. Initialize Firebase in `main()` before `runApp()`.

## Firestore structure

The current implementation prepares the following structure:

```text
users/{uid}
attendance/
assignments/
timetable/
announcements/
leave_requests/
notes/
departments/
notifications/
```

The `users` collection is implemented by `FirebaseAuthRepository`; `firestore.rules` provides the initial security boundary.

## Security rules explanation

Firestore security rules should enforce:

- unauthenticated users cannot read or write user documents
- users can read only their own profile
- users cannot change their `uid` or `role`
- parents can only access authorized child academic data
- teachers can only access permitted records
- admins manage administrative collections only

This app intentionally avoids client-side trust for RBAC; route protection is a convenience layer only, not a security boundary.

## How to run the project

```bash
flutter pub get
flutter run -d chrome
```

## Testing instructions

```bash
flutter test
flutter analyze
```

## Current implementation status

### Phase 1
- Splash screen implemented
- Welcome screen implemented
- Login screen implemented
- Student dashboard implemented
- Teacher dashboard implemented
- Parent dashboard implemented
- Admin dashboard implemented
- Shared theme and reusable UI widgets added

### Phase 2
- Riverpod integrated
- GoRouter integrated
- User role model and repository interface prepared
- Mock auth repository implemented
- Role-based route architecture prepared

### Phase 3
- Firebase packages added
- Firebase-ready app initialization structure prepared
- Auth repository abstraction created
- Firestore user profile model prepared
- Route protection expected based on role

## Future phases

- AI study assistant
- Firebase Cloud Messaging notifications
- Full attendance and assignment backends
- Analytics insights and reporting
- Campus utility modules and deeper admin features

## Important note

AI features, notifications, and advanced academic modules are intentionally not included in this implementation and are reserved for future phases.
