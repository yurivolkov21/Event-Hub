# Implementation Roadmap

## Step 01 - Project Setup

Goal: prepare the Flutter app and backend workspace.

Deliverables:

- Clean Flutter starter structure
- Create `server/` folder
- Add `server/.env.example`
- Initialize pnpm backend project
- Configure TypeScript
- Configure environment files
- Add shared documentation and progress tracking

## Step 02 - Backend Foundation

Goal: build the base Express TypeScript server.

Deliverables:

- Express app
- MongoDB connection with Mongoose
- Environment loader
- Error middleware
- Request logging
- Health check route
- Basic module folder structure

## Step 03 - Authentication

Goal: enable secure user identity.

Deliverables:

- User model
- Register API
- Login API
- JWT generation
- Auth middleware
- Current user API
- Password hashing with bcrypt
- Flutter sign in and sign up screens connected to API

## Step 04 - Events CRUD

Goal: satisfy the primary CRUD requirement.

Deliverables:

- Event model
- Create event API
- List events API
- Event detail API
- Update event API
- Delete event API
- Flutter event list and detail screens
- Flutter create and edit event screens

## Step 05 - Image Storage

Goal: upload event images from Android to Firebase Storage.

Deliverables:

- Firebase Admin setup
- Multer upload middleware
- Upload image API
- Save image URL in MongoDB
- Flutter image picker integration
- Event cards and detail images loaded from URL

## Step 06 - Booking And Social Features

Goal: make the app feel like EventHub instead of a plain CRUD app.

Deliverables:

- Booking model and APIs
- Bookmark model and APIs
- Invitation model and APIs
- Notification model
- My tickets screen
- Bookmark action
- Invite friend action
- Share action

## Step 07 - FCM Notifications

Goal: satisfy push notification requirement.

Deliverables:

- Register FCM token API
- Store FCM token in MongoDB
- Send notification from backend using Firebase Admin SDK
- Flutter Firebase Messaging setup
- Local handling for foreground messages
- Notification history screen

## Step 08 - Testing And Deploy

Goal: make the project presentable and testable.

Deliverables:

- Backend deploy to Render or Railway
- MongoDB Atlas database
- Android app configured with deployed API URL
- At least one backend test or Flutter unit test
- APK build
- Final README with demo accounts and API URL
- Demo and grading checklist completed

## Suggested Order

1. Backend foundation
2. Auth backend
3. Flutter auth UI integration
4. Events CRUD backend
5. Flutter event screens
6. Image upload
7. Booking and bookmarks
8. FCM notifications
9. Deploy and final polish

## Scoring Checklist

- Server backend and database: planned in steps 02, 03, 04, 06, 07
- CRUD on Android: planned in step 04
- Authentication: planned in step 03
- Push notification FCM: planned in step 07
- Image storage: planned in step 05
- Search/filter: planned after event list
- Deploy server: planned in step 08
- Tests: planned in step 08
