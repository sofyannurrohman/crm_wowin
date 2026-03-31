// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Deal {
  String get id;
  String get title;
  @JsonKey(name: 'customer_id')
  String get customerId;
  @JsonKey(name: 'contact_id')
  String? get contactId;
  String get stage;
  String get status;
  double? get amount;
  int? get probability;
  @JsonKey(name: 'expected_close')
  DateTime? get expectedClose;
  String? get description;
  List<DealItem>? get items;
  Customer? get customer;

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DealCopyWith<Deal> get copyWith =>
      _$DealCopyWithImpl<Deal>(this as Deal, _$identity);

  /// Serializes this Deal to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Deal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.contactId, contactId) ||
                other.contactId == contactId) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.probability, probability) ||
                other.probability == probability) &&
            (identical(other.expectedClose, expectedClose) ||
                other.expectedClose == expectedClose) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.items, items) &&
            (identical(other.customer, customer) ||
                other.customer == customer));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      customerId,
      contactId,
      stage,
      status,
      amount,
      probability,
      expectedClose,
      description,
      const DeepCollectionEquality().hash(items),
      customer);

  @override
  String toString() {
    return 'Deal(id: $id, title: $title, customerId: $customerId, contactId: $contactId, stage: $stage, status: $status, amount: $amount, probability: $probability, expectedClose: $expectedClose, description: $description, items: $items, customer: $customer)';
  }
}

/// @nodoc
abstract mixin class $DealCopyWith<$Res> {
  factory $DealCopyWith(Deal value, $Res Function(Deal) _then) =
      _$DealCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'customer_id') String customerId,
      @JsonKey(name: 'contact_id') String? contactId,
      String stage,
      String status,
      double? amount,
      int? probability,
      @JsonKey(name: 'expected_close') DateTime? expectedClose,
      String? description,
      List<DealItem>? items,
      Customer? customer});

  $CustomerCopyWith<$Res>? get customer;
}

/// @nodoc
class _$DealCopyWithImpl<$Res> implements $DealCopyWith<$Res> {
  _$DealCopyWithImpl(this._self, this._then);

  final Deal _self;
  final $Res Function(Deal) _then;

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? customerId = null,
    Object? contactId = freezed,
    Object? stage = null,
    Object? status = null,
    Object? amount = freezed,
    Object? probability = freezed,
    Object? expectedClose = freezed,
    Object? description = freezed,
    Object? items = freezed,
    Object? customer = freezed,
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
      customerId: null == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      contactId: freezed == contactId
          ? _self.contactId
          : contactId // ignore: cast_nullable_to_non_nullable
              as String?,
      stage: null == stage
          ? _self.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      probability: freezed == probability
          ? _self.probability
          : probability // ignore: cast_nullable_to_non_nullable
              as int?,
      expectedClose: freezed == expectedClose
          ? _self.expectedClose
          : expectedClose // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      items: freezed == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DealItem>?,
      customer: freezed == customer
          ? _self.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as Customer?,
    ));
  }

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomerCopyWith<$Res>? get customer {
    if (_self.customer == null) {
      return null;
    }

    return $CustomerCopyWith<$Res>(_self.customer!, (value) {
      return _then(_self.copyWith(customer: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Deal].
extension DealPatterns on Deal {
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
    TResult Function(_Deal value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Deal() when $default != null:
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
    TResult Function(_Deal value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Deal():
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
    TResult? Function(_Deal value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Deal() when $default != null:
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
            @JsonKey(name: 'customer_id') String customerId,
            @JsonKey(name: 'contact_id') String? contactId,
            String stage,
            String status,
            double? amount,
            int? probability,
            @JsonKey(name: 'expected_close') DateTime? expectedClose,
            String? description,
            List<DealItem>? items,
            Customer? customer)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Deal() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.customerId,
            _that.contactId,
            _that.stage,
            _that.status,
            _that.amount,
            _that.probability,
            _that.expectedClose,
            _that.description,
            _that.items,
            _that.customer);
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
            @JsonKey(name: 'customer_id') String customerId,
            @JsonKey(name: 'contact_id') String? contactId,
            String stage,
            String status,
            double? amount,
            int? probability,
            @JsonKey(name: 'expected_close') DateTime? expectedClose,
            String? description,
            List<DealItem>? items,
            Customer? customer)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Deal():
        return $default(
            _that.id,
            _that.title,
            _that.customerId,
            _that.contactId,
            _that.stage,
            _that.status,
            _that.amount,
            _that.probability,
            _that.expectedClose,
            _that.description,
            _that.items,
            _that.customer);
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
            @JsonKey(name: 'customer_id') String customerId,
            @JsonKey(name: 'contact_id') String? contactId,
            String stage,
            String status,
            double? amount,
            int? probability,
            @JsonKey(name: 'expected_close') DateTime? expectedClose,
            String? description,
            List<DealItem>? items,
            Customer? customer)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Deal() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.customerId,
            _that.contactId,
            _that.stage,
            _that.status,
            _that.amount,
            _that.probability,
            _that.expectedClose,
            _that.description,
            _that.items,
            _that.customer);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Deal implements Deal {
  const _Deal(
      {required this.id,
      required this.title,
      @JsonKey(name: 'customer_id') required this.customerId,
      @JsonKey(name: 'contact_id') this.contactId,
      required this.stage,
      required this.status,
      this.amount,
      this.probability,
      @JsonKey(name: 'expected_close') this.expectedClose,
      this.description,
      final List<DealItem>? items,
      this.customer})
      : _items = items;
  factory _Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey(name: 'customer_id')
  final String customerId;
  @override
  @JsonKey(name: 'contact_id')
  final String? contactId;
  @override
  final String stage;
  @override
  final String status;
  @override
  final double? amount;
  @override
  final int? probability;
  @override
  @JsonKey(name: 'expected_close')
  final DateTime? expectedClose;
  @override
  final String? description;
  final List<DealItem>? _items;
  @override
  List<DealItem>? get items {
    final value = _items;
    if (value == null) return null;
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Customer? customer;

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DealCopyWith<_Deal> get copyWith =>
      __$DealCopyWithImpl<_Deal>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DealToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Deal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.contactId, contactId) ||
                other.contactId == contactId) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.probability, probability) ||
                other.probability == probability) &&
            (identical(other.expectedClose, expectedClose) ||
                other.expectedClose == expectedClose) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.customer, customer) ||
                other.customer == customer));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      customerId,
      contactId,
      stage,
      status,
      amount,
      probability,
      expectedClose,
      description,
      const DeepCollectionEquality().hash(_items),
      customer);

  @override
  String toString() {
    return 'Deal(id: $id, title: $title, customerId: $customerId, contactId: $contactId, stage: $stage, status: $status, amount: $amount, probability: $probability, expectedClose: $expectedClose, description: $description, items: $items, customer: $customer)';
  }
}

/// @nodoc
abstract mixin class _$DealCopyWith<$Res> implements $DealCopyWith<$Res> {
  factory _$DealCopyWith(_Deal value, $Res Function(_Deal) _then) =
      __$DealCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'customer_id') String customerId,
      @JsonKey(name: 'contact_id') String? contactId,
      String stage,
      String status,
      double? amount,
      int? probability,
      @JsonKey(name: 'expected_close') DateTime? expectedClose,
      String? description,
      List<DealItem>? items,
      Customer? customer});

  @override
  $CustomerCopyWith<$Res>? get customer;
}

/// @nodoc
class __$DealCopyWithImpl<$Res> implements _$DealCopyWith<$Res> {
  __$DealCopyWithImpl(this._self, this._then);

  final _Deal _self;
  final $Res Function(_Deal) _then;

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? customerId = null,
    Object? contactId = freezed,
    Object? stage = null,
    Object? status = null,
    Object? amount = freezed,
    Object? probability = freezed,
    Object? expectedClose = freezed,
    Object? description = freezed,
    Object? items = freezed,
    Object? customer = freezed,
  }) {
    return _then(_Deal(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      contactId: freezed == contactId
          ? _self.contactId
          : contactId // ignore: cast_nullable_to_non_nullable
              as String?,
      stage: null == stage
          ? _self.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      probability: freezed == probability
          ? _self.probability
          : probability // ignore: cast_nullable_to_non_nullable
              as int?,
      expectedClose: freezed == expectedClose
          ? _self.expectedClose
          : expectedClose // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      items: freezed == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DealItem>?,
      customer: freezed == customer
          ? _self.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as Customer?,
    ));
  }

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomerCopyWith<$Res>? get customer {
    if (_self.customer == null) {
      return null;
    }

    return $CustomerCopyWith<$Res>(_self.customer!, (value) {
      return _then(_self.copyWith(customer: value));
    });
  }
}

// dart format on
