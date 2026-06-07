# System Architecture

## Overview

EventHub will use a client-server architecture.

```text
Flutter Android app
  -> REST API over HTTPS
Node.js Express TypeScript backend
  -> MongoDB with Mongoose
  -> Firebase Storage for images
  -> Firebase Cloud Messaging for push notifications
```

## Main Components

### Flutter App

Responsibilities:

- Render UI based on Figma screens
- Manage navigation
- Call backend APIs
- Store JWT locally
- Pick and upload images
- Register FCM token
- Handle push notifications

### Express Backend

Responsibilities:

- Authenticate users
- Validate requests
- Enforce authorization
- Provide REST APIs
- Store and query MongoDB data
- Upload images to Firebase Storage
- Send FCM notifications

### MongoDB

Responsibilities:

- Store users
- Store events
- Store bookings
- Store bookmarks
- Store reviews
- Store invitations
- Store notification history
- Store device FCM tokens

### Firebase

Responsibilities:

- Firebase Storage stores uploaded event and profile images
- FCM sends push notifications to Android devices

## Auth Model

- User signs in with email and password.
- Backend verifies password with bcrypt.
- Backend returns JWT.
- Flutter stores JWT securely.
- Protected API calls send `Authorization: Bearer <token>`.
- Backend auth middleware verifies JWT and attaches current user.

## Roles

- `user`: can browse, book, bookmark, review, invite.
- `organizer`: can create, update, and delete own events.
- `admin`: optional role for teacher testing and moderation.

## Data Flow: Create Event With Image

1. Flutter user opens Create Event.
2. User selects an image from device.
3. Flutter submits multipart form data to backend.
4. Backend validates user role.
5. Backend uploads image to Firebase Storage.
6. Backend creates event in MongoDB with image URL.
7. Backend returns created event.
8. Flutter refreshes event list.

## Data Flow: FCM Notification

1. Flutter initializes Firebase Messaging.
2. Flutter receives FCM token.
3. Flutter sends token to backend after login.
4. Backend stores token in MongoDB.
5. A relevant event occurs, such as invitation or booking confirmation.
6. Backend creates notification history record.
7. Backend sends push through Firebase Admin SDK.
8. Flutter receives push and opens the related screen.

## Security Notes

- Hash passwords with bcrypt.
- Never store raw passwords.
- Keep JWT secret in environment variables.
- Keep Firebase service account outside Git.
- Validate request body with Zod.
- Restrict event update/delete to event owner or admin.
- Do not expose internal MongoDB IDs unnecessarily in logs.
