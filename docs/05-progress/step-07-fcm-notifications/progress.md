# Step 07 - FCM Notifications

Status: Not started

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

- Pending

## Verification

- Pending

## Notes

- Push notification should be tested on Android emulator or real device.
- Backend should still create notification history even if push delivery fails.

## Next Action

Configure Firebase for Android app and backend.
