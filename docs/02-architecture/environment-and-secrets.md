# Environment And Secrets

This project must not commit real secrets.

## Files To Commit

Commit example files only:

```text
server/.env.example
```

## Files To Ignore

These files must stay out of Git:

```text
.env
.env.*
server/.env
server/.env.*
serviceAccountKey.json
firebase-service-account*.json
server/serviceAccountKey.json
server/firebase-service-account*.json
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

## Backend Environment Variables

```text
NODE_ENV=development
PORT=4000
MONGODB_URI=mongodb://127.0.0.1:27017/eventhub
JWT_SECRET=change-me
JWT_EXPIRES_IN=7d
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@example.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FCM_DRY_RUN=false
```

## Flutter Environment Notes

For Flutter, decide later between:

- Build-time dart define values
- Local config file ignored by Git
- Flavor-based configuration

Minimum values:

```text
API_BASE_URL=http://10.0.2.2:4000/api
```

Android emulator should use `10.0.2.2` to reach localhost backend.

## Firebase Notes

- Firebase service account is only for backend.
- Flutter Android may need `google-services.json`.
- `google-services.json` is ignored in this project to avoid accidental exposure.
- Document setup steps in the final README.

## Secret Rotation

If a secret is accidentally committed:

1. Revoke or rotate the secret immediately.
2. Remove it from Git history if needed.
3. Generate a new value.
4. Update local `.env`.
5. Confirm `.gitignore` catches it.
