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
date
minPrice
maxPrice
lat
lng
page
limit
sort
```

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
POST /api/events/:eventId/reviews
GET  /api/events/:eventId/reviews
```

Create review body:

```json
{
  "rating": 5,
  "comment": "Great event."
}
```

## Users

```text
GET /api/users
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
