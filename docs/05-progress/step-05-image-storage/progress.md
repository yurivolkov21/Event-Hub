# Step 05 - Image Storage

Status: In progress

## Goal

Upload event images to Cloudinary.

## Scope

- Configure Cloudinary in backend.
- Add Multer upload middleware.
- Upload image buffer to Cloudinary.
- Store image URL and Cloudinary public id in Event document.
- Pick image from Flutter app.
- Show uploaded image on event cards and detail page.

## Planned Deliverables

- Backend Cloudinary config
- Image upload support in create or update event
- Flutter image picker integration
- Network image rendering

## Files Changed

- Added `server/src/config/firebase.ts`
- Added `server/src/middlewares/upload.middleware.ts`
- Added `server/src/modules/images/image-storage.service.ts`
- Updated `server/src/config/env.ts`
- Updated `server/src/config/firebase.ts`
- Updated `server/src/modules/events/event.model.ts`
- Updated `server/src/middlewares/error.middleware.ts`
- Updated `server/src/modules/events/event.controller.ts`
- Updated `server/src/modules/events/event.routes.ts`
- Updated `server/src/modules/events/event.service.ts`
- Updated `server/.env.example`
- Updated `docs/README.md`
- Updated `docs/01-planning/product-plan.md`
- Updated `docs/01-planning/scope-control.md`
- Updated `docs/01-planning/implementation-roadmap.md`
- Updated `docs/01-planning/definition-of-done.md`
- Updated `docs/02-architecture/system-architecture.md`
- Updated `docs/02-architecture/environment-and-secrets.md`
- Updated `docs/04-backend-server/backend-plan.md`
- Updated `docs/05-progress/step-04-events-crud/progress.md`
- Updated `server/package.json`
- Updated `server/pnpm-lock.yaml`
- Updated `server/pnpm-workspace.yaml`
- Updated `server/tsconfig.json`

## Verification

- `pnpm typecheck` passed.
- `pnpm build` passed.
- `pnpm typecheck` passed after Cloudinary migration.
- `pnpm build` passed after Cloudinary migration.
- Direct Cloudinary upload test returned `CLOUDINARY_UPLOAD=OK`.
- Direct Cloudinary cleanup test returned `CLOUDINARY_DELETE=OK`.
- JSON `POST /api/events` still returned `201` after adding Multer middleware.
- Multipart `POST /api/events` with non-image file returned `400`.
- Test user and event were removed from local MongoDB after verification.

## Notes

- Firebase service account must not be committed; Firebase is kept for FCM only.
- Use Cloudinary for image storage, not MongoDB and not Firebase Storage.
- Backend upload plumbing is implemented and migrated to Cloudinary.
- If Cloudinary env values are missing or placeholder values, image upload returns `Cloudinary image storage is not configured`.
- Event create/update now accepts multipart field `image`.
- Event documents now store `imageUrl` and internal `imagePublicId`.
- Replacing or deleting an event attempts to clean up the old Cloudinary image.
- Flutter image picker and network image rendering are still pending.

## Next Action

Implement Flutter image picker and event image rendering when the Flutter UI layer is connected.
