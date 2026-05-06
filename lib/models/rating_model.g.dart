// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RatingModelImpl _$$RatingModelImplFromJson(Map<String, dynamic> json) =>
    _$RatingModelImpl(
      ratingId: json['id'] as String,
      bookingId: json['booking_id'] as String,
      propertyId: json['property_id'] as String,
      studentId: json['student_id'] as String,
      rating: (json['rating'] as num).toInt(),
      review: json['review'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$RatingModelImplToJson(_$RatingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.ratingId,
      'booking_id': instance.bookingId,
      'property_id': instance.propertyId,
      'student_id': instance.studentId,
      'rating': instance.rating,
      'review': instance.review,
      'created_at': instance.createdAt.toIso8601String(),
    };
