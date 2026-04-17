// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_model.freezed.dart';
part 'room_model.g.dart';

/// Room vacancy status - the core feature of VacanSee
enum RoomStatus {
  @JsonValue('vacant')
  vacant,
  @JsonValue('occupied')
  occupied,
}

/// Room model representing individual rooms within a property
@freezed
class RoomModel with _$RoomModel {
  const RoomModel._(); // Supporting custom getters

  const factory RoomModel({
    @JsonKey(name: 'id') required String roomId,
    @JsonKey(name: 'property_id') required String propertyId,
    required RoomStatus status,
    @Default([]) List<String> images,
    required int capacity,
    @JsonKey(name: 'current_occupants') @Default(0) int currentOccupants,
    @JsonKey(name: 'monthly_rate') int? monthlyRate,
    String? description,
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,

    // Virtual/Joined fields from the room_vacancies view
    @JsonKey(name: 'is_available') @Default(false) bool isAvailable,
    @JsonKey(name: 'property_name') String? propertyName,
  }) = _RoomModel;

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);

  /// Check if room has available slots
  bool get hasVacancy {
    if (status == RoomStatus.vacant) return true;
    if (capacity == 0) return false;
    return currentOccupants < capacity;
  }

  /// Get available slots count
  int get availableSlots {
    return capacity - currentOccupants;
  }
}
