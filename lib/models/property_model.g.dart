// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PropertyModelImpl _$$PropertyModelImplFromJson(
  Map<String, dynamic> json,
) => _$PropertyModelImpl(
  propertyId: json['id'] as String,
  ownerId: json['owner_id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  genderOrientation: $enumDecode(
    _$GenderOrientationEnumMap,
    json['gender_orientation'],
  ),
  amenities:
      (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  priceRange: PriceRange.fromJson(json['price_range'] as Map<String, dynamic>),
  status:
      $enumDecodeNullable(_$PropertyStatusEnumMap, json['status']) ??
      PropertyStatus.pending,
  lastUpdated: DateTime.parse(json['last_updated'] as String),
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  description: json['description'] as String?,
  hasVacancy: json['has_vacancy'] as bool? ?? true,
);

Map<String, dynamic> _$$PropertyModelImplToJson(
  _$PropertyModelImpl instance,
) => <String, dynamic>{
  'id': instance.propertyId,
  'owner_id': instance.ownerId,
  'name': instance.name,
  'address': instance.address,
  'lat': instance.lat,
  'lng': instance.lng,
  'gender_orientation': _$GenderOrientationEnumMap[instance.genderOrientation]!,
  'amenities': instance.amenities,
  'price_range': instance.priceRange,
  'status': _$PropertyStatusEnumMap[instance.status]!,
  'last_updated': instance.lastUpdated.toIso8601String(),
  'images': instance.images,
  'description': instance.description,
  'has_vacancy': instance.hasVacancy,
};

const _$GenderOrientationEnumMap = {
  GenderOrientation.male: 'male',
  GenderOrientation.female: 'female',
  GenderOrientation.mixed: 'mixed',
};

const _$PropertyStatusEnumMap = {
  PropertyStatus.pending: 'pending',
  PropertyStatus.verified: 'verified',
  PropertyStatus.deleted: 'deleted',
};

_$PriceRangeImpl _$$PriceRangeImplFromJson(Map<String, dynamic> json) =>
    _$PriceRangeImpl(
      min: (json['min'] as num?)?.toInt() ?? 0,
      max: (json['max'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PriceRangeImplToJson(_$PriceRangeImpl instance) =>
    <String, dynamic>{'min': instance.min, 'max': instance.max};
