# API Contract

Base path: `/api`

Auth header for protected routes:

```text
Authorization: Bearer <jwt>
```

## Health

```text
GET /health
```

Response:

```json
{
  "status": "ok"
}
```

## Auth

```text
POST /api/auth/register
POST /api/auth/login
GET  /api/auth/me
POST /api/auth/forgot-password
```

Register body:

```json
{
  "fullName": "Ashfak Sayem",
  "email": "ashfak@example.com",
  "password": "password123"
}
```

Login body:

```json
{
  "email": "ashfak@example.com",
  "password": "password123"
}
```

Auth response:

```json
{
  "token": "jwt-token",
  "user": {
    "id": "user-id",
    "fullName": "Ashfak Sayem",
    "email": "ashfak@example.com",
    "role": "user"
  }
}
```

## Events

```text
GET    /api/events
GET    /api/events/:id
POST   /api/events
PUT    /api/events/:id
DELETE /api/events/:id
```

List query params:

```text
search
categoryId
organizerId
date
minPrice
maxPrice
lat
lng
page
limit
sort
```

`organizerId` filters events by their owner (used by the Organizer Profile "Events" tab).

Create event body can be JSON or multipart form data if uploading image.

Multipart image field name:

```text
image
```

```json
{
  "title": "International Band Music Concert",
  "description": "Enjoy your favorite live music event.",
  "categoryId": "category-id",
  "startAt": "2026-07-10T09:00:00.000Z",
  "endAt": "2026-07-10T12:00:00.000Z",
  "venueName": "Gala Convention Center",
  "address": "36 Guild Street London, UK",
  "price": 120,
  "capacity": 200
}
```

## Bookings

```text
POST   /api/bookings
GET    /api/bookings/me
DELETE /api/bookings/:id
```

Create booking body:

```json
{
  "eventId": "event-id",
  "quantity": 1
}
```

## Bookmarks

```text
POST   /api/bookmarks/:eventId
GET    /api/bookmarks/me
DELETE /api/bookmarks/:eventId
```

## Notifications

```text
POST /api/notifications/register-token
GET  /api/notifications
PUT  /api/notifications/:id/read
```

`POST /api/notifications/register-token` stores the current device token for FCM. Notification history list/read is available through the same module.

**Notification triggers** (each creates a history row and sends an FCM push):

| Type | Recipient | When |
| ------ | ----------- | ------ |
| `booking` | the booker | a booking is confirmed |
| `event_created` | the organizer | they publish an event |
| `event_update` | confirmed attendees | the organizer edits the event |
| `event_cancelled` | confirmed attendees | the organizer deletes/cancels the event |
| `invite` | the invited user | an organizer/user invites them to an event |
| `invite_response` | the inviter | the invitee accepts or rejects |

Notifications carry an `eventId` in `data`, so tapping one deep-links to the event.

Register FCM token body:

```json
{
  "token": "fcm-token",
  "platform": "android",
  "appVersion": "1.0.0"
}
```

## Invitations

```text
POST /api/events/:eventId/invitations
GET  /api/invitations/me
PUT  /api/invitations/:id/accept
PUT  /api/invitations/:id/reject
```

Create invitation body:

```json
{
  "userIds": ["user-id-1", "user-id-2"]
}
```

## Reviews

```text
GET  /api/events/:eventId/reviews
GET  /api/events/:eventId/reviews/eligibility   (auth)
POST /api/events/:eventId/reviews               (auth)
```

Create review body:

```json
{
  "rating": 5,
  "comment": "Great event."
}
```

**Review rules (enforced server-side and surfaced in the UI):**

- An organizer cannot review their own event.
- A user can only review an event they have a `confirmed` booking for.

`GET .../reviews/eligibility` returns whether the current user may review, so the
app can hide the "Write a review" button and show the reason:

```json
{ "canReview": false, "reason": "You can only review events you have booked." }
```

## Users

```text
GET /api/users                  (auth) — list/search users
GET /api/users/:id              — public profile
GET /api/users/:id/reviews      — reviews across that organizer's events
PUT /api/users/me               (auth) — update own profile
```

`GET /api/users/:id` and `/:id/reviews` back the Organizer Profile screen.
`PUT /api/users/me` updates the signed-in user's profile.

Update profile body (all fields optional):

```json
{
  "fullName": "Ashfak Sayem",
  "phone": "+1 555 0100",
  "bio": "Event lover",
  "interests": ["Music", "Sports"]
}
```

List users is protected and is currently used by the Invite Friend flow.

Query params:

```text
search
role
limit
```

Response:

```json
{
  "data": [
    {
      "id": "user-id",
      "fullName": "Ashfak Sayem",
      "email": "ashfak@example.com",
      "role": "user",
      "avatarUrl": null,
      "phone": null,
      "bio": null,
      "interests": []
    }
  ]
}
```

## Error Response

```json
{
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Email is invalid"
    }
  ]
}
```
