// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_model.freezed.dart';
part 'property_model.g.dart';

/// Gender orientation for boarding house filtering
enum GenderOrientation { 
  @JsonValue('male') male, 
  @JsonValue('female') female, 
  @JsonValue('mixed') mixed 
}

/// Property model representing a boarding house listing
@freezed
class PropertyModel with _$PropertyModel {
  const factory PropertyModel({
    @JsonKey(name: 'id') required String propertyId,
    @JsonKey(name: 'owner_id') required String ownerId,
    required String name,
    required String address,
    required double lat,
    required double lng,
    @JsonKey(name: 'gender_orientation') required GenderOrientation genderOrientation,
    @Default([]) List<String> amenities,
    @JsonKey(name: 'price_range') required PriceRange priceRange,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,
    String? description,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'has_vacancy') @Default(true) bool hasVacancy,
  }) = _PropertyModel;

  factory PropertyModel.fromJson(Map<String, dynamic> json) => _$PropertyModelFromJson(json);
}

/// Price range for filtering
@freezed
class PriceRange with _$PriceRange {
  const PriceRange._(); // Supporting custom getters

  const factory PriceRange({
    @Default(0) int min,
    @Default(0) int max,
  }) = _PriceRange;

  factory PriceRange.fromJson(Map<String, dynamic> json) => _$PriceRangeFromJson(json);

  String get formatted => '₱$min - ₱$max';
}
