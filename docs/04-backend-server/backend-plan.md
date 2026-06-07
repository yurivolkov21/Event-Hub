# Backend Plan

## Stack

- Node.js
- Express
- TypeScript
- pnpm
- MongoDB
- Mongoose
- Firebase Admin SDK

## Suggested Folder Structure

```text
server/
  package.json
  pnpm-lock.yaml
  tsconfig.json
  src/
    app.ts
    server.ts
    config/
      env.ts
      database.ts
      firebase.ts
    middlewares/
      auth.middleware.ts
      upload.middleware.ts
      error.middleware.ts
    modules/
      auth/
        auth.controller.ts
        auth.routes.ts
        auth.service.ts
      users/
      events/
      bookings/
      bookmarks/
      notifications/
      invitations/
      reviews/
    utils/
      jwt.ts
      password.ts
```

## Dependencies

Install with pnpm:

```bash
pnpm add express mongoose dotenv cors helmet morgan bcryptjs jsonwebtoken multer firebase-admin zod
pnpm add -D typescript ts-node-dev @types/express @types/cors @types/jsonwebtoken @types/multer @types/morgan
```

## Scripts

```json
{
  "scripts": {
    "dev": "ts-node-dev --respawn --transpile-only src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js"
  }
}
```

## Environment Variables

```text
PORT=4000
MONGODB_URI=mongodb+srv://...
JWT_SECRET=change-me
JWT_EXPIRES_IN=7d
FIREBASE_PROJECT_ID=...
FIREBASE_CLIENT_EMAIL=...
FIREBASE_PRIVATE_KEY=...
FIREBASE_STORAGE_BUCKET=...
```

## Middleware

- `authMiddleware`: verifies JWT.
- `requireRole`: checks user role.
- `uploadMiddleware`: handles multipart files with Multer.
- `errorMiddleware`: returns consistent errors.

## Module Priority

1. Health and database connection
2. Auth
3. Events CRUD
4. Image upload
5. Bookings
6. Bookmarks
7. Notifications and FCM
8. Reviews and invitations

## Firebase Storage Approach

Preferred flow:

1. Flutter sends image as multipart form data.
2. Express receives file through Multer memory storage.
3. Backend uploads file buffer to Firebase Storage.
4. Backend makes the file URL accessible.
5. Backend stores image URL in MongoDB.

## Firebase Cloud Messaging Approach

Preferred flow:

1. Flutter sends FCM token to backend.
2. Backend stores token in `FcmToken`.
3. Backend sends push using Firebase Admin SDK.
4. Backend also creates notification history in MongoDB.

## Authorization Rules

- Only authenticated users can book, bookmark, invite, and review.
- Only organizers can create events.
- Only event owner or admin can update or delete events.
- Admin can moderate data if needed.
