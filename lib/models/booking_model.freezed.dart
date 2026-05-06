// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) {
  return _BookingModel.fromJson(json);
}

/// @nodoc
mixin _$BookingModel {
  @JsonKey(name: 'id')
  String get bookingId => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_id')
  String get studentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'property_id')
  String get propertyId => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_id')
  String get roomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'property_name')
  String get propertyName => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_description')
  String get roomDescription => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_name')
  String get studentName => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_email')
  String get studentEmail => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_phone')
  String? get studentPhone => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'requested_at')
  DateTime get requestedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'responded_at')
  DateTime? get respondedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_notes')
  String? get ownerNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_notes')
  String? get studentNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'move_in_date')
  DateTime? get moveInDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_months')
  int get durationMonths => throw _privateConstructorUsedError;

  /// Serializes this BookingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingModelCopyWith<BookingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingModelCopyWith<$Res> {
  factory $BookingModelCopyWith(
    BookingModel value,
    $Res Function(BookingModel) then,
  ) = _$BookingModelCopyWithImpl<$Res, BookingModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String bookingId,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'property_id') String propertyId,
    @JsonKey(name: 'room_id') String roomId,
    @JsonKey(name: 'property_name') String propertyName,
    @JsonKey(name: 'room_description') String roomDescription,
    @JsonKey(name: 'student_name') String studentName,
    @JsonKey(name: 'student_email') String studentEmail,
    @JsonKey(name: 'student_phone') String? studentPhone,
    BookingStatus status,
    @JsonKey(name: 'requested_at') DateTime requestedAt,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'owner_notes') String? ownerNotes,
    @JsonKey(name: 'student_notes') String? studentNotes,
    @JsonKey(name: 'move_in_date') DateTime? moveInDate,
    @JsonKey(name: 'duration_months') int durationMonths,
  });
}

/// @nodoc
class _$BookingModelCopyWithImpl<$Res, $Val extends BookingModel>
    implements $BookingModelCopyWith<$Res> {
  _$BookingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? studentId = null,
    Object? propertyId = null,
    Object? roomId = null,
    Object? propertyName = null,
    Object? roomDescription = null,
    Object? studentName = null,
    Object? studentEmail = null,
    Object? studentPhone = freezed,
    Object? status = null,
    Object? requestedAt = null,
    Object? respondedAt = freezed,
    Object? expiresAt = freezed,
    Object? ownerNotes = freezed,
    Object? studentNotes = freezed,
    Object? moveInDate = freezed,
    Object? durationMonths = null,
  }) {
    return _then(
      _value.copyWith(
            bookingId: null == bookingId
                ? _value.bookingId
                : bookingId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            propertyId: null == propertyId
                ? _value.propertyId
                : propertyId // ignore: cast_nullable_to_non_nullable
                      as String,
            roomId: null == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                      as String,
            propertyName: null == propertyName
                ? _value.propertyName
                : propertyName // ignore: cast_nullable_to_non_nullable
                      as String,
            roomDescription: null == roomDescription
                ? _value.roomDescription
                : roomDescription // ignore: cast_nullable_to_non_nullable
                      as String,
            studentName: null == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                      as String,
            studentEmail: null == studentEmail
                ? _value.studentEmail
                : studentEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            studentPhone: freezed == studentPhone
                ? _value.studentPhone
                : studentPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BookingStatus,
            requestedAt: null == requestedAt
                ? _value.requestedAt
                : requestedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            respondedAt: freezed == respondedAt
                ? _value.respondedAt
                : respondedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            ownerNotes: freezed == ownerNotes
                ? _value.ownerNotes
                : ownerNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            studentNotes: freezed == studentNotes
                ? _value.studentNotes
                : studentNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            moveInDate: freezed == moveInDate
                ? _value.moveInDate
                : moveInDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            durationMonths: null == durationMonths
                ? _value.durationMonths
                : durationMonths // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookingModelImplCopyWith<$Res>
    implements $BookingModelCopyWith<$Res> {
  factory _$$BookingModelImplCopyWith(
    _$BookingModelImpl value,
    $Res Function(_$BookingModelImpl) then,
  ) = __$$BookingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String bookingId,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'property_id') String propertyId,
    @JsonKey(name: 'room_id') String roomId,
    @JsonKey(name: 'property_name') String propertyName,
    @JsonKey(name: 'room_description') String roomDescription,
    @JsonKey(name: 'student_name') String studentName,
    @JsonKey(name: 'student_email') String studentEmail,
    @JsonKey(name: 'student_phone') String? studentPhone,
    BookingStatus status,
    @JsonKey(name: 'requested_at') DateTime requestedAt,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'owner_notes') String? ownerNotes,
    @JsonKey(name: 'student_notes') String? studentNotes,
    @JsonKey(name: 'move_in_date') DateTime? moveInDate,
    @JsonKey(name: 'duration_months') int durationMonths,
  });
}

/// @nodoc
class __$$BookingModelImplCopyWithImpl<$Res>
    extends _$BookingModelCopyWithImpl<$Res, _$BookingModelImpl>
    implements _$$BookingModelImplCopyWith<$Res> {
  __$$BookingModelImplCopyWithImpl(
    _$BookingModelImpl _value,
    $Res Function(_$BookingModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? studentId = null,
    Object? propertyId = null,
    Object? roomId = null,
    Object? propertyName = null,
    Object? roomDescription = null,
    Object? studentName = null,
    Object? studentEmail = null,
    Object? studentPhone = freezed,
    Object? status = null,
    Object? requestedAt = null,
    Object? respondedAt = freezed,
    Object? expiresAt = freezed,
    Object? ownerNotes = freezed,
    Object? studentNotes = freezed,
    Object? moveInDate = freezed,
    Object? durationMonths = null,
  }) {
    return _then(
      _$BookingModelImpl(
        bookingId: null == bookingId
            ? _value.bookingId
            : bookingId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        propertyId: null == propertyId
            ? _value.propertyId
            : propertyId // ignore: cast_nullable_to_non_nullable
                  as String,
        roomId: null == roomId
            ? _value.roomId
            : roomId // ignore: cast_nullable_to_non_nullable
                  as String,
        propertyName: null == propertyName
            ? _value.propertyName
            : propertyName // ignore: cast_nullable_to_non_nullable
                  as String,
        roomDescription: null == roomDescription
            ? _value.roomDescription
            : roomDescription // ignore: cast_nullable_to_non_nullable
                  as String,
        studentName: null == studentName
            ? _value.studentName
            : studentName // ignore: cast_nullable_to_non_nullable
                  as String,
        studentEmail: null == studentEmail
            ? _value.studentEmail
            : studentEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        studentPhone: freezed == studentPhone
            ? _value.studentPhone
            : studentPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BookingStatus,
        requestedAt: null == requestedAt
            ? _value.requestedAt
            : requestedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        respondedAt: freezed == respondedAt
            ? _value.respondedAt
            : respondedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        ownerNotes: freezed == ownerNotes
            ? _value.ownerNotes
            : ownerNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        studentNotes: freezed == studentNotes
            ? _value.studentNotes
            : studentNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        moveInDate: freezed == moveInDate
            ? _value.moveInDate
            : moveInDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        durationMonths: null == durationMonths
            ? _value.durationMonths
            : durationMonths // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingModelImpl extends _BookingModel {
  const _$BookingModelImpl({
    @JsonKey(name: 'id') required this.bookingId,
    @JsonKey(name: 'student_id') required this.studentId,
    @JsonKey(name: 'property_id') required this.propertyId,
    @JsonKey(name: 'room_id') required this.roomId,
    @JsonKey(name: 'property_name') required this.propertyName,
    @JsonKey(name: 'room_description') required this.roomDescription,
    @JsonKey(name: 'student_name') required this.studentName,
    @JsonKey(name: 'student_email') required this.studentEmail,
    @JsonKey(name: 'student_phone') this.studentPhone,
    required this.status,
    @JsonKey(name: 'requested_at') required this.requestedAt,
    @JsonKey(name: 'responded_at') this.respondedAt,
    @JsonKey(name: 'expires_at') this.expiresAt,
    @JsonKey(name: 'owner_notes') this.ownerNotes,
    @JsonKey(name: 'student_notes') this.studentNotes,
    @JsonKey(name: 'move_in_date') this.moveInDate,
    @JsonKey(name: 'duration_months') this.durationMonths = 1,
  }) : super._();

  factory _$BookingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String bookingId;
  @override
  @JsonKey(name: 'student_id')
  final String studentId;
  @override
  @JsonKey(name: 'property_id')
  final String propertyId;
  @override
  @JsonKey(name: 'room_id')
  final String roomId;
  @override
  @JsonKey(name: 'property_name')
  final String propertyName;
  @override
  @JsonKey(name: 'room_description')
  final String roomDescription;
  @override
  @JsonKey(name: 'student_name')
  final String studentName;
  @override
  @JsonKey(name: 'student_email')
  final String studentEmail;
  @override
  @JsonKey(name: 'student_phone')
  final String? studentPhone;
  @override
  final BookingStatus status;
  @override
  @JsonKey(name: 'requested_at')
  final DateTime requestedAt;
  @override
  @JsonKey(name: 'responded_at')
  final DateTime? respondedAt;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @override
  @JsonKey(name: 'owner_notes')
  final String? ownerNotes;
  @override
  @JsonKey(name: 'student_notes')
  final String? studentNotes;
  @override
  @JsonKey(name: 'move_in_date')
  final DateTime? moveInDate;
  @override
  @JsonKey(name: 'duration_months')
  final int durationMonths;

  @override
  String toString() {
    return 'BookingModel(bookingId: $bookingId, studentId: $studentId, propertyId: $propertyId, roomId: $roomId, propertyName: $propertyName, roomDescription: $roomDescription, studentName: $studentName, studentEmail: $studentEmail, studentPhone: $studentPhone, status: $status, requestedAt: $requestedAt, respondedAt: $respondedAt, expiresAt: $expiresAt, ownerNotes: $ownerNotes, studentNotes: $studentNotes, moveInDate: $moveInDate, durationMonths: $durationMonths)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingModelImpl &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.propertyName, propertyName) ||
                other.propertyName == propertyName) &&
            (identical(other.roomDescription, roomDescription) ||
                other.roomDescription == roomDescription) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.studentEmail, studentEmail) ||
                other.studentEmail == studentEmail) &&
            (identical(other.studentPhone, studentPhone) ||
                other.studentPhone == studentPhone) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.ownerNotes, ownerNotes) ||
                other.ownerNotes == ownerNotes) &&
            (identical(other.studentNotes, studentNotes) ||
                other.studentNotes == studentNotes) &&
            (identical(other.moveInDate, moveInDate) ||
                other.moveInDate == moveInDate) &&
            (identical(other.durationMonths, durationMonths) ||
                other.durationMonths == durationMonths));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    bookingId,
    studentId,
    propertyId,
    roomId,
    propertyName,
    roomDescription,
    studentName,
    studentEmail,
    studentPhone,
    status,
    requestedAt,
    respondedAt,
    expiresAt,
    ownerNotes,
    studentNotes,
    moveInDate,
    durationMonths,
  );

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      __$$BookingModelImplCopyWithImpl<_$BookingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingModelImplToJson(this);
  }
}

abstract class _BookingModel extends BookingModel {
  const factory _BookingModel({
    @JsonKey(name: 'id') required final String bookingId,
    @JsonKey(name: 'student_id') required final String studentId,
    @JsonKey(name: 'property_id') required final String propertyId,
    @JsonKey(name: 'room_id') required final String roomId,
    @JsonKey(name: 'property_name') required final String propertyName,
    @JsonKey(name: 'room_description') required final String roomDescription,
    @JsonKey(name: 'student_name') required final String studentName,
    @JsonKey(name: 'student_email') required final String studentEmail,
    @JsonKey(name: 'student_phone') final String? studentPhone,
    required final BookingStatus status,
    @JsonKey(name: 'requested_at') required final DateTime requestedAt,
    @JsonKey(name: 'responded_at') final DateTime? respondedAt,
    @JsonKey(name: 'expires_at') final DateTime? expiresAt,
    @JsonKey(name: 'owner_notes') final String? ownerNotes,
    @JsonKey(name: 'student_notes') final String? studentNotes,
    @JsonKey(name: 'move_in_date') final DateTime? moveInDate,
    @JsonKey(name: 'duration_months') final int durationMonths,
  }) = _$BookingModelImpl;
  const _BookingModel._() : super._();

  factory _BookingModel.fromJson(Map<String, dynamic> json) =
      _$BookingModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get bookingId;
  @override
  @JsonKey(name: 'student_id')
  String get studentId;
  @override
  @JsonKey(name: 'property_id')
  String get propertyId;
  @override
  @JsonKey(name: 'room_id')
  String get roomId;
  @override
  @JsonKey(name: 'property_name')
  String get propertyName;
  @override
  @JsonKey(name: 'room_description')
  String get roomDescription;
  @override
  @JsonKey(name: 'student_name')
  String get studentName;
  @override
  @JsonKey(name: 'student_email')
  String get studentEmail;
  @override
  @JsonKey(name: 'student_phone')
  String? get studentPhone;
  @override
  BookingStatus get status;
  @override
  @JsonKey(name: 'requested_at')
  DateTime get requestedAt;
  @override
  @JsonKey(name: 'responded_at')
  DateTime? get respondedAt;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;
  @override
  @JsonKey(name: 'owner_notes')
  String? get ownerNotes;
  @override
  @JsonKey(name: 'student_notes')
  String? get studentNotes;
  @override
  @JsonKey(name: 'move_in_date')
  DateTime? get moveInDate;
  @override
  @JsonKey(name: 'duration_months')
  int get durationMonths;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
