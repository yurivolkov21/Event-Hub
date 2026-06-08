# EventHub Documentation

Created: 2026-06-07

This folder stores the planning notes, architecture decisions, and step-by-step progress logs for the EventHub Flutter Android app.

## Final Stack

- Mobile app: Flutter Android
- Backend: Node.js, Express, TypeScript
- Package manager: pnpm
- Database: MongoDB with Mongoose
- Authentication: JWT with bcrypt-compatible password hashing via bcryptjs
- Image storage: Cloudinary
- Push notification: Firebase Cloud Messaging through Firebase Admin SDK

## Docs Map

- [Product Plan](01-planning/product-plan.md)
- [Pages And Features](01-planning/pages-and-features.md)
- [Implementation Roadmap](01-planning/implementation-roadmap.md)
- [Definition Of Done](01-planning/definition-of-done.md)
- [Demo And Grading Checklist](01-planning/demo-grading-checklist.md)
- [Design Reference](01-planning/design-reference.md)
- [Scope Control](01-planning/scope-control.md)
- [System Architecture](02-architecture/system-architecture.md)
- [Database Model](02-architecture/database-model.md)
- [API Contract](02-architecture/api-contract.md)
- [API Error Convention](02-architecture/api-error-convention.md)
- [Environment And Secrets](02-architecture/environment-and-secrets.md)
- [Seed Data Plan](02-architecture/seed-data-plan.md)
- [Flutter App Plan](03-flutter-app/flutter-plan.md)
- [Backend Plan](04-backend-server/backend-plan.md)
- [Progress Tracker](05-progress/README.md)

## Progress Rules

Each implementation step has its own folder under `05-progress/`.

Every step should track:

- Status: not started, in progress, done, blocked
- Goal
- Scope
- Files changed
- Verification
- Notes and decisions
- Next action

## Project Requirements

The project must satisfy these 4 core requirements:

- Server backend and database
- CRUD on Android app
- Authentication
- Push notification with FCM

Optional scoring features are tracked in the roadmap, especially image upload, search/filter, pagination, offline cache, deploy, tests, and CI/CD.
