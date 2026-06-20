# Demo And Grading Checklist

Use this checklist before final submission or class demo.

## Required Demo Flow

1. Open app on Android.
2. Show splash or onboarding.
3. Register a new user.
4. Login with created user.
5. Login or switch to organizer account.
6. Create an event.
7. Upload an event image.
8. Show event appears in home/list.
9. Open event detail.
10. Update event.
11. Delete or cancel event.
12. Book an event as a user.
13. Show My Tickets or My Bookings.
14. Trigger notification or invitation.
15. Show FCM push notification.
16. Show notification history screen.

## Backend Evidence

- Backend URL: https://eventhub-api-b4yb.onrender.com
- Health endpoint: https://eventhub-api-b4yb.onrender.com/health
- MongoDB database name: eventhub (MongoDB Atlas free cluster)
- Deployment platform: Render (Blueprint web service, free plan, rootDir `server`)
- API collection: see `docs/02-architecture/api-contract.md`
- Production verification (2026-06-20): full demo-flow smoke test passed 25/25 against the live URL + Atlas.

## Demo Accounts

Organizer account:

```text
Email:
Password:
Role: organizer
```

User account:

```text
Email:
Password:
Role: user
```

## Required Requirements

- Server backend and database: ready for manual verification
- CRUD on Android: ready for manual verification
- Authentication: ready for manual verification
- Push notification with FCM: ready for manual verification

## Bonus Checklist

- Image upload from device
- Search events
- Filter by category/date/location/price
- Pagination or load more
- Bookmark events
- Deploy backend: done (Render + MongoDB Atlas, https://eventhub-api-b4yb.onrender.com)
- Basic test: implemented with `server/tests/app.test.js`
- CI/CD build APK

## Final Submission Items

- Git repository link
- APK file
- Backend live URL
- MongoDB Atlas or database proof
- Firebase project configured
- Demo account credentials
- Setup guide
- Short demo video if required
