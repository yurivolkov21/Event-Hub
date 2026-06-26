# Google Sign-In (Firebase Authentication) Setup

This guide explains how to enable **Sign in with Google through Firebase** for the
EventHub Android app, how to obtain the required keys, and how the pieces connect.

## How the flow works

```
[Android app]
  google_sign_in v7  ->  user picks a Google account  ->  Google ID token
        |
        v
  firebase_auth signInWithCredential(GoogleAuthProvider.credential(idToken))
        |  (user now appears in Firebase Console -> Authentication -> Users)
        v
  FirebaseAuth.currentUser.getIdToken()  ->  Firebase ID token
        |
        v
[Backend]  POST /api/auth/google { idToken }
  firebase-admin auth().verifyIdToken(idToken)  ->  { uid, email, name, picture }
        |
        v
  upsert User in MongoDB  ->  issue app JWT  ->  { token, user }
        |
        v
[Android app] stores JWT like a normal login -> can use all app features
```

Key idea: Google sign-in authenticates the user **with Firebase**, then the backend
verifies the Firebase ID token and issues the same app JWT used by email/password
login. The Google user can then create/book events exactly like any other user.

## Keys you need (summary)

| Key | Where it is used | Where to get it |
| --- | --- | --- |
| **Web client ID** (a.k.a. `serverClientId`) | Frontend `GoogleSignIn.initialize(serverClientId:)` | Firebase/Google Cloud Console (auto-created when Google sign-in is enabled) |
| **SHA-1 / SHA-256 fingerprint** | Registered in Firebase so Google trusts the app | Already generated below (debug keystore) |
| `google-services.json` | Android app Firebase config (already present for FCM) | Firebase Console -> Project settings -> Android app |
| Firebase Admin service account | Backend `verifyIdToken` (already configured for FCM) | Already in `server/.env` |

The backend needs **no new key** - it reuses the existing Firebase Admin credentials.

## Step 1 - Enable the Google provider

1. Open **Firebase Console** -> your project (`eventhub-a3933`).
2. Left menu: **Authentication** -> **Sign-in method**.
3. Click **Add new provider** (or edit) -> **Google** -> toggle **Enable**.
4. Set a **Project support email** (your email).
5. **Save**.

## Step 2 - Register the Android SHA fingerprints

Google Sign-In on Android requires the app's signing certificate fingerprint to be
registered in Firebase.

Debug keystore fingerprints for this machine (use these for emulator/debug demo):

```
SHA-1:   FB:9A:70:ED:FE:CF:6B:D4:38:34:03:5D:E2:30:8B:33:BC:6C:7F:22
SHA-256: 47:BD:69:40:C8:7D:F1:9C:3A:45:08:A1:7C:CA:C4:2C:FA:9C:3E:CF:8B:7D:D9:79:5A:E3:17:C9:A7:C6:3C:4F
```

To register them:

1. Firebase Console -> **Project settings** (gear icon) -> **General** tab.
2. Scroll to **Your apps** -> the **Android** app (package `com.example.event_hub` or
   whatever is in `android/app/build.gradle` `applicationId`).
3. Click **Add fingerprint** -> paste the **SHA-1** -> Save. Repeat for **SHA-256**.

> To regenerate later: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
> For a **release** build you must also add the SHA-1/256 of your release keystore.

## Step 3 - Download the updated `google-services.json`

After enabling Google sign-in and adding fingerprints:

1. Same **Project settings** -> **Your apps** -> Android app -> **Download `google-services.json`**.
2. Replace the file at **`android/app/google-services.json`**.

This updated file now contains the OAuth client entries needed by Google Sign-In.

## Step 4 - Get the Web client ID (`serverClientId`)

When you enable Google sign-in, Firebase auto-creates a **Web client** OAuth credential.
This is the value passed as `serverClientId` on Android.

Find it in **either** place:

- **google-services.json**: open the file, look in `oauth_client` for the entry with
  `"client_type": 3`. Its `client_id` (ends with `.apps.googleusercontent.com`) is the
  Web client ID.
- **Google Cloud Console**: https://console.cloud.google.com -> select the project ->
  **APIs & Services** -> **Credentials** -> under **OAuth 2.0 Client IDs**, copy
  **"Web client (auto created by Google Service)"**.

Copy that full ID, e.g. `123456789-abcdef.apps.googleusercontent.com`.

## Step 5 - Plug the Web client ID into the app

The app reads the Web client ID from a compile-time define so it never gets hard-coded.

Run / build the app with an extra `--dart-define`:

```powershell
flutter run -d emulator-5554 ^
  --dart-define=API_BASE_URL=https://eventhub-api-b4yb.onrender.com/api ^
  --dart-define=GOOGLE_SERVER_CLIENT_ID=PASTE_WEB_CLIENT_ID_HERE
```

(`AppConfig.googleServerClientId` is wired to read `GOOGLE_SERVER_CLIENT_ID`.)

## Step 6 - Backend (already implemented)

- Endpoint: `POST /api/auth/google` with body `{ "idToken": "<firebase-id-token>" }`.
- It calls `firebase-admin` `auth().verifyIdToken()`, upserts the user by email
  (role defaults to `user`, `authProvider = google`, no password), and returns the same
  `{ token, user }` shape as `/api/auth/login`.
- No env changes needed on the backend.

## Testing checklist

1. Provider enabled in Firebase, SHA-1/256 added, fresh `google-services.json` in place.
2. App launched with `GOOGLE_SERVER_CLIENT_ID` define.
3. Tap **Continue with Google** -> pick an account.
4. App lands on Home; the account appears under Firebase Console -> Authentication -> Users.
5. The Google user can browse, book, and receive notifications like any user.

## Common errors

- `ApiException: 10` (DEVELOPER_ERROR) -> SHA-1 not registered, or wrong
  `serverClientId`, or stale `google-services.json`. Re-check steps 2-5.
- `sign_in_failed` / `12500` -> usually missing SHA or Google provider not enabled.
- Backend `401 invalid Google token` -> the Firebase ID token is expired or from a
  different project; ensure the app and backend use the same Firebase project.
