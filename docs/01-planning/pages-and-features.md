# Pages And Features

## Figma Screens Found

The folder `Event Booking App- EventHub/` contains these design screens:

- Splash Screen
- Onboarding 1
- Onboarding 2
- Onboarding 3
- Sign in
- Sign up
- Resset Password
- Verification
- Home
- Search- White Bar
- Filter
- See All Events
- Map View
- Event Details
- Invite Friend v1
- Share
- Notification
- Empty Notification
- My Profile
- Menu White
- Organizer Profile- About
- Organizer Profile- Event
- Organizer Profile- Review
- Empty Events

## Page Groups

### Launch And Auth

- Splash screen
- Onboarding carousel
- Sign in
- Sign up
- Reset password
- Verification

### Main App

- Home or Explore
- Event list
- Search
- Filter bottom sheet
- Map view
- Event detail
- Notifications
- Profile
- Drawer menu

### Social And Event Actions

- Invite friend bottom sheet
- Share bottom sheet
- Bookmark event
- Follow organizer
- Organizer profile
- Reviews

### Empty States

- Empty notification
- Empty upcoming events

## Missing Pages To Add

The Figma screens mostly cover attendee flows. To satisfy CRUD clearly, add these implementation screens:

- Organizer Dashboard
- My Created Events
- Create Event
- Edit Event
- Event Management Detail
- Delete Event Confirmation
- My Tickets
- Booking Confirmation
- Edit Profile
- Settings

## Bottom Navigation Proposal

- Explore
- Events or Tickets
- Add Event
- Map
- Profile

## Drawer Menu Proposal

- My Profile
- Messages
- Calendar
- Bookmark
- Contact Us
- Settings
- Help and FAQs
- Sign Out

## CRUD Mapping

Primary CRUD entity: Event

- Create: organizer creates an event
- Read: all users read event lists and details
- Update: organizer edits own event
- Delete: organizer deletes own event

Secondary CRUD-like actions:

- User updates profile
- User creates or removes bookmark
- User creates or cancels booking
- User creates review
- User accepts or rejects invitation

## Feature Priority

Must have:

- Auth
- Event list
- Event detail
- Event CRUD
- Booking
- Image upload
- FCM token registration
- Notification history

Should have:

- Search
- Filter
- Bookmark
- Organizer profile
- Invite friend

Could have:

- Map view
- Reviews
- Follow organizer
- Offline cache
- Dark mode
