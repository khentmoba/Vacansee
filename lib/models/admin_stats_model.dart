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
    @Default(0) int totalUsers,
    @Default(0.0) double occupancyRate,
    @Default(0) int totalBookings,
    @Default(0) int activeTenants,
    @Default(0) int pendingBookings,
    required DateTime lastUpdated,
  }) = _AdminStatsModel;

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) =>
      _$AdminStatsModelFromJson(json);
}
