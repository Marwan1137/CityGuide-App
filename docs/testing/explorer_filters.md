# Explorer category and distance filters manual test

## Automated gate

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator --debug
```

## Filter matrix

Test each category with at least one distance:

- Cafe
- Restaurant
- Pharmacy
- 1 km
- 3 km
- 5 km
- 10 km

## Android and iOS manual test

1. Enter Explorer using device location or Cairo.
2. Open the filter sheet from the map.
3. Select **Restaurant** and verify exactly one refresh occurs.
4. Verify map markers and list cards contain the same restaurant IDs/count.
5. Open filters and select **5 km**; verify exactly one refresh occurs.
6. Select the already active **5 km** option and verify no refresh occurs.
7. Switch between map and list; verify no extra request occurs.
8. Repeat with **Pharmacy** and **1 km**.
9. Verify an empty result shows a suggestion to widen distance, change
   category, or choose another city.
10. Tap **Reset** and verify filters return to **Cafe** and **3 km** with one
    request.
11. Restart the app and verify the last accepted filters are restored.

## Server validation

The authenticated `places-nearby` function must:

- accept only `cafe`, `restaurant`, and `pharmacy`;
- accept only 1000, 3000, 5000, and 10000 meters;
- reject unsupported values with stable `invalid_category` or
  `invalid_radius` errors;
- return no more than 20 places;
- calculate geodesic distance without logging coordinates or secrets.
