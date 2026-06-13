# EventHub

EventHub is a Flutter Android event booking app with a Node.js, Express, TypeScript, MongoDB, Cloudinary, and Firebase Cloud Messaging backend.

## Main Requirements

- Server backend and database
- CRUD on Android
- Authentication
- Push notification with FCM

## Tech Stack

- App: Flutter
- Backend: Node.js, Express, TypeScript
- Package manager: pnpm
- Database: MongoDB with Mongoose
- Auth: JWT and bcryptjs
- Image storage: Cloudinary
- Push notifications: Firebase Cloud Messaging with Firebase Admin SDK

## Project Structure

```text
lib/       Flutter app
server/    Express TypeScript backend
docs/      Planning, architecture, progress, and deployment guides
```

## Backend Setup

```powershell
cd server
pnpm install
Copy-Item .env.example .env
pnpm dev
```

Required local values in `server/.env`:

```text
MONGODB_URI
JWT_SECRET
CLOUDINARY_CLOUD_NAME
CLOUDINARY_API_KEY
CLOUDINARY_API_SECRET
FIREBASE_PROJECT_ID
FIREBASE_CLIENT_EMAIL
FIREBASE_PRIVATE_KEY
```

Health check:

```text
http://localhost:4000/health
```

## Flutter Setup

For Android emulator with local backend:

```powershell
flutter run -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:4000/api
```

For Chrome/web with local backend:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:4000/api
```

For deployed backend:

```powershell
flutter run -d <device-id> --dart-define=API_BASE_URL=https://<service-name>.onrender.com/api
```

## Verification

Backend:

```powershell
cd server
pnpm test
pnpm typecheck
pnpm build
```

Flutter:

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Debug APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Deployment

The repository includes `render.yaml` for a Render Blueprint deployment. See:

```text
docs/06-deployment/testing-and-deploy.md
```

## Documentation

Start here:

```text
docs/README.md
```

Key docs:

- `docs/01-planning/implementation-roadmap.md`
- `docs/02-architecture/api-contract.md`
- `docs/02-architecture/environment-and-secrets.md`
- `docs/05-progress/README.md`
- `docs/06-deployment/testing-and-deploy.md`
