# Product Plan

## Product Summary

EventHub is an event discovery and booking app. Users can explore nearby and upcoming events, search and filter by category, view event details, buy tickets, save bookmarks, invite friends, follow organizers, and receive notifications.

The current Flutter project is still a starter template. The Figma folder contains the target UI screens and will be used as the visual reference for the first version.

## Target Users

- Event attendee: searches for events, books tickets, saves events, invites friends.
- Organizer: creates and manages events.
- Admin or teacher test account: verifies CRUD, auth, notifications, and backend deployment.

## Core User Flows

1. First launch
   - Splash screen
   - Onboarding screens
   - Sign in or sign up

2. Authentication
   - Sign up with full name, email, password
   - Sign in with email and password
   - Forgot password
   - Optional verification screen
   - Optional Google login if time allows

3. Event discovery
   - Home screen with current location, search, categories, upcoming events, nearby events
   - See all events
   - Search events
   - Filter by category, date, location, and price range
   - Map view for nearby events

4. Event booking
   - Open event detail
   - Bookmark event
   - Invite friends
   - Share event
   - Buy ticket
   - See booking in My Tickets or My Events tab

5. Organizer CRUD
   - Create event
   - View owned events
   - Update event
   - Delete event
   - Upload event image to Firebase Storage

6. Notification
   - Register FCM token after login
   - Receive push notifications
   - See notification history in the app
   - Accept or reject event invitations

## Required Scope

- Backend API and MongoDB database
- Flutter Android app connected to backend
- CRUD for events
- JWT authentication
- FCM push notification

## Recommended MVP

The first complete version should include:

- Email/password auth
- Event list and event detail
- Event CRUD for organizer
- Image upload for event cover
- Booking creation and cancellation
- Bookmark events
- Notification list and FCM token registration

## Nice-To-Have Scope

- Search and advanced filters
- Map view
- Organizer profile tabs
- Reviews
- Follow organizer
- Invite friends
- Offline cache
- Dark mode
- Multi-language support
- CI/CD build APK
