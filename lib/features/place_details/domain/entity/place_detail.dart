import 'package:equatable/equatable.dart';

final class PlaceDetailPhoto extends Equatable {
  const PlaceDetailPhoto({required this.url, this.attribution});

  final String url;
  final String? attribution;

  @override
  List<Object?> get props => [url, attribution];
}

final class PlaceDetail extends Equatable {
  const PlaceDetail({
    required this.id,
    this.priceLevel,
    this.openNow,
    this.nextCloseTime,
    this.weeklyHours = const [],
    this.photos = const [],
  });

  final String id;
  final String? priceLevel;
  final bool? openNow;
  final DateTime? nextCloseTime;
  final List<String> weeklyHours;
  final List<PlaceDetailPhoto> photos;

  @override
  List<Object?> get props => [
    id,
    priceLevel,
    openNow,
    nextCloseTime,
    weeklyHours,
    photos,
  ];
}