# Step 05 - Image Storage

Status: In progress

## Goal

Upload event images to Firebase Storage.

## Scope

- Configure Firebase Admin SDK in backend.
- Add Multer upload middleware.
- Upload image buffer to Firebase Storage.
- Store image URL in Event document.
- Pick image from Flutter app.
- Show uploaded image on event cards and detail page.

## Planned Deliverables

- Backend Firebase config
- Image upload support in create or update event
- Flutter image picker integration
- Network image rendering

## Files Changed

- Added `server/src/config/firebase.ts`
- Added `server/src/middlewares/upload.middleware.ts`
- Added `server/src/modules/images/image-storage.service.ts`
- Updated `server/src/middlewares/error.middleware.ts`
- Updated `server/src/modules/events/event.controller.ts`
- Updated `server/src/modules/events/event.routes.ts`
- Updated `server/src/modules/events/event.service.ts`
- Updated `server/package.json`
- Updated `server/pnpm-lock.yaml`
- Updated `server/pnpm-workspace.yaml`
- Updated `server/tsconfig.json`

## Verification

- `pnpm typecheck` passed.
- `pnpm build` passed.
- JSON `POST /api/events` still returned `201` after adding Multer middleware.
- Multipart `POST /api/events` with non-image file returned `400`.
- Test user and event were removed from local MongoDB after verification.

## Notes

- Firebase service account must not be committed.
- Use Firebase Storage for image storage, not MongoDB.
- Backend upload plumbing is implemented.
- Firebase Admin initializes lazily, so the server can still start without Firebase credentials.
- If Firebase env values are missing or placeholder values, image upload returns `Firebase Storage is not configured`.
- Event create/update now accepts multipart field `image`.
- Actual upload to Firebase Storage has not been executed in this pass to avoid writing to external storage without explicit confirmation.
- Flutter image picker and network image rendering are still pending.

## Next Action

Verify real Firebase upload with project credentials, then implement Flutter image picker and event image rendering.
