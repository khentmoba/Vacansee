// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomModelImpl _$$RoomModelImplFromJson(Map<String, dynamic> json) =>
    _$RoomModelImpl(
      roomId: json['id'] as String,
      propertyId: json['property_id'] as String,
      status: $enumDecode(_$RoomStatusEnumMap, json['status']),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      capacity: (json['capacity'] as num).toInt(),
      currentOccupants: (json['current_occupants'] as num?)?.toInt() ?? 0,
      monthlyRate: (json['monthly_rate'] as num?)?.toInt(),
      description: json['description'] as String?,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      isAvailable: json['is_available'] as bool? ?? false,
      propertyName: json['property_name'] as String?,
    );

Map<String, dynamic> _$$RoomModelImplToJson(_$RoomModelImpl instance) =>
    <String, dynamic>{
      'id': instance.roomId,
      'property_id': instance.propertyId,
      'status': _$RoomStatusEnumMap[instance.status]!,
      'images': instance.images,
      'capacity': instance.capacity,
      'current_occupants': instance.currentOccupants,
      'monthly_rate': instance.monthlyRate,
      'description': instance.description,
      'last_updated': instance.lastUpdated.toIso8601String(),
      'is_available': instance.isAvailable,
      'property_name': instance.propertyName,
    };

const _$RoomStatusEnumMap = {
  RoomStatus.vacant: 'vacant',
  RoomStatus.occupied: 'occupied',
};
