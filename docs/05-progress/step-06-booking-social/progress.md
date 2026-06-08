# Step 06 - Booking And Social

Status: In progress

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
- My tickets UI

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
- Updated `server/src/modules/events/event.routes.ts`
- Updated `server/src/app.ts`
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

## Notes

- Payment can be simulated for the course project.
- Booking success should create a notification record.
- Backend APIs are implemented and verified.
- FCM push delivery is not part of this step; Step 06 creates notification history records only.
- Flutter My Tickets, Bookmark button, Invite Friend UI, and Share flow are still pending.
- Booking cancellation changes status to `cancelled` and decrements event `bookedCount`.
- Bookmark creation is idempotent through a unique `userId + eventId` index.

## Next Action

Start Step 07 FCM notifications, or connect Flutter UI for auth/events/booking/bookmark before adding push delivery.
