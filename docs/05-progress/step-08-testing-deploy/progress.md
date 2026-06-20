# Step 08 - Testing And Deploy

Status: Done (backend deployed; APK + demo accounts pending)

## Goal

Prepare the project for demo, grading, and final submission.

## Scope

- Deploy backend to Render or Railway.
- Use MongoDB Atlas.
- Configure Android app with deployed API URL.
- Add at least one useful test.
- Build APK.
- Write final setup instructions.

## Planned Deliverables

- Live backend URL
- MongoDB Atlas connection
- Demo account
- APK build
- Final README update

## Files Changed

- Added `render.yaml`
- Added `server/tests/app.test.js`
- Updated `server/package.json`
- Updated `server/pnpm-lock.yaml`
- Added `docs/06-deployment/testing-and-deploy.md`
- Updated `docs/README.md`
- Updated `README.md`
- Updated `docs/01-planning/demo-grading-checklist.md`

## Verification

- `pnpm test` passed in `server`.
- `pnpm typecheck` passed in `server`.
- `pnpm build` passed in `server`.
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.
- `flutter build apk --debug` passed and produced `build/app/outputs/flutter-apk/app-debug.apk`.

## Notes

- Deployment should happen after core APIs are stable.
- Backend test currently verifies `/health` and protected route rejection without a bearer token.
- `render.yaml` is prepared for a Render Blueprint web service using `server/` as `rootDir`.
- MongoDB Atlas and Render live URL still need real dashboard setup.
- Demo accounts should be created manually through the app before final submission.
- `flutter build apk --debug` currently passes with a `share_plus` Kotlin Gradle Plugin future-compatibility warning. It does not block the debug build.

## Phase B Deploy - 2026-06-20

- MongoDB Atlas free cluster created and connected (database `eventhub`); connection verified from local with ping OK.
- Backend deployed to Render as a Blueprint web service: https://eventhub-api-b4yb.onrender.com
- Production health check returns `status: ok` with the database connected to the Atlas host.
- Fixed the Render build: replaced `corepack enable` (failed with EROFS on Render's read-only `/usr/bin`) with `npx --yes pnpm@11.4.0 ...`, changed the start command to `node dist/server.js`, and pinned `NODE_VERSION` to 22.
- Ran the full demo-flow smoke test against the live URL + Atlas: 25/25 checks passed.
- Smoke-test data was removed from Atlas after verification.

## Next Action

Build the demo APK against the deployed API (`flutter build apk --debug --dart-define=API_BASE_URL=https://eventhub-api-b4yb.onrender.com/api`), create the organizer/user demo accounts through the app, and record them in the demo-grading checklist.
