# Step 04 - Events CRUD

Status: Done

## Goal

Implement the primary CRUD feature for events.

## Scope

- Event model.
- Event list.
- Event detail.
- Create event.
- Update event.
- Delete event.
- Organizer-only authorization.
- Flutter event screens connected to backend.

## Planned Deliverables

- `GET /api/events`
- `GET /api/events/:id`
- `POST /api/events`
- `PUT /api/events/:id`
- `DELETE /api/events/:id`
- Home event list
- Event detail screen
- Create and edit event screens

## Files Changed

- Added `server/src/modules/events/event.model.ts`
- Added `server/src/modules/events/event.dto.ts`
- Added `server/src/modules/events/event.schemas.ts`
- Added `server/src/modules/events/event.service.ts`
- Added `server/src/modules/events/event.controller.ts`
- Added `server/src/modules/events/event.routes.ts`
- Updated `server/src/app.ts`

## Verification

- `pnpm typecheck` passed.
- `pnpm build` passed.
- `POST /api/events` with normal user returned `403`.
- `POST /api/events` with organizer returned `201`.
- `GET /api/events` returned created event in paginated list.
- `GET /api/events/:id` returned event detail.
- `PUT /api/events/:id` with organizer returned `200`.
- `PUT /api/events/:id` with normal user returned `403`.
- `DELETE /api/events/:id` with organizer returned `204`.
- `GET /api/events/:id` after delete returned `404`.
- Test users and event were removed from local MongoDB after verification.

## Notes

- This backend step prepares the API needed to prove Android CRUD later.
- Event owner or admin can update/delete.
- Backend CRUD is implemented and verified.
- Flutter event screens are not connected yet; that is still needed to fully prove CRUD from the Android UI.
- Event uses `categoryId` as an ObjectId string, matching the current database plan. Category seed/module can be added later.
- Image upload is not included in this step. `imageUrl` is accepted for now and Cloudinary upload is planned in Step 05.

## Next Action

Start Step 05 Image Storage, or connect Flutter event screens before moving deeper into backend features.
