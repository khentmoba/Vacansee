// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rating_model.freezed.dart';
part 'rating_model.g.dart';

@freezed
class RatingModel with _$RatingModel {
  const factory RatingModel({
    @JsonKey(name: 'id') required String ratingId,
    @JsonKey(name: 'booking_id') required String bookingId,
    @JsonKey(name: 'property_id') required String propertyId,
    @JsonKey(name: 'student_id') required String studentId,
    required int rating,
    String? review,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _RatingModel;

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);
}
