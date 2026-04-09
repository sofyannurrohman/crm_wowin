// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Lead {
  String get id;
  String get title;
  String get name;
  @JsonKey(name: 'company')
  String? get company;
  String? get email;
  String? get phone;
  String get source;
  String get status;
  @JsonKey(name: 'customer_id')
  String? get customerId;
  @JsonKey(name: 'estimated_value')
  double? get estimatedValue;
  @JsonKey(name: 'potential_products')
  List<String>? get potentialProducts;
  String? get notes;
  @JsonKey(name: 'converted_at')
  DateTime? get convertedAt;
  String? get address;
  double? get latitude;
  double? get longitude;
  @JsonKey(name: 'sales_id')
  String? get salesId;
  @JsonKey(name: 'salesman_name')
  String? get salesmanName;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LeadCopyWith<Lead> get copyWith =>
      _$LeadCopyWithImpl<Lead>(this as Lead, _$identity);

  /// Serializes this Lead to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Lead &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.estimatedValue, estimatedValue) ||
                other.estimatedValue == estimatedValue) &&
            const DeepCollectionEquality()
                .equals(other.potentialProducts, potentialProducts) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.convertedAt, convertedAt) ||
                other.convertedAt == convertedAt) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.salesId, salesId) || other.salesId == salesId) &&
            (identical(other.salesmanName, salesmanName) ||
                other.salesmanName == salesmanName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      name,
      company,
      email,
      phone,
      source,
      status,
      customerId,
      estimatedValue,
      const DeepCollectionEquality().hash(potentialProducts),
      notes,
      convertedAt,
      address,
      latitude,
      longitude,
      salesId,
      salesmanName);

  @override
  String toString() {
    return 'Lead(id: $id, title: $title, name: $name, company: $company, email: $email, phone: $phone, source: $source, status: $status, customerId: $customerId, estimatedValue: $estimatedValue, potentialProducts: $potentialProducts, notes: $notes, convertedAt: $convertedAt, address: $address, latitude: $latitude, longitude: $longitude, salesId: $salesId, salesmanName: $salesmanName)';
  }
}

/// @nodoc
abstract mixin class $LeadCopyWith<$Res> {
  factory $LeadCopyWith(Lead value, $Res Function(Lead) _then) =
      _$LeadCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      String name,
      @JsonKey(name: 'company') String? company,
      String? email,
      String? phone,
      String source,
      String status,
      @JsonKey(name: 'customer_id') String? customerId,
      @JsonKey(name: 'estimated_value') double? estimatedValue,
      @JsonKey(name: 'potential_products') List<String>? potentialProducts,
      String? notes,
      @JsonKey(name: 'converted_at') DateTime? convertedAt,
      String? address,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'sales_id') String? salesId,
      @JsonKey(name: 'salesman_name') String? salesmanName});
}

/// @nodoc
class _$LeadCopyWithImpl<$Res> implements $LeadCopyWith<$Res> {
  _$LeadCopyWithImpl(this._self, this._then);

  final Lead _self;
  final $Res Function(Lead) _then;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? name = null,
    Object? company = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? source = null,
    Object? status = null,
    Object? customerId = freezed,
    Object? estimatedValue = freezed,
    Object? potentialProducts = freezed,
    Object? notes = freezed,
    Object? convertedAt = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? salesId = freezed,
    Object? salesmanName = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      company: freezed == company
          ? _self.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedValue: freezed == estimatedValue
          ? _self.estimatedValue
          : estimatedValue // ignore: cast_nullable_to_non_nullable
              as double?,
      potentialProducts: freezed == potentialProducts
          ? _self.potentialProducts
          : potentialProducts // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      convertedAt: freezed == convertedAt
          ? _self.convertedAt
          : convertedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      salesId: freezed == salesId
          ? _self.salesId
          : salesId // ignore: cast_nullable_to_non_nullable
              as String?,
      salesmanName: freezed == salesmanName
          ? _self.salesmanName
          : salesmanName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Lead].
extension LeadPatterns on Lead {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Lead value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Lead() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Lead value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Lead():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Lead value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Lead() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String title,
            String name,
            @JsonKey(name: 'company') String? company,
            String? email,
            String? phone,
            String source,
            String status,
            @JsonKey(name: 'customer_id') String? customerId,
            @JsonKey(name: 'estimated_value') double? estimatedValue,
            @JsonKey(name: 'potential_products')
            List<String>? potentialProducts,
            String? notes,
            @JsonKey(name: 'converted_at') DateTime? convertedAt,
            String? address,
            double? latitude,
            double? longitude,
            @JsonKey(name: 'sales_id') String? salesId,
            @JsonKey(name: 'salesman_name') String? salesmanName)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Lead() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.name,
            _that.company,
            _that.email,
            _that.phone,
            _that.source,
            _that.status,
            _that.customerId,
            _that.estimatedValue,
            _that.potentialProducts,
            _that.notes,
            _that.convertedAt,
            _that.address,
            _that.latitude,
            _that.longitude,
            _that.salesId,
            _that.salesmanName);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String title,
            String name,
            @JsonKey(name: 'company') String? company,
            String? email,
            String? phone,
            String source,
            String status,
            @JsonKey(name: 'customer_id') String? customerId,
            @JsonKey(name: 'estimated_value') double? estimatedValue,
            @JsonKey(name: 'potential_products')
            List<String>? potentialProducts,
            String? notes,
            @JsonKey(name: 'converted_at') DateTime? convertedAt,
            String? address,
            double? latitude,
            double? longitude,
            @JsonKey(name: 'sales_id') String? salesId,
            @JsonKey(name: 'salesman_name') String? salesmanName)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Lead():
        return $default(
            _that.id,
            _that.title,
            _that.name,
            _that.company,
            _that.email,
            _that.phone,
            _that.source,
            _that.status,
            _that.customerId,
            _that.estimatedValue,
            _that.potentialProducts,
            _that.notes,
            _that.convertedAt,
            _that.address,
            _that.latitude,
            _that.longitude,
            _that.salesId,
            _that.salesmanName);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String title,
            String name,
            @JsonKey(name: 'company') String? company,
            String? email,
            String? phone,
            String source,
            String status,
            @JsonKey(name: 'customer_id') String? customerId,
            @JsonKey(name: 'estimated_value') double? estimatedValue,
            @JsonKey(name: 'potential_products')
            List<String>? potentialProducts,
            String? notes,
            @JsonKey(name: 'converted_at') DateTime? convertedAt,
            String? address,
            double? latitude,
            double? longitude,
            @JsonKey(name: 'sales_id') String? salesId,
            @JsonKey(name: 'salesman_name') String? salesmanName)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Lead() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.name,
            _that.company,
            _that.email,
            _that.phone,
            _that.source,
            _that.status,
            _that.customerId,
            _that.estimatedValue,
            _that.potentialProducts,
            _that.notes,
            _that.convertedAt,
            _that.address,
            _that.latitude,
            _that.longitude,
            _that.salesId,
            _that.salesmanName);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Lead implements Lead {
  const _Lead(
      {required this.id,
      required this.title,
      required this.name,
      @JsonKey(name: 'company') this.company,
      this.email,
      this.phone,
      required this.source,
      required this.status,
      @JsonKey(name: 'customer_id') this.customerId,
      @JsonKey(name: 'estimated_value') this.estimatedValue,
      @JsonKey(name: 'potential_products')
      final List<String>? potentialProducts,
      this.notes,
      @JsonKey(name: 'converted_at') this.convertedAt,
      this.address,
      this.latitude,
      this.longitude,
      @JsonKey(name: 'sales_id') this.salesId,
      @JsonKey(name: 'salesman_name') this.salesmanName})
      : _potentialProducts = potentialProducts;
  factory _Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String name;
  @override
  @JsonKey(name: 'company')
  final String? company;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String source;
  @override
  final String status;
  @override
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @override
  @JsonKey(name: 'estimated_value')
  final double? estimatedValue;
  final List<String>? _potentialProducts;
  @override
  @JsonKey(name: 'potential_products')
  List<String>? get potentialProducts {
    final value = _potentialProducts;
    if (value == null) return null;
    if (_potentialProducts is EqualUnmodifiableListView)
      return _potentialProducts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? notes;
  @override
  @JsonKey(name: 'converted_at')
  final DateTime? convertedAt;
  @override
  final String? address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey(name: 'sales_id')
  final String? salesId;
  @override
  @JsonKey(name: 'salesman_name')
  final String? salesmanName;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LeadCopyWith<_Lead> get copyWith =>
      __$LeadCopyWithImpl<_Lead>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LeadToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Lead &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.estimatedValue, estimatedValue) ||
                other.estimatedValue == estimatedValue) &&
            const DeepCollectionEquality()
                .equals(other._potentialProducts, _potentialProducts) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.convertedAt, convertedAt) ||
                other.convertedAt == convertedAt) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.salesId, salesId) || other.salesId == salesId) &&
            (identical(other.salesmanName, salesmanName) ||
                other.salesmanName == salesmanName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      name,
      company,
      email,
      phone,
      source,
      status,
      customerId,
      estimatedValue,
      const DeepCollectionEquality().hash(_potentialProducts),
      notes,
      convertedAt,
      address,
      latitude,
      longitude,
      salesId,
      salesmanName);

  @override
  String toString() {
    return 'Lead(id: $id, title: $title, name: $name, company: $company, email: $email, phone: $phone, source: $source, status: $status, customerId: $customerId, estimatedValue: $estimatedValue, potentialProducts: $potentialProducts, notes: $notes, convertedAt: $convertedAt, address: $address, latitude: $latitude, longitude: $longitude, salesId: $salesId, salesmanName: $salesmanName)';
  }
}

/// @nodoc
abstract mixin class _$LeadCopyWith<$Res> implements $LeadCopyWith<$Res> {
  factory _$LeadCopyWith(_Lead value, $Res Function(_Lead) _then) =
      __$LeadCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String name,
      @JsonKey(name: 'company') String? company,
      String? email,
      String? phone,
      String source,
      String status,
      @JsonKey(name: 'customer_id') String? customerId,
      @JsonKey(name: 'estimated_value') double? estimatedValue,
      @JsonKey(name: 'potential_products') List<String>? potentialProducts,
      String? notes,
      @JsonKey(name: 'converted_at') DateTime? convertedAt,
      String? address,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'sales_id') String? salesId,
      @JsonKey(name: 'salesman_name') String? salesmanName});
}

/// @nodoc
class __$LeadCopyWithImpl<$Res> implements _$LeadCopyWith<$Res> {
  __$LeadCopyWithImpl(this._self, this._then);

  final _Lead _self;
  final $Res Function(_Lead) _then;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? name = null,
    Object? company = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? source = null,
    Object? status = null,
    Object? customerId = freezed,
    Object? estimatedValue = freezed,
    Object? potentialProducts = freezed,
    Object? notes = freezed,
    Object? convertedAt = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? salesId = freezed,
    Object? salesmanName = freezed,
  }) {
    return _then(_Lead(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      company: freezed == company
          ? _self.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedValue: freezed == estimatedValue
          ? _self.estimatedValue
          : estimatedValue // ignore: cast_nullable_to_non_nullable
              as double?,
      potentialProducts: freezed == potentialProducts
          ? _self._potentialProducts
          : potentialProducts // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      convertedAt: freezed == convertedAt
          ? _self.convertedAt
          : convertedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      salesId: freezed == salesId
          ? _self.salesId
          : salesId // ignore: cast_nullable_to_non_nullable
              as String?,
      salesmanName: freezed == salesmanName
          ? _self.salesmanName
          : salesmanName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
