# Health Minister Application - Mobile

This repository contains the official Flutter application for the Health Minister project. It now includes Firebase Cloud Messaging (FCM) wiring for push notifications outside the app, plus backend token registration support.

## Key Functionalities
- Official branding and Ministry of Health UI styling
- Guest access and authenticated user flows
- Clinic discovery and health learning content
- In-app notification center backed by local storage
- FCM push notifications for Android and iOS when the app is backgrounded or closed

## FCM Setup
1. Create Android and iOS apps for this project in Firebase.
2. Enable Firebase Cloud Messaging in the Firebase console.
3. Start the backend with Firebase Admin credentials configured in [backend/api/.env.example](../backend/api/.env.example).
4. Run the mobile app with the Firebase client values supplied through `--dart-define`:

```bash
flutter run \
  --dart-define=FIREBASE_PROJECT_ID=your-project-id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your-project-id.firebasestorage.app \
  --dart-define=FIREBASE_ANDROID_API_KEY=your-android-api-key \
  --dart-define=FIREBASE_ANDROID_APP_ID=your-android-app-id \
  --dart-define=FIREBASE_ANDROID_MESSAGING_SENDER_ID=your-sender-id \
  --dart-define=FIREBASE_IOS_API_KEY=your-ios-api-key \
  --dart-define=FIREBASE_IOS_APP_ID=your-ios-app-id \
  --dart-define=FIREBASE_IOS_MESSAGING_SENDER_ID=your-sender-id \
  --dart-define=FIREBASE_IOS_BUNDLE_ID=your.ios.bundle.id
```

## iOS Follow-up
- Open `ios/Runner.xcworkspace` in Xcode.
- Enable the `Push Notifications` capability.
- Enable `Background Modes`, then turn on `Remote notifications` and `Background fetch`.
- Upload your APNs authentication key or certificate in Firebase Console > Project Settings > Cloud Messaging.

## Android Follow-up
- Android 13+ requires the runtime notification permission. The app now requests this when the user enables push notifications or signs in.
- The default FCM notification channel ID is `high_importance_channel`.

## How to Run
1. Ensure you are on the `main` branch.
2. Run `flutter pub get` to install dependencies.
3. Supply the Firebase `--dart-define` values shown above.
4. Run `flutter run` on your preferred device.

## Notes
- The profile notification settings screen now includes a `Push Notifications` toggle that registers or unregisters the current device with the backend.
- New published learning modules can trigger real push notifications through the backend notification automation hook.
- On Windows, Flutter plugin builds require Developer Mode because the toolchain uses symlinks.
