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

## Next Action

Connect auth UI/API flow so Flutter can call `registerCurrentToken(authToken)` after login, then test real push delivery on Android.
