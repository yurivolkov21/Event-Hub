# Step 07 - FCM Notifications

Status: In progress

## Goal

Implement Firebase Cloud Messaging push notifications.

## Scope

- Flutter Firebase Messaging setup.
- Request Android notification permission where needed.
- Register FCM token with backend.
- Store token in MongoDB.
- Send push from backend.
- Show notification history.

## Planned Deliverables

- `POST /api/notifications/register-token`
- `GET /api/notifications`
- `PUT /api/notifications/:id/read`
- Push on booking success or invitation
- Notification screen populated from backend

## Files Changed

- Added `server/src/modules/notifications/fcm-token.model.ts`
- Added `server/src/modules/notifications/fcm-token.service.ts`
- Added `lib/core/config/app_config.dart`
- Added `lib/features/notifications/fcm_notification_service.dart`
- Added `lib/features/notifications/data/notification_models.dart`
- Added `lib/features/notifications/data/notification_repository.dart`
- Added `lib/features/notifications/presentation/notification_list_screen.dart`
- Updated `lib/features/auth/application/auth_controller.dart`
- Updated `lib/features/auth/presentation/signed_in_home_screen.dart`
- Updated `server/src/config/firebase.ts`
- Updated `docs/02-architecture/database-model.md`
- Updated `server/src/modules/notifications/notification.schemas.ts`
- Updated `server/src/modules/notifications/notification.controller.ts`
- Updated `server/src/modules/notifications/notification.routes.ts`
- Updated `server/src/modules/notifications/notification.service.ts`
- Updated `docs/02-architecture/api-contract.md`
- Updated `lib/main.dart`
- Updated `android/app/src/main/AndroidManifest.xml`
- Updated `pubspec.yaml`
- Updated `pubspec.lock`
- Updated generated Flutter plugin files
- Updated `test/widget_test.dart`
- Updated `docs/03-flutter-app/flutter-plan.md`

## Verification

- `pnpm typecheck` passed.
- `pnpm build` passed.
- Final `pnpm typecheck` passed.
- Final `pnpm build` passed.
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build apk --debug` passed and produced `build/app/outputs/flutter-apk/app-debug.apk`.
- `flutter analyze` passed after notification history screen integration.
- `flutter test` passed after notification history screen integration.
- `flutter build web` passed after notification history screen integration.
- `flutter build apk --debug` passed after notification history screen integration.
- `pnpm typecheck` passed after notification history screen integration.
- `pnpm build` passed after notification history screen integration.
- `POST /api/notifications/register-token` returned `201` in local API verification.
- FCM token was saved in MongoDB during local API verification.
- Notification history remained saved when push delivery used a fake token and failed.
- Test user and FCM token were removed from local MongoDB after verification.
- Pending real Android device/emulator FCM token registration after auth flow is connected.
- Pending real push delivery test with a valid Android FCM token.

## Notes

- Push notification should be tested on Android emulator or real device.
- Backend should still create notification history even if push delivery fails.
- Backend stores one or more FCM tokens per user through a separate `FcmToken` collection.
- Notification creation now attempts best-effort push delivery after saving history.
- Invalid or unregistered FCM tokens are disabled when Firebase reports them.
- Flutter package install added `firebase_core`, `firebase_messaging`, and `http`.
- `flutter pub add` updated dependencies, but initially reported Windows Developer Mode/symlink support guidance for plugins.
- Analyze/test passed after package and widget test updates.
- Auth controller now calls `registerCurrentToken(authToken)` after login, register, and session restore.
- Flutter notification history screen is implemented.
- Flutter can mark notifications as read.

## Phase A QA - 2026-06-20

- API-level smoke test confirmed `POST /api/notifications/register-token` returns 201 and `GET /api/notifications` returns history records created by booking and invitation.
- Confirmed notification history is still saved when push delivery uses a fake/unregistered token and fails.
- Still pending: real Android emulator/device FCM token registration through the app, and real push delivery to a device.

## Next Action

Manual test notification history from app, then run Android emulator/device FCM token and real push delivery verification.
