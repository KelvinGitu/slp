# SolarTide

Solar installation quotes for installers in Kenya, on Android, iOS and the web.

- **Clients:** keep everyone you quote for in one place, with a call or WhatsApp button.
- **Sizing:** enter the appliances or the monthly units and the county. SolarTide suggests the number of panels, the inverter and the battery bank, using NASA POWER sun data.
- **Quotes:** go through the components of an installation, with each price taken from your own price catalogue. Totals include markup and 16% VAT.
- **PDFs:** a quote for the client with your logo, KRA PIN and M-Pesa or bank details, plus a components list for the crew. Share either by WhatsApp or email, or print it.
- **Dashboard:** drafts, sent, accepted and installed quotes, and what you've won this month.

## Setup

Requirements: Flutter 3.41 or later (Dart 3.11) and the Firebase CLI.

1. Install the packages:
   ```
   flutter pub get
   ```
2. Connect Firebase. The app IDs changed to `com.solartide.app` in 2026, so register them in the existing project:
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure --project=solar-project-6a8a9 --platforms=android,ios,web
   ```
   This regenerates `lib/firebase_options.dart`, `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.
3. In the Firebase console:
   - Enable **Authentication > Email/Password**.
   - Enable **Storage**.
4. Deploy the security rules:
   ```
   firebase deploy --only firestore:rules,storage
   ```
5. Let the web app load logos from Storage (one time):
   ```
   gsutil cors set storage-cors.json gs://solar-project-6a8a9.appspot.com
   ```

A new account is taken through business setup. Setup also loads the starting price catalogue, which you can edit in Settings > Price catalogue.

## Run
```
flutter run                 # phone or emulator
flutter run -d chrome       # browser
flutter analyze && flutter test
```

## Release
- **Android:**
  - Copy `android/key.properties.example` to `android/key.properties` and fill it in.
  - Run `flutter build appbundle`.
  - Release builds refuse to build without signing or Firebase config.
- **Web:**
  - Pushes to `master` deploy to Firebase Hosting (`.github/workflows/firebase-hosting.yml`).
  - The workflow needs the repository secret `FIREBASE_SERVICE_ACCOUNT_SOLAR_PROJECT`; `firebase init hosting:github` creates it.
  - To deploy by hand: `flutter build web && firebase deploy --only hosting`.

See `CLAUDE.md` for the architecture and conventions.
