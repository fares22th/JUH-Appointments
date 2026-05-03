# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Jordan University Hospital (JUH) — Appointment Booking App**
Flutter app (`juh_appointments`) for booking hospital appointments. Supports Arabic (RTL) and English, light/dark themes. Backend is Nhost (subdomain `hdlupyawqibeobhzjlhm`, region `eu-central-1`).

## Common Commands

```bash
# Run app (Android/emulator)
flutter run

# Build APK
flutter build apk --release

# Analyze & lint
flutter analyze

# Run build_runner (after model changes)
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test
flutter test test/widget_test.dart   # single file
```

## Architecture

### State Management — Riverpod
All state uses `StateNotifierProvider` or `ChangeNotifierProvider`. Key providers:

| Provider | File | Purpose |
|---|---|---|
| `authProvider` | `providers/auth_provider.dart` | Wraps Nhost auth; `ChangeNotifier` so GoRouter can listen |
| `authListenable` | same | Singleton `AuthNotifier` passed to `GoRouter.refreshListenable` |
| `pendingSignupProvider` | same | `StateProvider<PendingSignup?>` — carries nationalId + civilRecord between signup steps |
| `profileProvider` | `providers/profile_provider.dart` | Reads from `nhostClient.auth.currentUser` metadata; rebuilds when `authProvider` changes |
| `relativesProvider` | same | `List<Relative>` seeded from `SeedData.defaultRelatives(userId)` |
| `bookingProvider` | `providers/booking_provider.dart` | `BookingDraft` for the multi-step booking wizard |
| `appointmentsProvider` | `providers/appointments_provider.dart` | In-memory `List<Appointment>` |
| `localeProvider` | `providers/locale_provider.dart` | `Locale('ar')` default, persisted to SharedPreferences |
| `themeModeProvider` | `providers/theme_provider.dart` | `ThemeMode.light` default, persisted to SharedPreferences |

### Navigation — GoRouter
Configured in `routes/router.dart`. Auth redirect rules:
- Unauthenticated + protected route → `/welcome`
- Authenticated + auth route → `/home`
- Auth routes set: `{'/welcome', '/login', '/signup', '/contact'}` — **`/login-welcome` is NOT in this set** (it's reachable only after sign-in)

Back navigation: `ScreenHeader` uses `context.canPop() ? context.pop() : context.go('/home')`. Never use `Navigator.maybePop()` — bottom-nav screens don't have a back stack.

### Auth Flow
**Signup:** `SignUpScreen` (nationalId + civilRecord) → saves to `pendingSignupProvider` → `ContactScreen` (name + phone + email + password) → calls `nhostClient.auth.signUp(email: '$nationalId@juh.app', password: ...)` with metadata.

**Login:** `LoginScreen` → `nhostClient.auth.signInEmailPassword(email: '$nationalId@juh.app', password: ...)` → on success: `context.go('/login-welcome')` → user sees their info card → `context.go('/home')`.

**Nhost email pattern:** All users have a synthetic email `{nationalId}@juh.app`. Real contact email is stored in user metadata under `contactEmail`.

**Session restore:** `main.dart` calls `nhostClient.auth.signInWithStoredCredentials()` at startup.

### Booking Wizard (multi-step)
`/relatives?who=` → `/booking?who=&insurance=` → `/calendar?who=` → `/confirm?who=`

`bookingProvider` holds `BookingDraft` across steps. Resetting: `setInsurance` clears spec + doc downstream. `setSpec` clears doc. Route query param `who` identifies self vs relative.

### Bilingual Pattern
Every screen reads `ref.watch(localeProvider).languageCode == 'ar'` as `isAr`. Strings are inlined as `isAr ? 'عربي' : 'English'`. The `BuildContext` extension `.t(ar, en)` in `core/extensions.dart` is an alternative. Text direction on `Row`/containers must be set explicitly: `textDirection: isAr ? TextDirection.rtl : TextDirection.ltr`.

### Database (Nhost/PostgreSQL)
Tables: `profiles`, `insurance_types`, `specialties`, `doctors`, `doctor_insurance`, `doctor_schedules`, `doctor_leaves`, `relatives`, `appointments`.

RLS policies use `public.current_user_id()` (NOT `auth.uid()` — Nhost blocks writes to the `auth` schema). The helper function:
```sql
CREATE OR REPLACE FUNCTION public.current_user_id()
RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT COALESCE(
    current_setting('hasura.user.x-hasura-user-id', true),
    (current_setting('request.jwt.claims', true)::jsonb ->> 'sub')
  )::uuid
$$;
```

Trigger `on_auth_user_created` on `auth.users` calls `public.handle_new_user()` to auto-create the `profiles` row from signup metadata.

### Shared Widgets
- **`ScreenHeader`** — `PreferredSizeWidget` AppBar with bilingual title, back/home logic, optional language toggle
- **`AppButton`** — Primary/outline/ghost variants with loading spinner
- **`JuhFormField`** — `StatefulWidget` with password toggle, validator, helper text
- **`StatusChip`** — Bilingual appointment status badge
- **`SegmentBar`** — Step progress bar (0-indexed) used in signup flow

### Design Tokens (`core/sizes.dart`, `core/colors.dart`)
Use `JuhSizes.*` for spacing/typography/radii and `JuhColors.*` for colors. Never use hardcoded pixel values or raw `Color(0x...)` outside these files.
