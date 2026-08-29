# Explorer Map manual test

## Automated gate

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator --debug
```

## Required private files

Android:

```properties
# secrets.properties
MAPS_API_KEY=YOUR_RESTRICTED_ANDROID_MAPS_KEY
```

iOS:

```text
// ios/Flutter/Secrets.xcconfig
MAPS_API_KEY=YOUR_RESTRICTED_IOS_MAPS_KEY
```

Both files are ignored by Git. Never add the server-side Google Places key to
either file; it remains only in Supabase as `GOOGLE_PLACES_API_KEY`.

## Nearby proxy prerequisites

- Supabase anonymous sign-ins enabled.
- `places-nearby` deployed with in-function user-JWT validation.
- `GOOGLE_PLACES_API_KEY` present in Supabase Edge Function secrets.
- Places API (New) enabled for the server key.

## Android and iOS manual matrix

1. Start CityGuide and grant location, or choose Cairo from City Search.
2. Verify Explorer shows a Google map centered on the chosen search center.
3. Verify one nearby request runs on entry with category `cafe`, radius 3000 m,
   and maximum 20 results.
4. Verify cafe markers appear and the first result is shown in the bottom
   preview card.
5. Tap another marker and verify the selected preview changes without another
   nearby request.
6. Pan and zoom repeatedly. Verify no new nearby request is made.
7. Tap the Explorer search control and verify City Search opens.
8. Test a center with no cafe results and verify the friendly empty overlay.
9. Disconnect the network before opening Explorer and verify the friendly
   retryable error state.
10. Restore the network, tap **Try again**, and verify results return.

## Google Cloud verification

After one successful live test, open Google Cloud Console and verify:

- Maps SDK for Android requests use only the restricted Android key.
- Maps SDK for iOS requests use only the restricted iOS key.
- Nearby Search (New) requests use only the server key stored in Supabase.
- The result count never exceeds 20.
- No request is sent for camera movement.
