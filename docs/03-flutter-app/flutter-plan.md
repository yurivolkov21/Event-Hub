# Flutter App Plan

## Current State

The app now contains a minimal EventHub app shell in `lib/main.dart`.

Implemented Flutter foundation:

- Firebase initializes before `runApp`.
- Firebase Messaging background handler is registered.
- FCM permission request and token retrieval are scaffolded.
- `FcmNotificationService.registerCurrentToken(authToken)` can be called after login.
- API base URL can be overridden with `--dart-define=API_BASE_URL=...`.
- Sign-in and sign-up forms are implemented.
- JWT and user summary are stored with `flutter_secure_storage`.
- Saved sessions are restored through `GET /api/auth/me`.
- Event list and detail screens are connected to the backend Events API.
- Organizer create, edit, and delete event flows are implemented with JSON payloads.

## Suggested Folder Structure

```text
lib/
  main.dart
  app.dart
  core/
    config/
    constants/
    networking/
    storage/
    theme/
    widgets/
  features/
    auth/
      data/
      presentation/
    events/
      data/
      presentation/
    bookings/
      data/
      presentation/
    notifications/
      data/
      presentation/
    profile/
      data/
      presentation/
```

## Suggested Packages

Add these only when implementation starts:

```text
dio
go_router
provider or flutter_bloc
flutter_secure_storage
image_picker
cached_network_image
firebase_core
firebase_messaging
http
intl
```

If using a simpler state approach for the course project, `provider` is enough.

## Screens To Implement

Auth:

- Splash
- Onboarding
- Sign in
- Sign up
- Reset password

Main:

- Home
- Event list: implemented
- Search
- Filter
- Event detail: implemented
- Map view
- Notifications
- Profile

Organizer:

- My created events
- Create event: implemented
- Edit event: implemented
- Event management detail

Booking:

- Buy ticket confirmation
- My tickets

## Navigation

Use `go_router` for named routes:

```text
/
/onboarding
/sign-in
/sign-up
/reset-password
/home
/events
/events/:id
/events/create
/events/:id/edit
/tickets
/notifications
/profile
/map
```

## Local Storage

Store:

- JWT token: implemented
- Current user summary: implemented
- Onboarding seen flag

Use `flutter_secure_storage` for token.

## API Layer

Create a reusable HTTP client that:

- Uses backend base URL: implemented
- Adds JWT header when available: implemented
- Handles 401 by clearing session: implemented in session restore
- Parses error response: implemented

## FCM Integration

Flutter should:

- Initialize Firebase: implemented
- Request notification permission: implemented
- Get FCM token: implemented
- Send token to backend after login: implemented in auth controller
- Listen for foreground messages: scaffolded
- Open related screen when user taps notification

## UI Notes From Figma

- Primary color is blue-purple.
- Accent colors appear in category chips.
- Event cards use strong image thumbnails.
- Detail page uses large hero image.
- Bottom navigation has a centered create/add action.
- Use empty states for no events and no notifications.
