# Explorer map and list synchronization manual test

## Automated gate

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator --debug
```

## Android and iOS manual test

1. Start CityGuide and grant location, or select Cairo through City Search.
2. Wait for Explorer to load nearby cafes.
3. Record the visible result count and a few place names on the map.
4. Tap the list control on the right side of the map.
5. Verify the list count and place names match the map results.
6. Scroll down the list, switch to the map, then return to the list.
7. Verify the list returns to the preserved scroll position.
8. Tap a place card that is not currently selected.
9. Verify Explorer returns to the map, focuses that place, and shows the same
   place in the quick-preview card.
10. Tap a different marker and switch to the list.
11. Verify the matching list card is selected.
12. Pan or zoom, switch between map and list repeatedly, and verify:
    - the search center and zoom are preserved;
    - the selected place is preserved;
    - result IDs and count do not change;
    - no loading state or new nearby request occurs.

## Expected ownership

One `ExplorerCubit` owns `allPlaces`, `filteredPlaces`, `selectedPlaceId`,
`viewMode`, `searchCenter`, `zoom`, and `listScrollOffset`. Switching views and
selecting places are local state changes and must not call the repository.
