enum PlaceCategory {
  cafe,
  restaurant,
  pharmacy,
  custom;

  String get label => switch (this) {
    cafe => 'Cafe',
    restaurant => 'Restaurant',
    pharmacy => 'Pharmacy',
    custom => 'Custom',
  };
}
