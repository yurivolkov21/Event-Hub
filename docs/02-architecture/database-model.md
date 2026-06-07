# Database Model

Database: MongoDB

ODM: Mongoose

## User

```ts
{
  _id: ObjectId,
  fullName: string,
  email: string,
  passwordHash: string,
  role: "user" | "organizer" | "admin",
  avatarUrl?: string,
  phone?: string,
  bio?: string,
  interests: string[],
  createdAt: Date,
  updatedAt: Date
}
```

Indexes:

- unique `email`
- optional text index on `fullName`

## Category

```ts
{
  _id: ObjectId,
  name: string,
  icon?: string,
  color?: string,
  createdAt: Date,
  updatedAt: Date
}
```

## Event

```ts
{
  _id: ObjectId,
  title: string,
  description: string,
  categoryId: ObjectId,
  organizerId: ObjectId,
  imageUrl?: string,
  startAt: Date,
  endAt: Date,
  venueName: string,
  address: string,
  city?: string,
  country?: string,
  latitude?: number,
  longitude?: number,
  price: number,
  capacity: number,
  bookedCount: number,
  status: "draft" | "published" | "cancelled",
  createdAt: Date,
  updatedAt: Date
}
```

Indexes:

- text index on `title`, `description`, `venueName`, `address`
- index on `categoryId`
- index on `organizerId`
- index on `startAt`
- optional 2dsphere index if map search is implemented

## Booking

```ts
{
  _id: ObjectId,
  userId: ObjectId,
  eventId: ObjectId,
  quantity: number,
  totalPrice: number,
  status: "confirmed" | "cancelled",
  createdAt: Date,
  updatedAt: Date
}
```

Rules:

- User cannot book cancelled events.
- Booking quantity must not exceed remaining capacity.
- Cancelling booking should reduce booked count.

## Bookmark

```ts
{
  _id: ObjectId,
  userId: ObjectId,
  eventId: ObjectId,
  createdAt: Date
}
```

Indexes:

- unique compound index on `userId` and `eventId`

## Review

```ts
{
  _id: ObjectId,
  userId: ObjectId,
  organizerId?: ObjectId,
  eventId?: ObjectId,
  rating: number,
  comment: string,
  createdAt: Date,
  updatedAt: Date
}
```

Rules:

- Rating should be from 1 to 5.
- User should review only booked or attended events if time allows.

## FcmToken

```ts
{
  _id: ObjectId,
  userId: ObjectId,
  token: string,
  platform: "android",
  lastUsedAt: Date,
  createdAt: Date,
  updatedAt: Date
}
```

Indexes:

- unique `token`
- index on `userId`

## Notification

```ts
{
  _id: ObjectId,
  userId: ObjectId,
  type: "invite" | "booking" | "event_update" | "event_cancelled" | "follow" | "review",
  title: string,
  body: string,
  data?: Record<string, string>,
  readAt?: Date,
  createdAt: Date
}
```

## Invitation

```ts
{
  _id: ObjectId,
  eventId: ObjectId,
  fromUserId: ObjectId,
  toUserId: ObjectId,
  status: "pending" | "accepted" | "rejected",
  createdAt: Date,
  updatedAt: Date
}
```

## Follow

```ts
{
  _id: ObjectId,
  followerId: ObjectId,
  followingId: ObjectId,
  createdAt: Date
}
```

Indexes:

- unique compound index on `followerId` and `followingId`
