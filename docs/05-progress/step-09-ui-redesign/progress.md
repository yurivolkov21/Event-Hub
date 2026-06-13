# Step 09 - UI Redesign From Figma

Status: First UI pass complete

## Goal

Move the Flutter UI from a plain functional prototype toward the EventHub Figma visual direction.

## Scope

- App-wide EventHub theme.
- Signed-in dashboard polish.
- Event list redesign.
- Event detail redesign.
- Keep existing API/data flows intact.

## Planned Deliverables

- Theme constants and Material theme.
- Figma-inspired event list header, search bar, category chips, and event cards.
- Figma-inspired event detail hero image, overlay actions, info rows, organizer area, and bottom booking action.
- Updated progress documentation.

## Files Changed

- Added `lib/core/theme/eventhub_theme.dart`
- Updated `lib/main.dart`
- Updated `lib/features/auth/presentation/auth_screen.dart`
- Updated `lib/features/auth/presentation/signed_in_home_screen.dart`
- Updated `lib/features/events/data/event_repository.dart`
- Updated `lib/features/events/presentation/event_list_screen.dart`
- Updated `lib/features/events/presentation/event_detail_screen.dart`
- Updated `docs/01-planning/implementation-roadmap.md`
- Updated `docs/05-progress/README.md`

## Verification

- `dart format lib docs` passed.
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.
- `flutter build apk --debug` passed and produced `build/app/outputs/flutter-apk/app-debug.apk`.

## Notes

- The first UI pass focuses on the screens users see most often.
- Auth, signed-in dashboard, event list, and event detail now follow the EventHub Figma direction more closely.
- Tickets, notifications, invite friend, and event forms can receive a second visual polish pass after this one.
- Category chips on event list now use the existing backend category filter.
- `flutter build apk --debug` currently passes with a `share_plus` Kotlin Gradle Plugin future-compatibility warning. It does not block the debug build.

## Next Action

Manual UI QA on Chrome or Android emulator, then polish tickets, notifications, invite friend, and event forms.
