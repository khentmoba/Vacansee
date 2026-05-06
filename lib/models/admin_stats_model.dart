import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_stats_model.freezed.dart';
part 'admin_stats_model.g.dart';

@freezed
class AdminStatsModel with _$AdminStatsModel {
  const factory AdminStatsModel({
    required int totalProperties,
    required int verifiedProperties,
    required int totalOwners,
    required int totalStudents,
    required DateTime lastUpdated,
  }) = _AdminStatsModel;

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) =>
      _$AdminStatsModelFromJson(json);
}
