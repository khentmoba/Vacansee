// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminStatsModelImpl _$$AdminStatsModelImplFromJson(
  Map<String, dynamic> json,
) => _$AdminStatsModelImpl(
  totalProperties: (json['totalProperties'] as num).toInt(),
  verifiedProperties: (json['verifiedProperties'] as num).toInt(),
  totalOwners: (json['totalOwners'] as num).toInt(),
  totalStudents: (json['totalStudents'] as num).toInt(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$$AdminStatsModelImplToJson(
  _$AdminStatsModelImpl instance,
) => <String, dynamic>{
  'totalProperties': instance.totalProperties,
  'verifiedProperties': instance.verifiedProperties,
  'totalOwners': instance.totalOwners,
  'totalStudents': instance.totalStudents,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};
