// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'property_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PropertyModel _$PropertyModelFromJson(Map<String, dynamic> json) {
  return _PropertyModel.fromJson(json);
}

/// @nodoc
mixin _$PropertyModel {
  @JsonKey(name: 'id')
  String get propertyId => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_id')
  String get ownerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  @JsonKey(name: 'gender_orientation')
  GenderOrientation get genderOrientation => throw _privateConstructorUsedError;
  List<String> get amenities => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_range')
  PriceRange get priceRange => throw _privateConstructorUsedError;
  PropertyStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_vacancy')
  bool get hasVacancy => throw _privateConstructorUsedError;

  /// Serializes this PropertyModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PropertyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PropertyModelCopyWith<PropertyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PropertyModelCopyWith<$Res> {
  factory $PropertyModelCopyWith(
    PropertyModel value,
    $Res Function(PropertyModel) then,
  ) = _$PropertyModelCopyWithImpl<$Res, PropertyModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String propertyId,
    @JsonKey(name: 'owner_id') String ownerId,
    String name,
    String address,
    double lat,
    double lng,
    @JsonKey(name: 'gender_orientation') GenderOrientation genderOrientation,
    List<String> amenities,
    @JsonKey(name: 'price_range') PriceRange priceRange,
    PropertyStatus status,
    @JsonKey(name: 'last_updated') DateTime lastUpdated,
    List<String> images,
    String? description,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'has_vacancy') bool hasVacancy,
  });

  $PriceRangeCopyWith<$Res> get priceRange;
}

/// @nodoc
class _$PropertyModelCopyWithImpl<$Res, $Val extends PropertyModel>
    implements $PropertyModelCopyWith<$Res> {
  _$PropertyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PropertyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? propertyId = null,
    Object? ownerId = null,
    Object? name = null,
    Object? address = null,
    Object? lat = null,
    Object? lng = null,
    Object? genderOrientation = null,
    Object? amenities = null,
    Object? priceRange = null,
    Object? status = null,
    Object? lastUpdated = null,
    Object? images = null,
    Object? description = freezed,
    Object? rejectionReason = freezed,
    Object? hasVacancy = null,
  }) {
    return _then(
      _value.copyWith(
            propertyId: null == propertyId
                ? _value.propertyId
                : propertyId // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerId: null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            genderOrientation: null == genderOrientation
                ? _value.genderOrientation
                : genderOrientation // ignore: cast_nullable_to_non_nullable
                      as GenderOrientation,
            amenities: null == amenities
                ? _value.amenities
                : amenities // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            priceRange: null == priceRange
                ? _value.priceRange
                : priceRange // ignore: cast_nullable_to_non_nullable
                      as PriceRange,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PropertyStatus,
            lastUpdated: null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            rejectionReason: freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            hasVacancy: null == hasVacancy
                ? _value.hasVacancy
                : hasVacancy // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of PropertyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceRangeCopyWith<$Res> get priceRange {
    return $PriceRangeCopyWith<$Res>(_value.priceRange, (value) {
      return _then(_value.copyWith(priceRange: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PropertyModelImplCopyWith<$Res>
    implements $PropertyModelCopyWith<$Res> {
  factory _$$PropertyModelImplCopyWith(
    _$PropertyModelImpl value,
    $Res Function(_$PropertyModelImpl) then,
  ) = __$$PropertyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String propertyId,
    @JsonKey(name: 'owner_id') String ownerId,
    String name,
    String address,
    double lat,
    double lng,
    @JsonKey(name: 'gender_orientation') GenderOrientation genderOrientation,
    List<String> amenities,
    @JsonKey(name: 'price_range') PriceRange priceRange,
    PropertyStatus status,
    @JsonKey(name: 'last_updated') DateTime lastUpdated,
    List<String> images,
    String? description,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'has_vacancy') bool hasVacancy,
  });

  @override
  $PriceRangeCopyWith<$Res> get priceRange;
}

/// @nodoc
class __$$PropertyModelImplCopyWithImpl<$Res>
    extends _$PropertyModelCopyWithImpl<$Res, _$PropertyModelImpl>
    implements _$$PropertyModelImplCopyWith<$Res> {
  __$$PropertyModelImplCopyWithImpl(
    _$PropertyModelImpl _value,
    $Res Function(_$PropertyModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PropertyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? propertyId = null,
    Object? ownerId = null,
    Object? name = null,
    Object? address = null,
    Object? lat = null,
    Object? lng = null,
    Object? genderOrientation = null,
    Object? amenities = null,
    Object? priceRange = null,
    Object? status = null,
    Object? lastUpdated = null,
    Object? images = null,
    Object? description = freezed,
    Object? rejectionReason = freezed,
    Object? hasVacancy = null,
  }) {
    return _then(
      _$PropertyModelImpl(
        propertyId: null == propertyId
            ? _value.propertyId
            : propertyId // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        genderOrientation: null == genderOrientation
            ? _value.genderOrientation
            : genderOrientation // ignore: cast_nullable_to_non_nullable
                  as GenderOrientation,
        amenities: null == amenities
            ? _value._amenities
            : amenities // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        priceRange: null == priceRange
            ? _value.priceRange
            : priceRange // ignore: cast_nullable_to_non_nullable
                  as PriceRange,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PropertyStatus,
        lastUpdated: null == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        rejectionReason: freezed == rejectionReason
            ? _value.rejectionReason
            : rejectionReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasVacancy: null == hasVacancy
            ? _value.hasVacancy
            : hasVacancy // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PropertyModelImpl extends _PropertyModel {
  const _$PropertyModelImpl({
    @JsonKey(name: 'id') required this.propertyId,
    @JsonKey(name: 'owner_id') required this.ownerId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    @JsonKey(name: 'gender_orientation') required this.genderOrientation,
    final List<String> amenities = const [],
    @JsonKey(name: 'price_range') required this.priceRange,
    this.status = PropertyStatus.pending,
    @JsonKey(name: 'last_updated') required this.lastUpdated,
    final List<String> images = const [],
    this.description,
    @JsonKey(name: 'rejection_reason') this.rejectionReason,
    @JsonKey(name: 'has_vacancy') this.hasVacancy = true,
  }) : _amenities = amenities,
       _images = images,
       super._();

  factory _$PropertyModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PropertyModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String propertyId;
  @override
  @JsonKey(name: 'owner_id')
  final String ownerId;
  @override
  final String name;
  @override
  final String address;
  @override
  final double lat;
  @override
  final double lng;
  @override
  @JsonKey(name: 'gender_orientation')
  final GenderOrientation genderOrientation;
  final List<String> _amenities;
  @override
  @JsonKey()
  List<String> get amenities {
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amenities);
  }

  @override
  @JsonKey(name: 'price_range')
  final PriceRange priceRange;
  @override
  @JsonKey()
  final PropertyStatus status;
  @override
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final String? description;
  @override
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @override
  @JsonKey(name: 'has_vacancy')
  final bool hasVacancy;

  @override
  String toString() {
    return 'PropertyModel(propertyId: $propertyId, ownerId: $ownerId, name: $name, address: $address, lat: $lat, lng: $lng, genderOrientation: $genderOrientation, amenities: $amenities, priceRange: $priceRange, status: $status, lastUpdated: $lastUpdated, images: $images, description: $description, rejectionReason: $rejectionReason, hasVacancy: $hasVacancy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PropertyModelImpl &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.genderOrientation, genderOrientation) ||
                other.genderOrientation == genderOrientation) &&
            const DeepCollectionEquality().equals(
              other._amenities,
              _amenities,
            ) &&
            (identical(other.priceRange, priceRange) ||
                other.priceRange == priceRange) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.hasVacancy, hasVacancy) ||
                other.hasVacancy == hasVacancy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    propertyId,
    ownerId,
    name,
    address,
    lat,
    lng,
    genderOrientation,
    const DeepCollectionEquality().hash(_amenities),
    priceRange,
    status,
    lastUpdated,
    const DeepCollectionEquality().hash(_images),
    description,
    rejectionReason,
    hasVacancy,
  );

  /// Create a copy of PropertyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PropertyModelImplCopyWith<_$PropertyModelImpl> get copyWith =>
      __$$PropertyModelImplCopyWithImpl<_$PropertyModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PropertyModelImplToJson(this);
  }
}

abstract class _PropertyModel extends PropertyModel {
  const factory _PropertyModel({
    @JsonKey(name: 'id') required final String propertyId,
    @JsonKey(name: 'owner_id') required final String ownerId,
    required final String name,
    required final String address,
    required final double lat,
    required final double lng,
    @JsonKey(name: 'gender_orientation')
    required final GenderOrientation genderOrientation,
    final List<String> amenities,
    @JsonKey(name: 'price_range') required final PriceRange priceRange,
    final PropertyStatus status,
    @JsonKey(name: 'last_updated') required final DateTime lastUpdated,
    final List<String> images,
    final String? description,
    @JsonKey(name: 'rejection_reason') final String? rejectionReason,
    @JsonKey(name: 'has_vacancy') final bool hasVacancy,
  }) = _$PropertyModelImpl;
  const _PropertyModel._() : super._();

  factory _PropertyModel.fromJson(Map<String, dynamic> json) =
      _$PropertyModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get propertyId;
  @override
  @JsonKey(name: 'owner_id')
  String get ownerId;
  @override
  String get name;
  @override
  String get address;
  @override
  double get lat;
  @override
  double get lng;
  @override
  @JsonKey(name: 'gender_orientation')
  GenderOrientation get genderOrientation;
  @override
  List<String> get amenities;
  @override
  @JsonKey(name: 'price_range')
  PriceRange get priceRange;
  @override
  PropertyStatus get status;
  @override
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated;
  @override
  List<String> get images;
  @override
  String? get description;
  @override
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason;
  @override
  @JsonKey(name: 'has_vacancy')
  bool get hasVacancy;

  /// Create a copy of PropertyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PropertyModelImplCopyWith<_$PropertyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceRange _$PriceRangeFromJson(Map<String, dynamic> json) {
  return _PriceRange.fromJson(json);
}

/// @nodoc
mixin _$PriceRange {
  int get min => throw _privateConstructorUsedError;
  int get max => throw _privateConstructorUsedError;

  /// Serializes this PriceRange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceRangeCopyWith<PriceRange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceRangeCopyWith<$Res> {
  factory $PriceRangeCopyWith(
    PriceRange value,
    $Res Function(PriceRange) then,
  ) = _$PriceRangeCopyWithImpl<$Res, PriceRange>;
  @useResult
  $Res call({int min, int max});
}

/// @nodoc
class _$PriceRangeCopyWithImpl<$Res, $Val extends PriceRange>
    implements $PriceRangeCopyWith<$Res> {
  _$PriceRangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? min = null, Object? max = null}) {
    return _then(
      _value.copyWith(
            min: null == min
                ? _value.min
                : min // ignore: cast_nullable_to_non_nullable
                      as int,
            max: null == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PriceRangeImplCopyWith<$Res>
    implements $PriceRangeCopyWith<$Res> {
  factory _$$PriceRangeImplCopyWith(
    _$PriceRangeImpl value,
    $Res Function(_$PriceRangeImpl) then,
  ) = __$$PriceRangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int min, int max});
}

/// @nodoc
class __$$PriceRangeImplCopyWithImpl<$Res>
    extends _$PriceRangeCopyWithImpl<$Res, _$PriceRangeImpl>
    implements _$$PriceRangeImplCopyWith<$Res> {
  __$$PriceRangeImplCopyWithImpl(
    _$PriceRangeImpl _value,
    $Res Function(_$PriceRangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PriceRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? min = null, Object? max = null}) {
    return _then(
      _$PriceRangeImpl(
        min: null == min
            ? _value.min
            : min // ignore: cast_nullable_to_non_nullable
                  as int,
        max: null == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceRangeImpl extends _PriceRange {
  const _$PriceRangeImpl({this.min = 0, this.max = 0}) : super._();

  factory _$PriceRangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceRangeImplFromJson(json);

  @override
  @JsonKey()
  final int min;
  @override
  @JsonKey()
  final int max;

  @override
  String toString() {
    return 'PriceRange(min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceRangeImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, min, max);

  /// Create a copy of PriceRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceRangeImplCopyWith<_$PriceRangeImpl> get copyWith =>
      __$$PriceRangeImplCopyWithImpl<_$PriceRangeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceRangeImplToJson(this);
  }
}

abstract class _PriceRange extends PriceRange {
  const factory _PriceRange({final int min, final int max}) = _$PriceRangeImpl;
  const _PriceRange._() : super._();

  factory _PriceRange.fromJson(Map<String, dynamic> json) =
      _$PriceRangeImpl.fromJson;

  @override
  int get min;
  @override
  int get max;

  /// Create a copy of PriceRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceRangeImplCopyWith<_$PriceRangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
