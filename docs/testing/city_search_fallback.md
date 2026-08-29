# City Search Fallback manual test

## Automated gate

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator --debug
```

## Offline catalog

1. Start CityGuide and deny location permission.
2. Tap **Choose a city instead**.
3. Enable airplane mode after the city screen opens.
4. Verify the screen lists exactly 27 governorate capitals.
5. Search `Cairo`, `القاهره`, `Dakahlia`, and `الدقهلية`.
6. Verify Cairo matches the first two and Mansoura matches the latter two.
7. Select Cairo. Verify Explorer receives a `SearchCenter` labelled Cairo.
8. Return to city search or restart the app. Verify Cairo appears under
   **Recent**.

## Remote fallback

Remote testing requires all of the following:

- Supabase anonymous sign-ins enabled.
- `geocode-city` deployed with in-function Supabase user-JWT validation.
- `GOOGLE_PLACES_API_KEY` stored directly as a Supabase project secret.
- Geocoding API enabled for that server key.

With network restored:

1. Search for an Egyptian city that is not a governorate capital, such as
   `Zamalek`.
2. Verify no network request occurs while typing and an offline empty state is
   shown first.
3. Tap **Search online for Zamalek**.
4. Verify one authenticated `geocode-city` request occurs.
5. Select the returned result and verify Explorer receives its persisted
   `SearchCenter`.
6. Search for an invalid or non-Egyptian place and verify a friendly not-found
   response.
7. Disconnect the network before explicit online search and verify a friendly
   retryable error.

Quota, timeout, missing-session, DTO parsing, English/Arabic matching, and
persistence behavior are covered by automated tests. Review Supabase function
logs without logging full queries or user-location histories.
