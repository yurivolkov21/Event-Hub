# Design Reference

The current Figma export folder is:

```text
Event Booking App- EventHub/
```

This folder is used as the visual reference for the Flutter UI.

## Current Decision

Keep the design folder in the project root for now.

Reason:

- The folder is already staged in Git.
- Moving many image files before coding can make the first commit harder to review.
- The folder name clearly identifies the design source.

## Optional Future Cleanup

If we want a cleaner documentation layout later, move it to:

```text
docs/design/eventhub-figma/
```

If that move happens, update:

- `docs/01-planning/pages-and-features.md`
- `docs/03-flutter-app/flutter-plan.md`
- Any README references

## Design Usage Rules

- Use Figma images as UI reference, not as final app screenshots.
- Avoid hardcoding text exactly when it is lorem ipsum.
- Keep EventHub visual language: blue-purple primary color, colorful category chips, image-first event cards.
- Add missing CRUD screens using the same visual style.
- Android layout can adapt from iOS-looking mockups.
