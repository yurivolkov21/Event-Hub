# Seed Data Plan

Seed data makes demo and testing faster.

## Goal

Create predictable demo data that matches the EventHub Figma screens.

## Seed Users

Organizer:

```text
Full name: Ashfak Sayem
Email: organizer@eventhub.local
Password: Password123!
Role: organizer
```

User:

```text
Full name: Demo User
Email: user@eventhub.local
Password: Password123!
Role: user
```

Admin:

```text
Full name: Admin User
Email: admin@eventhub.local
Password: Password123!
Role: admin
```

## Seed Categories

- Sports
- Music
- Food
- Art
- Movie
- Concert
- Games Online
- Others

## Seed Events

Create events similar to Figma:

- International Band Music Concert
- A Virtual Evening of Smooth Jazz
- Jo Malone London's Mother's Day Presents
- Women's Leadership Conference
- International Kids Safe Parents Night Out
- International Gala Music Festival

Each event should include:

- Category
- Organizer
- Start and end date
- Venue name
- Address
- Price
- Capacity
- Image URL or local placeholder uploaded during seed

## Seed Bookings

- Demo user books 1 or 2 events.
- Some events have non-zero `bookedCount`.

## Seed Notifications

Create sample notification records:

- Booking confirmed
- Event invitation
- Event updated

## Script Plan

When backend exists, add:

```text
server/src/scripts/seed.ts
```

Run with:

```bash
pnpm seed
```

Expected behavior:

- Connect to MongoDB.
- Clear only seed-owned data if needed.
- Create users, categories, events, bookings, notifications.
- Print demo account credentials.

## Safety

Do not run destructive seed reset on production unless explicitly confirmed.
