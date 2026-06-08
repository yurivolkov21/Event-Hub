# Definition Of Done

This document defines what "done" means for each implementation step.

## Global Done Rules

A step is done only when:

- Required code or documents are created.
- The related progress file is updated.
- Basic verification is recorded.
- Any known issue is listed clearly.
- The next action is written down.

## Step 01 - Project Setup

Done when:

- Documentation structure exists.
- Backend and Flutter folder plan is documented.
- `.gitignore` includes Flutter, Node.js, pnpm, env, and Firebase secrets.
- `server/.env.example` exists.
- Progress tracker is updated.

Verification:

- `docs/` files exist.
- `server/.env.example` is tracked.
- Secret files are ignored.

## Step 02 - Backend Foundation

Done when:

- Backend project is initialized with pnpm.
- TypeScript config exists.
- Express server starts.
- MongoDB connection is configured.
- `GET /health` returns `{ "status": "ok" }`.
- Backend dev script runs with `pnpm dev`.

Verification:

- Run backend locally.
- Hit health endpoint.
- Confirm MongoDB connects without crashing.

## Step 03 - Authentication

Done when:

- User model exists.
- Register API works.
- Login API works.
- Password is hashed with bcrypt-compatible hashing.
- JWT is returned on login.
- Protected route middleware works.
- Flutter can register, login, store token, and call `/api/auth/me`.

Verification:

- Test register/login with Postman or REST client.
- Test invalid credentials.
- Test protected route without token.
- Test protected route with token.

## Step 04 - Events CRUD

Done when:

- Event model exists.
- Create event API works.
- List events API works.
- Event detail API works.
- Update event API works.
- Delete event API works.
- Organizer ownership rule works.
- Flutter can create, read, update, and delete events.

Verification:

- Create an event as organizer.
- List events as normal user.
- Update owner event.
- Block update from another user.
- Delete owner event.

## Step 05 - Image Storage

Done when:

- Cloudinary credentials are configured.
- Backend accepts multipart image upload.
- Image uploads to Cloudinary.
- Public or signed image URL is saved in MongoDB.
- Flutter can pick an image and upload it with event data.
- Event cards and detail page show uploaded image.

Verification:

- Upload test image.
- Confirm file appears in Cloudinary Media Library.
- Confirm event document has image URL.
- Confirm Flutter renders image from URL.

## Step 06 - Booking And Social

Done when:

- User can book an event.
- User can cancel booking.
- User can bookmark and unbookmark events.
- Invite friend flow creates invitation records.
- Notification history record is created for booking or invitation.
- Flutter has My Tickets or Bookings screen.

Verification:

- Book event.
- Confirm booked count updates.
- Cancel booking.
- Bookmark event.
- Invite another user.

## Step 07 - FCM Notifications

Done when:

- Flutter Firebase Messaging is configured.
- App obtains FCM token.
- App sends token to backend.
- Backend stores token.
- Backend can send test push notification.
- Notification history screen loads saved notifications.

Verification:

- Register token after login.
- Send test push from backend.
- Receive push on Android device or emulator.
- Open notification history.

## Step 08 - Testing And Deploy

Done when:

- Backend is deployed.
- MongoDB Atlas is connected.
- Flutter app uses deployed API URL.
- APK can be built.
- At least one useful test exists.
- Demo account credentials are documented.
- Final README explains setup and demo flow.

Verification:

- Call deployed health endpoint.
- Login with demo account.
- Run required demo flow.
- Build APK successfully.
