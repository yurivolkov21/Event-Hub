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
- Added `lib/features/events/data/event_models.dart`
- Added `lib/features/events/data/event_repository.dart`
- Added `lib/features/events/presentation/event_image.dart`
- Added `lib/features/events/presentation/event_list_screen.dart`
- Added `lib/features/events/presentation/event_detail_screen.dart`
- Updated `lib/core/networking/api_client.dart`
- Updated `lib/features/auth/presentation/signed_in_home_screen.dart`
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
- `flutter analyze` passed after Flutter event list/detail integration.
- `flutter test` passed after Flutter event list/detail integration.
- `flutter build apk --debug` passed after Flutter event list/detail integration.
- `pnpm typecheck` passed after Flutter event list/detail integration.
- `pnpm build` passed after Flutter event list/detail integration.

## Notes

- This backend step prepares the API needed to prove Android CRUD later.
- Event owner or admin can update/delete.
- Backend CRUD is implemented and verified.
- Flutter event list and detail screens are connected to the Events API.
- Flutter organizer create/edit/delete screens are still pending to fully prove CRUD from Android UI.
- Event uses `categoryId` as an ObjectId string, matching the current database plan. Category seed/module can be added later.
- Image upload is not included in this step. `imageUrl` is accepted for now and Cloudinary upload is planned in Step 05.

## Next Action

Implement Flutter organizer create/edit/delete screens, then add image picker upload for event covers.
