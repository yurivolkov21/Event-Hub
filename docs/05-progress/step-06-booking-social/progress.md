# Step 06 - Booking And Social

Status: Implementation complete, manual QA pending

## Goal

Add booking, bookmark, invitation, and social features from the EventHub design.

## Scope

- Booking APIs.
- Bookmark APIs.
- Invitation APIs.
- Notification history records.
- My tickets screen.
- Bookmark button.
- Invite friend flow.
- Share flow.

## Planned Deliverables

- `POST /api/bookings`
- `GET /api/bookings/me`
- `DELETE /api/bookings/:id`
- Bookmark create/list/delete
- Invitation create/accept/reject
- User search/list for invite friend
- My tickets UI
- Invite Friend UI
- Native Share flow

## Files Changed

- Added `server/src/modules/bookings/booking.model.ts`
- Added `server/src/modules/bookings/booking.dto.ts`
- Added `server/src/modules/bookings/booking.schemas.ts`
- Added `server/src/modules/bookings/booking.service.ts`
- Added `server/src/modules/bookings/booking.controller.ts`
- Added `server/src/modules/bookings/booking.routes.ts`
- Added `server/src/modules/bookmarks/bookmark.model.ts`
- Added `server/src/modules/bookmarks/bookmark.dto.ts`
- Added `server/src/modules/bookmarks/bookmark.schemas.ts`
- Added `server/src/modules/bookmarks/bookmark.service.ts`
- Added `server/src/modules/bookmarks/bookmark.controller.ts`
- Added `server/src/modules/bookmarks/bookmark.routes.ts`
- Added `server/src/modules/invitations/invitation.model.ts`
- Added `server/src/modules/invitations/invitation.dto.ts`
- Added `server/src/modules/invitations/invitation.schemas.ts`
- Added `server/src/modules/invitations/invitation.service.ts`
- Added `server/src/modules/invitations/invitation.controller.ts`
- Added `server/src/modules/invitations/invitation.routes.ts`
- Added `server/src/modules/notifications/notification.model.ts`
- Added `server/src/modules/notifications/notification.dto.ts`
- Added `server/src/modules/notifications/notification.schemas.ts`
- Added `server/src/modules/notifications/notification.service.ts`
- Added `server/src/modules/notifications/notification.controller.ts`
- Added `server/src/modules/notifications/notification.routes.ts`
- Added `server/src/modules/users/user.schemas.ts`
- Added `server/src/modules/users/user.service.ts`
- Added `server/src/modules/users/user.controller.ts`
- Added `server/src/modules/users/user.routes.ts`
- Added `lib/features/bookings/data/booking_models.dart`
- Added `lib/features/bookings/data/booking_repository.dart`
- Added `lib/features/bookings/presentation/my_tickets_screen.dart`
- Added `lib/features/bookmarks/data/bookmark_models.dart`
- Added `lib/features/bookmarks/data/bookmark_repository.dart`
- Added `lib/features/users/data/user_models.dart`
- Added `lib/features/users/data/user_repository.dart`
- Added `lib/features/invitations/data/invitation_models.dart`
- Added `lib/features/invitations/data/invitation_repository.dart`
- Added `lib/features/invitations/presentation/invite_friends_sheet.dart`
- Updated `lib/features/events/presentation/event_detail_screen.dart`
- Updated `lib/features/auth/presentation/signed_in_home_screen.dart`
- Updated `server/src/modules/events/event.routes.ts`
- Updated `server/src/app.ts`
- Updated `pubspec.yaml`
- Updated `docs/02-architecture/api-contract.md`

## Verification

- `pnpm typecheck` passed.
- `pnpm build` passed.
- Organizer created a test event.
- User created booking with `POST /api/bookings`.
- `GET /api/bookings/me` returned booking.
- Event `bookedCount` increased after booking.
- Booking created notification history record.
- User created bookmark with `POST /api/bookmarks/:eventId`.
- `GET /api/bookmarks/me` returned bookmark.
- User removed bookmark with `DELETE /api/bookmarks/:eventId`.
- User invited another user with `POST /api/events/:eventId/invitations`.
- Invitee saw invitation with `GET /api/invitations/me`.
- Invitee saw invitation notification with `GET /api/notifications`.
- Invitee marked notification read with `PUT /api/notifications/:id/read`.
- Invitee accepted invitation with `PUT /api/invitations/:id/accept`.
- User cancelled booking with `DELETE /api/bookings/:id`.
- Event `bookedCount` decreased after cancellation.
- Test users, event, booking, bookmark, invitation, and notifications were removed from local MongoDB after verification.
- `flutter analyze` passed after Flutter booking/bookmark integration.
- `flutter test` passed after Flutter booking/bookmark integration.
- `flutter build web` passed after Flutter booking/bookmark integration.
- `flutter build apk --debug` passed after Flutter booking/bookmark integration.
- `pnpm typecheck` passed after Flutter booking/bookmark integration.
- `pnpm build` passed after Flutter booking/bookmark integration.
- `dart format lib test` passed after Invite Friend and Share integration.
- `flutter analyze` passed after Invite Friend and Share integration.
- `flutter test` passed after Invite Friend and Share integration.
- `flutter build web` passed after Invite Friend and Share integration.
- `flutter build apk --debug` passed after Invite Friend and Share integration.
- `pnpm typecheck` passed after adding `GET /api/users`.
- `pnpm build` passed after adding `GET /api/users`.

## Notes

- Payment can be simulated for the course project.
- Booking success should create a notification record.
- Backend APIs are implemented and verified.
- FCM push delivery is not part of this step; Step 06 creates notification history records only.
- Flutter My Tickets screen is implemented.
- Flutter event detail can create bookings and toggle bookmarks.
- Flutter event detail can invite friends through a searchable bottom sheet.
- Flutter event detail can open the native share sheet through `share_plus`.
- Booking cancellation changes status to `cancelled` and decrements event `bookedCount`.
- Bookmark creation is idempotent through a unique `userId + eventId` index.
- `flutter build apk --debug` currently passes with a `share_plus` Kotlin Gradle Plugin future-compatibility warning. It does not block the debug build.

## Next Action

Manual test booking, bookmark, invite friend, share, notifications, and FCM on Android emulator with the local backend.
