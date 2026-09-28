# SolarTide

Quotation app for solar installers in Kenya. An installer adds a client, optionally sizes the system, goes through the components of an installation, and sends the client a priced PDF quote. Everything is in KES. One Flutter app for phones and the browser.

Visual source of truth: the Guard Monitor `STYLE_GUIDE.md` (kept in `lisabem_security_app/docs/`). Its tokens, palette, type and components apply as-is. The guard-specific parts (panic button, alert banner, guard statuses, map) don't apply.

## Stack
The stack follows `lisabem_security_app` / `small_biz_tool` / `global-events-tracker`:

- **Riverpod 2**, hand-written providers. Controllers are `StateNotifierProvider<XController, bool>` loading flags that fold results into snackbars. There is no code generation.
- **Routemaster**, with one `RouteMap` per `RouteStage` (`resolving`, `signedOut`, `setup`, `signedIn`) in `lib/routes.dart`. Tabs are not routes; the current tab lives in `appTabProvider`.
- **fpdart**: repositories return `FutureEither<T>` / `FutureVoid` with a `Failure(message)`.
- **Firebase**:
  - Auth: email and password; installers sign themselves up.
  - Firestore: everything lives under `users/{uid}`.
  - Storage: logos.
- **Models** are hand-written, with `fromMap`/`toMap`/`copyWith` and tolerant parsers from `core/utils/firestore_json.dart`.
- **Icons**: `phosphor_flutter`.

## Layout
```
lib/core/      theme/, widgets/ (style-guide components), providers/, utils/, enums/, constants/, error/
lib/features/  <feature>/{controller,repository,providers,logic,data,views/{screens,widgets}}
lib/models/    shared data models
```
Feature folders are `auth`, `business`, `catalogue`, `clients`, `quotes`, `documents` (the PDFs), `sizing`, `home` (the shell, dashboard and `AppNav`) and `settings`.

## How quotes work
- **The catalogue** (`users/{uid}/catalogue`) holds each installer's own price list. It is seeded from `features/catalogue/data/default_catalogue.dart`.
- **Component kinds.** Every item has a `ComponentKind`: `fixed`, `quantity`, `length`, `choice`, `multi` or `custom`. These six kinds replace the 46 hand-written pages the 2024 app had. `LineEditor` picks the right fields for each kind.
- **Quotes** (`users/{uid}/quotes`) carry every line with its price frozen at edit time, plus stored totals.
- **All arithmetic** lives in `features/quotes/logic/quote_calculator.dart`, which is pure and unit-tested. Never compute money in a widget.
  - Markup is applied to cost.
  - VAT is charged on cost plus markup.
  - The client PDF spreads the markup across the lines (`sellingTotals`).
- **Quote numbers** (`ST-2026-0007`) are allocated in a transaction on the business profile and restart every January.
- **Sizing** (`features/sizing/logic/sizing_calculator.dart`) gets peak sun hours from NASA POWER, with a 5.0 fallback. It picks catalogue items by their `SizingRole`, not by name.

## UI rules (STYLE_GUIDE §12)
- **Tokens only.** Colours, radii, spacing, sizes and durations come from `lib/core/theme/`. No hex values or magic numbers in widgets. Read colours with `context.palette`.
- **One mint `PrimaryButton` per screen.** `AppColors.danger` is for real errors only.
- **Status** is always shown as icon, word and colour together. `QuoteStatus` and `LineState` implement `StatusStyle`.
- **Copy** uses sentence case, second person and no exclamation marks. Money reads "KES 125,000"; dates read "20 April 2026".
- **Layout:**
  - Every screen must survive a 1.5 text scale at 360 px wide, and must also work at 1280 px.
  - Use `context.isWide`; don't compare widths yourself.
  - On wide layouts, `AppNav` fills the detail panel instead of pushing a page.

## Running
```
flutter run                    # Android/iOS
flutter run -d chrome          # browser
flutter analyze && flutter test
```
- **Firebase project:** `solar-project-6a8a9`.
- **Emulators:** `--dart-define=USE_EMULATORS=true` targets `firebase emulators:start` (Auth 9099, Firestore 8080, Storage 9199). The Firestore and Storage emulators need Java.
- **Widget tests** override `firebaseReadyProvider` to false; see `test/helpers/pump.dart`. `test/features/screens_test.dart` renders every screen in the style-guide variants. Add new screens to it.
