import 'package:equatable/equatable.dart';

final class CityModel extends Equatable {
  const CityModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.governorateEn,
    required this.governorateAr,
    required this.latitude,
    required this.longitude,
    required this.aliases,
    this.isRemoteResult = false,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
    id: json['id'] as String,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String? ?? '',
    governorateEn: json['governorate_en'] as String? ?? '',
    governorateAr: json['governorate_ar'] as String? ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    aliases: (json['aliases'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false),
    isRemoteResult: json['is_remote_result'] as bool? ?? false,
  );

  final String id;
  final String nameEn;
  final String nameAr;
  final String governorateEn;
  final String governorateAr;
  final double latitude;
  final double longitude;
  final List<String> aliases;
  final bool isRemoteResult;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name_en': nameEn,
    'name_ar': nameAr,
    'governorate_en': governorateEn,
    'governorate_ar': governorateAr,
    'latitude': latitude,
    'longitude': longitude,
    'aliases': aliases,
    'is_remote_result': isRemoteResult,
  };

  @override
  List<Object?> get props => [
    id,
    nameEn,
    nameAr,
    governorateEn,
    governorateAr,
    latitude,
    longitude,
    aliases,
    isRemoteResult,
  ];
}
