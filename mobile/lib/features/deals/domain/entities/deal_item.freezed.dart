// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deal_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DealItem {
  String get id;
  @JsonKey(name: 'deal_id')
  String get dealId;
  @JsonKey(name: 'product_id')
  String get productId;
  int get quantity;
  @JsonKey(name: 'unit_price')
  double get unitPrice;
  double get discount;
  double get subtotal;
  String? get notes;
  @JsonKey(name: 'product_name')
  String? get productName;
  @JsonKey(name: 'product_sku')
  String? get productSku;

  /// Create a copy of DealItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DealItemCopyWith<DealItem> get copyWith =>
      _$DealItemCopyWithImpl<DealItem>(this as DealItem, _$identity);

  /// Serializes this DealItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DealItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dealId, dealId) || other.dealId == dealId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productSku, productSku) ||
                other.productSku == productSku));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, dealId, productId, quantity,
      unitPrice, discount, subtotal, notes, productName, productSku);

  @override
  String toString() {
    return 'DealItem(id: $id, dealId: $dealId, productId: $productId, quantity: $quantity, unitPrice: $unitPrice, discount: $discount, subtotal: $subtotal, notes: $notes, productName: $productName, productSku: $productSku)';
  }
}

/// @nodoc
abstract mixin class $DealItemCopyWith<$Res> {
  factory $DealItemCopyWith(DealItem value, $Res Function(DealItem) _then) =
      _$DealItemCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'deal_id') String dealId,
      @JsonKey(name: 'product_id') String productId,
      int quantity,
      @JsonKey(name: 'unit_price') double unitPrice,
      double discount,
      double subtotal,
      String? notes,
      @JsonKey(name: 'product_name') String? productName,
      @JsonKey(name: 'product_sku') String? productSku});
}

/// @nodoc
class _$DealItemCopyWithImpl<$Res> implements $DealItemCopyWith<$Res> {
  _$DealItemCopyWithImpl(this._self, this._then);

  final DealItem _self;
  final $Res Function(DealItem) _then;

  /// Create a copy of DealItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dealId = null,
    Object? productId = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? discount = null,
    Object? subtotal = null,
    Object? notes = freezed,
    Object? productName = freezed,
    Object? productSku = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      dealId: null == dealId
          ? _self.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _self.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _self.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      subtotal: null == subtotal
          ? _self.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      productName: freezed == productName
          ? _self.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String?,
      productSku: freezed == productSku
          ? _self.productSku
          : productSku // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [DealItem].
extension DealItemPatterns on DealItem {
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
    TResult Function(_DealItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DealItem() when $default != null:
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
    TResult Function(_DealItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DealItem():
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
    TResult? Function(_DealItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DealItem() when $default != null:
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
            @JsonKey(name: 'deal_id') String dealId,
            @JsonKey(name: 'product_id') String productId,
            int quantity,
            @JsonKey(name: 'unit_price') double unitPrice,
            double discount,
            double subtotal,
            String? notes,
            @JsonKey(name: 'product_name') String? productName,
            @JsonKey(name: 'product_sku') String? productSku)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DealItem() when $default != null:
        return $default(
            _that.id,
            _that.dealId,
            _that.productId,
            _that.quantity,
            _that.unitPrice,
            _that.discount,
            _that.subtotal,
            _that.notes,
            _that.productName,
            _that.productSku);
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
            @JsonKey(name: 'deal_id') String dealId,
            @JsonKey(name: 'product_id') String productId,
            int quantity,
            @JsonKey(name: 'unit_price') double unitPrice,
            double discount,
            double subtotal,
            String? notes,
            @JsonKey(name: 'product_name') String? productName,
            @JsonKey(name: 'product_sku') String? productSku)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DealItem():
        return $default(
            _that.id,
            _that.dealId,
            _that.productId,
            _that.quantity,
            _that.unitPrice,
            _that.discount,
            _that.subtotal,
            _that.notes,
            _that.productName,
            _that.productSku);
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
            @JsonKey(name: 'deal_id') String dealId,
            @JsonKey(name: 'product_id') String productId,
            int quantity,
            @JsonKey(name: 'unit_price') double unitPrice,
            double discount,
            double subtotal,
            String? notes,
            @JsonKey(name: 'product_name') String? productName,
            @JsonKey(name: 'product_sku') String? productSku)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DealItem() when $default != null:
        return $default(
            _that.id,
            _that.dealId,
            _that.productId,
            _that.quantity,
            _that.unitPrice,
            _that.discount,
            _that.subtotal,
            _that.notes,
            _that.productName,
            _that.productSku);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DealItem implements DealItem {
  const _DealItem(
      {required this.id,
      @JsonKey(name: 'deal_id') required this.dealId,
      @JsonKey(name: 'product_id') required this.productId,
      required this.quantity,
      @JsonKey(name: 'unit_price') required this.unitPrice,
      required this.discount,
      required this.subtotal,
      this.notes,
      @JsonKey(name: 'product_name') this.productName,
      @JsonKey(name: 'product_sku') this.productSku});
  factory _DealItem.fromJson(Map<String, dynamic> json) =>
      _$DealItemFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'deal_id')
  final String dealId;
  @override
  @JsonKey(name: 'product_id')
  final String productId;
  @override
  final int quantity;
  @override
  @JsonKey(name: 'unit_price')
  final double unitPrice;
  @override
  final double discount;
  @override
  final double subtotal;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'product_name')
  final String? productName;
  @override
  @JsonKey(name: 'product_sku')
  final String? productSku;

  /// Create a copy of DealItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DealItemCopyWith<_DealItem> get copyWith =>
      __$DealItemCopyWithImpl<_DealItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DealItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DealItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dealId, dealId) || other.dealId == dealId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productSku, productSku) ||
                other.productSku == productSku));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, dealId, productId, quantity,
      unitPrice, discount, subtotal, notes, productName, productSku);

  @override
  String toString() {
    return 'DealItem(id: $id, dealId: $dealId, productId: $productId, quantity: $quantity, unitPrice: $unitPrice, discount: $discount, subtotal: $subtotal, notes: $notes, productName: $productName, productSku: $productSku)';
  }
}

/// @nodoc
abstract mixin class _$DealItemCopyWith<$Res>
    implements $DealItemCopyWith<$Res> {
  factory _$DealItemCopyWith(_DealItem value, $Res Function(_DealItem) _then) =
      __$DealItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'deal_id') String dealId,
      @JsonKey(name: 'product_id') String productId,
      int quantity,
      @JsonKey(name: 'unit_price') double unitPrice,
      double discount,
      double subtotal,
      String? notes,
      @JsonKey(name: 'product_name') String? productName,
      @JsonKey(name: 'product_sku') String? productSku});
}

/// @nodoc
class __$DealItemCopyWithImpl<$Res> implements _$DealItemCopyWith<$Res> {
  __$DealItemCopyWithImpl(this._self, this._then);

  final _DealItem _self;
  final $Res Function(_DealItem) _then;

  /// Create a copy of DealItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? dealId = null,
    Object? productId = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? discount = null,
    Object? subtotal = null,
    Object? notes = freezed,
    Object? productName = freezed,
    Object? productSku = freezed,
  }) {
    return _then(_DealItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      dealId: null == dealId
          ? _self.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _self.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _self.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      subtotal: null == subtotal
          ? _self.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      productName: freezed == productName
          ? _self.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String?,
      productSku: freezed == productSku
          ? _self.productSku
          : productSku // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
