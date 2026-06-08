# Step 03 - Authentication

Status: Done

## Goal

Implement email and password authentication.

## Scope

- User model.
- Register route.
- Login route.
- JWT utility.
- Auth middleware.
- Current user route.
- Flutter sign in and sign up API integration.

## Planned Deliverables

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- Protected route support
- JWT stored in Flutter secure storage

## Files Changed

- Added `server/src/modules/users/user.model.ts`
- Added `server/src/modules/users/user.dto.ts`
- Added `server/src/modules/auth/auth.schemas.ts`
- Added `server/src/modules/auth/auth.service.ts`
- Added `server/src/modules/auth/auth.controller.ts`
- Added `server/src/modules/auth/auth.routes.ts`
- Added `server/src/middlewares/auth.middleware.ts`
- Added `server/src/types/express.d.ts`
- Added `server/src/utils/password.ts`
- Added `server/src/utils/jwt.ts`
- Added `lib/core/networking/api_client.dart`
- Added `lib/core/storage/session_storage.dart`
- Added `lib/features/auth/data/auth_models.dart`
- Added `lib/features/auth/data/auth_repository.dart`
- Added `lib/features/auth/application/auth_controller.dart`
- Added `lib/features/auth/presentation/auth_screen.dart`
- Added `lib/features/auth/presentation/signed_in_home_screen.dart`
- Updated `lib/main.dart`
- Updated `pubspec.yaml`
- Updated `pubspec.lock`
- Updated generated Flutter plugin files
- Updated `test/widget_test.dart`
- Updated `server/src/app.ts`
- Updated `server/package.json`
- Updated `server/pnpm-lock.yaml`

## Verification

- `pnpm typecheck` passed.
- `pnpm build` passed.
- `POST /api/auth/register` returned `201` with JWT and public user payload.
- Duplicate `POST /api/auth/register` returned `409`.
- `POST /api/auth/login` returned `200` with JWT and public user payload.
- `GET /api/auth/me` with bearer token returned `200`.
- `GET /api/auth/me` without token returned `401`.
- Test user created for verification was removed from local MongoDB after the check.
- `flutter analyze` passed after Flutter auth integration.
- `flutter test` passed after Flutter auth integration.
- `flutter build apk --debug` passed after Flutter auth integration.
- `pnpm typecheck` passed after Flutter auth integration.
- `pnpm build` passed after Flutter auth integration.

## Notes

- Uses `bcryptjs` for bcrypt-compatible password hashing, avoiding native build approval issues with pnpm.
- Optional verification and social login can be added later.
- Register currently allows `user` and `organizer` roles so the app can demo organizer CRUD.
- `admin` is reserved for seed data or manual setup, not public registration.
- Flutter now has sign-in and sign-up forms connected through an auth repository/controller layer.
- JWT and user summary are stored through `flutter_secure_storage`.
- On app start, Flutter restores the saved JWT and validates it through `GET /api/auth/me`.
- After login/register/session restore, Flutter attempts FCM token registration without blocking auth.

## Next Action

Connect Flutter event list/detail screens to the existing Events API, then add organizer create/edit forms.
