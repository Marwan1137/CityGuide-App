# Location Permission Matrix manual test

Use a disposable emulator or simulator. The commands below reset only the
CityGuide app or its permission state.

## Automated gate

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator --debug
```

## Android

Start from a clean app state:

```bash
adb shell pm clear com.marwanheikal.cityguide
flutter run -d <android-device-id>
```

Verify these cases:

1. First launch shows “Discover what is nearby” without opening the system
   prompt automatically.
2. Tap **Use my location**, choose **While using the app**, and verify a
   successful location result.
3. Reset the app, tap **Use my location**, deny once, and verify the recoverable
   denied screen plus **Choose a city instead**.
4. Request again and choose **Don’t ask again** when available, or deny until
   Android reports the permission permanently denied. Verify **Open app
   Settings**.
5. From app Settings, allow location and return to CityGuide. Verify that the
   screen rechecks automatically without relaunching.
6. On Android 12+, reset and choose **Approximate** instead of **Precise**.
   Verify the reduced-accuracy screen and that continuing still works.
7. Turn device Location off. Verify **Turn on Location Services**, open location
   Settings, turn it on, and return. The app must recover automatically.
8. Remove or disable the emulator’s simulated GPS fix for at least 12 seconds.
   Verify **Location took too long**, then restore a fix and retry.

Useful reset commands:

```bash
adb shell pm revoke com.marwanheikal.cityguide android.permission.ACCESS_FINE_LOCATION
adb shell pm revoke com.marwanheikal.cityguide android.permission.ACCESS_COARSE_LOCATION
adb shell pm clear com.marwanheikal.cityguide
```

`pm clear` removes CityGuide’s local first-request marker as well as its Android
permission state. It does not affect another app.

## iOS

Boot a Simulator, then reset CityGuide’s permission state:

```bash
xcrun simctl privacy booted reset all com.marwanheikal.cityguide
flutter run -d <ios-simulator-id>
```

Verify these cases:

1. First launch shows the rationale without opening the iOS prompt.
2. Tap **Use my location** and choose **Allow While Using App**. CityGuide must
   never request background or always-on access.
3. Reset, request again, and choose **Don’t Allow**. Verify the unavailable
   screen and city-search fallback.
4. Tap **Open app Settings**, change Location to **While Using the App**, and
   return. Verify automatic lifecycle recheck.
5. In Settings, turn **Precise Location** off. Return and verify the
   reduced-accuracy outcome. Tap **Improve accuracy in Settings**, turn it on,
   and return.
6. Turn global Location Services off under **Privacy & Security → Location
   Services**. Verify the services-disabled recovery flow, then turn it on and
   return.
7. Set Simulator location to **None** long enough to exceed 12 seconds. Verify
   the timeout screen and retry action.

Useful Simulator commands:

```bash
xcrun simctl privacy booted deny location com.marwanheikal.cityguide
xcrun simctl privacy booted grant location com.marwanheikal.cityguide
xcrun simctl privacy booted reset all com.marwanheikal.cityguide
```

## Acceptance record

Record the Android device/emulator model and Android version, plus the iOS
device/simulator model and iOS version. Mark every row as passed before merging
Feature 1 into `Development`.
