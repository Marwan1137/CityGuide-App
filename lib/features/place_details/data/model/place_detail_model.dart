final class PlaceDetailPhotoModel {
  const PlaceDetailPhotoModel({required this.url, this.attribution});

  factory PlaceDetailPhotoModel.fromJson(Map<String, dynamic> json) {
    final url = json['url'];
    if (url is! String || url.trim().isEmpty) {
      throw const FormatException('Invalid photo payload.');
    }
    return PlaceDetailPhotoModel(
      url: url,
      attribution: json['attribution'] is String
          ? json['attribution'] as String
          : null,
    );
  }

  final String url;
  final String? attribution;
}
final class PlaceDetailModel {
  const PlaceDetailModel({
    required this.id,
    this.priceLevel,
    this.openNow,
    this.nextCloseTime,
    this.weeklyHours = const [],
    this.photos = const [],
  });

  factory PlaceDetailModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.trim().isEmpty) {
      throw const FormatException('Invalid place detail payload.');
    }

    final weeklyHoursJson = json['weekly_hours'];
    final photosJson = json['photos'];
    final nextCloseTimeJson = json['next_close_time'];

    return PlaceDetailModel(
      id: id,
      priceLevel: json['price_level'] is String
          ? json['price_level'] as String
          : null,
      openNow: json['open_now'] is bool ? json['open_now'] as bool : null,
      nextCloseTime: nextCloseTimeJson is String
          ? DateTime.tryParse(nextCloseTimeJson)?.toLocal()
          : null,
      weeklyHours: weeklyHoursJson is List
          ? weeklyHoursJson.whereType<String>().toList(growable: false)
          : const [],
      photos: photosJson is List
          ? photosJson
          .map(
            (item) => PlaceDetailPhotoModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(growable: false)
          : const [],
    );
  }

  final String id;
  final String? priceLevel;
  final bool? openNow;
  final DateTime? nextCloseTime;
  final List<String> weeklyHours;
  final List<PlaceDetailPhotoModel> photos;
}