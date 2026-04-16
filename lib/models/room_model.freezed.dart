// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RoomModel _$RoomModelFromJson(Map<String, dynamic> json) {
  return _RoomModel.fromJson(json);
}

/// @nodoc
mixin _$RoomModel {
  @JsonKey(name: 'id')
  String get roomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'property_id')
  String get propertyId => throw _privateConstructorUsedError;
  RoomStatus get status => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_occupants')
  int get currentOccupants => throw _privateConstructorUsedError;
  @JsonKey(name: 'monthly_rate')
  int? get monthlyRate => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated => throw _privateConstructorUsedError; // Virtual/Joined fields from the room_vacancies view
  @JsonKey(name: 'is_available')
  bool get isAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'property_name')
  String? get propertyName => throw _privateConstructorUsedError;

  /// Serializes this RoomModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoomModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomModelCopyWith<RoomModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomModelCopyWith<$Res> {
  factory $RoomModelCopyWith(RoomModel value, $Res Function(RoomModel) then) =
      _$RoomModelCopyWithImpl<$Res, RoomModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String roomId,
    @JsonKey(name: 'property_id') String propertyId,
    RoomStatus status,
    List<String> images,
    int capacity,
    @JsonKey(name: 'current_occupants') int currentOccupants,
    @JsonKey(name: 'monthly_rate') int? monthlyRate,
    String? description,
    @JsonKey(name: 'last_updated') DateTime lastUpdated,
    @JsonKey(name: 'is_available') bool isAvailable,
    @JsonKey(name: 'property_name') String? propertyName,
  });
}

/// @nodoc
class _$RoomModelCopyWithImpl<$Res, $Val extends RoomModel>
    implements $RoomModelCopyWith<$Res> {
  _$RoomModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoomModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? propertyId = null,
    Object? status = null,
    Object? images = null,
    Object? capacity = null,
    Object? currentOccupants = null,
    Object? monthlyRate = freezed,
    Object? description = freezed,
    Object? lastUpdated = null,
    Object? isAvailable = null,
    Object? propertyName = freezed,
  }) {
    return _then(
      _value.copyWith(
            roomId: null == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                      as String,
            propertyId: null == propertyId
                ? _value.propertyId
                : propertyId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RoomStatus,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            capacity: null == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int,
            currentOccupants: null == currentOccupants
                ? _value.currentOccupants
                : currentOccupants // ignore: cast_nullable_to_non_nullable
                      as int,
            monthlyRate: freezed == monthlyRate
                ? _value.monthlyRate
                : monthlyRate // ignore: cast_nullable_to_non_nullable
                      as int?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastUpdated: null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            propertyName: freezed == propertyName
                ? _value.propertyName
                : propertyName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoomModelImplCopyWith<$Res>
    implements $RoomModelCopyWith<$Res> {
  factory _$$RoomModelImplCopyWith(
    _$RoomModelImpl value,
    $Res Function(_$RoomModelImpl) then,
  ) = __$$RoomModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String roomId,
    @JsonKey(name: 'property_id') String propertyId,
    RoomStatus status,
    List<String> images,
    int capacity,
    @JsonKey(name: 'current_occupants') int currentOccupants,
    @JsonKey(name: 'monthly_rate') int? monthlyRate,
    String? description,
    @JsonKey(name: 'last_updated') DateTime lastUpdated,
    @JsonKey(name: 'is_available') bool isAvailable,
    @JsonKey(name: 'property_name') String? propertyName,
  });
}

/// @nodoc
class __$$RoomModelImplCopyWithImpl<$Res>
    extends _$RoomModelCopyWithImpl<$Res, _$RoomModelImpl>
    implements _$$RoomModelImplCopyWith<$Res> {
  __$$RoomModelImplCopyWithImpl(
    _$RoomModelImpl _value,
    $Res Function(_$RoomModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoomModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? propertyId = null,
    Object? status = null,
    Object? images = null,
    Object? capacity = null,
    Object? currentOccupants = null,
    Object? monthlyRate = freezed,
    Object? description = freezed,
    Object? lastUpdated = null,
    Object? isAvailable = null,
    Object? propertyName = freezed,
  }) {
    return _then(
      _$RoomModelImpl(
        roomId: null == roomId
            ? _value.roomId
            : roomId // ignore: cast_nullable_to_non_nullable
                  as String,
        propertyId: null == propertyId
            ? _value.propertyId
            : propertyId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RoomStatus,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        capacity: null == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int,
        currentOccupants: null == currentOccupants
            ? _value.currentOccupants
            : currentOccupants // ignore: cast_nullable_to_non_nullable
                  as int,
        monthlyRate: freezed == monthlyRate
            ? _value.monthlyRate
            : monthlyRate // ignore: cast_nullable_to_non_nullable
                  as int?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastUpdated: null == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        propertyName: freezed == propertyName
            ? _value.propertyName
            : propertyName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomModelImpl extends _RoomModel {
  const _$RoomModelImpl({
    @JsonKey(name: 'id') required this.roomId,
    @JsonKey(name: 'property_id') required this.propertyId,
    required this.status,
    final List<String> images = const [],
    required this.capacity,
    @JsonKey(name: 'current_occupants') this.currentOccupants = 0,
    @JsonKey(name: 'monthly_rate') this.monthlyRate,
    this.description,
    @JsonKey(name: 'last_updated') required this.lastUpdated,
    @JsonKey(name: 'is_available') this.isAvailable = false,
    @JsonKey(name: 'property_name') this.propertyName,
  }) : _images = images,
       super._();

  factory _$RoomModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String roomId;
  @override
  @JsonKey(name: 'property_id')
  final String propertyId;
  @override
  final RoomStatus status;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final int capacity;
  @override
  @JsonKey(name: 'current_occupants')
  final int currentOccupants;
  @override
  @JsonKey(name: 'monthly_rate')
  final int? monthlyRate;
  @override
  final String? description;
  @override
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;
  // Virtual/Joined fields from the room_vacancies view
  @override
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @override
  @JsonKey(name: 'property_name')
  final String? propertyName;

  @override
  String toString() {
    return 'RoomModel(roomId: $roomId, propertyId: $propertyId, status: $status, images: $images, capacity: $capacity, currentOccupants: $currentOccupants, monthlyRate: $monthlyRate, description: $description, lastUpdated: $lastUpdated, isAvailable: $isAvailable, propertyName: $propertyName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomModelImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.currentOccupants, currentOccupants) ||
                other.currentOccupants == currentOccupants) &&
            (identical(other.monthlyRate, monthlyRate) ||
                other.monthlyRate == monthlyRate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.propertyName, propertyName) ||
                other.propertyName == propertyName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    roomId,
    propertyId,
    status,
    const DeepCollectionEquality().hash(_images),
    capacity,
    currentOccupants,
    monthlyRate,
    description,
    lastUpdated,
    isAvailable,
    propertyName,
  );

  /// Create a copy of RoomModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomModelImplCopyWith<_$RoomModelImpl> get copyWith =>
      __$$RoomModelImplCopyWithImpl<_$RoomModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomModelImplToJson(this);
  }
}

abstract class _RoomModel extends RoomModel {
  const factory _RoomModel({
    @JsonKey(name: 'id') required final String roomId,
    @JsonKey(name: 'property_id') required final String propertyId,
    required final RoomStatus status,
    final List<String> images,
    required final int capacity,
    @JsonKey(name: 'current_occupants') final int currentOccupants,
    @JsonKey(name: 'monthly_rate') final int? monthlyRate,
    final String? description,
    @JsonKey(name: 'last_updated') required final DateTime lastUpdated,
    @JsonKey(name: 'is_available') final bool isAvailable,
    @JsonKey(name: 'property_name') final String? propertyName,
  }) = _$RoomModelImpl;
  const _RoomModel._() : super._();

  factory _RoomModel.fromJson(Map<String, dynamic> json) =
      _$RoomModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get roomId;
  @override
  @JsonKey(name: 'property_id')
  String get propertyId;
  @override
  RoomStatus get status;
  @override
  List<String> get images;
  @override
  int get capacity;
  @override
  @JsonKey(name: 'current_occupants')
  int get currentOccupants;
  @override
  @JsonKey(name: 'monthly_rate')
  int? get monthlyRate;
  @override
  String? get description;
  @override
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated; // Virtual/Joined fields from the room_vacancies view
  @override
  @JsonKey(name: 'is_available')
  bool get isAvailable;
  @override
  @JsonKey(name: 'property_name')
  String? get propertyName;

  /// Create a copy of RoomModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomModelImplCopyWith<_$RoomModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
