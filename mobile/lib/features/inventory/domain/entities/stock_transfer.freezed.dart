// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_transfer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StockTransfer {

 String get id;@JsonKey(name: 'warehouse_id') String get warehouseId;@JsonKey(name: 'sales_id') String get salesId; StockTransferType get type; StockTransferStatus get status; String? get notes;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt; List<StockTransferItem> get items;
/// Create a copy of StockTransfer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockTransferCopyWith<StockTransfer> get copyWith => _$StockTransferCopyWithImpl<StockTransfer>(this as StockTransfer, _$identity);

  /// Serializes this StockTransfer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockTransfer&&(identical(other.id, id) || other.id == id)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.salesId, salesId) || other.salesId == salesId)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,warehouseId,salesId,type,status,notes,createdAt,updatedAt,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'StockTransfer(id: $id, warehouseId: $warehouseId, salesId: $salesId, type: $type, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, items: $items)';
}


}

/// @nodoc
abstract mixin class $StockTransferCopyWith<$Res>  {
  factory $StockTransferCopyWith(StockTransfer value, $Res Function(StockTransfer) _then) = _$StockTransferCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'warehouse_id') String warehouseId,@JsonKey(name: 'sales_id') String salesId, StockTransferType type, StockTransferStatus status, String? notes,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt, List<StockTransferItem> items
});




}
/// @nodoc
class _$StockTransferCopyWithImpl<$Res>
    implements $StockTransferCopyWith<$Res> {
  _$StockTransferCopyWithImpl(this._self, this._then);

  final StockTransfer _self;
  final $Res Function(StockTransfer) _then;

/// Create a copy of StockTransfer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? warehouseId = null,Object? salesId = null,Object? type = null,Object? status = null,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,salesId: null == salesId ? _self.salesId : salesId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as StockTransferType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StockTransferStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<StockTransferItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [StockTransfer].
extension StockTransferPatterns on StockTransfer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockTransfer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockTransfer() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockTransfer value)  $default,){
final _that = this;
switch (_that) {
case _StockTransfer():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockTransfer value)?  $default,){
final _that = this;
switch (_that) {
case _StockTransfer() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'warehouse_id')  String warehouseId, @JsonKey(name: 'sales_id')  String salesId,  StockTransferType type,  StockTransferStatus status,  String? notes, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  List<StockTransferItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockTransfer() when $default != null:
return $default(_that.id,_that.warehouseId,_that.salesId,_that.type,_that.status,_that.notes,_that.createdAt,_that.updatedAt,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'warehouse_id')  String warehouseId, @JsonKey(name: 'sales_id')  String salesId,  StockTransferType type,  StockTransferStatus status,  String? notes, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  List<StockTransferItem> items)  $default,) {final _that = this;
switch (_that) {
case _StockTransfer():
return $default(_that.id,_that.warehouseId,_that.salesId,_that.type,_that.status,_that.notes,_that.createdAt,_that.updatedAt,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'warehouse_id')  String warehouseId, @JsonKey(name: 'sales_id')  String salesId,  StockTransferType type,  StockTransferStatus status,  String? notes, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  List<StockTransferItem> items)?  $default,) {final _that = this;
switch (_that) {
case _StockTransfer() when $default != null:
return $default(_that.id,_that.warehouseId,_that.salesId,_that.type,_that.status,_that.notes,_that.createdAt,_that.updatedAt,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockTransfer implements StockTransfer {
  const _StockTransfer({required this.id, @JsonKey(name: 'warehouse_id') required this.warehouseId, @JsonKey(name: 'sales_id') required this.salesId, required this.type, required this.status, this.notes, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, final  List<StockTransferItem> items = const []}): _items = items;
  factory _StockTransfer.fromJson(Map<String, dynamic> json) => _$StockTransferFromJson(json);

@override final  String id;
@override@JsonKey(name: 'warehouse_id') final  String warehouseId;
@override@JsonKey(name: 'sales_id') final  String salesId;
@override final  StockTransferType type;
@override final  StockTransferStatus status;
@override final  String? notes;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
 final  List<StockTransferItem> _items;
@override@JsonKey() List<StockTransferItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of StockTransfer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockTransferCopyWith<_StockTransfer> get copyWith => __$StockTransferCopyWithImpl<_StockTransfer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockTransferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockTransfer&&(identical(other.id, id) || other.id == id)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.salesId, salesId) || other.salesId == salesId)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,warehouseId,salesId,type,status,notes,createdAt,updatedAt,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'StockTransfer(id: $id, warehouseId: $warehouseId, salesId: $salesId, type: $type, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, items: $items)';
}


}

/// @nodoc
abstract mixin class _$StockTransferCopyWith<$Res> implements $StockTransferCopyWith<$Res> {
  factory _$StockTransferCopyWith(_StockTransfer value, $Res Function(_StockTransfer) _then) = __$StockTransferCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'warehouse_id') String warehouseId,@JsonKey(name: 'sales_id') String salesId, StockTransferType type, StockTransferStatus status, String? notes,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt, List<StockTransferItem> items
});




}
/// @nodoc
class __$StockTransferCopyWithImpl<$Res>
    implements _$StockTransferCopyWith<$Res> {
  __$StockTransferCopyWithImpl(this._self, this._then);

  final _StockTransfer _self;
  final $Res Function(_StockTransfer) _then;

/// Create a copy of StockTransfer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? warehouseId = null,Object? salesId = null,Object? type = null,Object? status = null,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? items = null,}) {
  return _then(_StockTransfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,salesId: null == salesId ? _self.salesId : salesId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as StockTransferType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StockTransferStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<StockTransferItem>,
  ));
}


}


/// @nodoc
mixin _$StockTransferItem {

 String get id;@JsonKey(name: 'transfer_id') String get transferId;@JsonKey(name: 'product_id') String get productId; double get quantity;@JsonKey(name: 'product_name') String? get productName;@JsonKey(name: 'product_unit') String? get productUnit;
/// Create a copy of StockTransferItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockTransferItemCopyWith<StockTransferItem> get copyWith => _$StockTransferItemCopyWithImpl<StockTransferItem>(this as StockTransferItem, _$identity);

  /// Serializes this StockTransferItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockTransferItem&&(identical(other.id, id) || other.id == id)&&(identical(other.transferId, transferId) || other.transferId == transferId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productUnit, productUnit) || other.productUnit == productUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transferId,productId,quantity,productName,productUnit);

@override
String toString() {
  return 'StockTransferItem(id: $id, transferId: $transferId, productId: $productId, quantity: $quantity, productName: $productName, productUnit: $productUnit)';
}


}

/// @nodoc
abstract mixin class $StockTransferItemCopyWith<$Res>  {
  factory $StockTransferItemCopyWith(StockTransferItem value, $Res Function(StockTransferItem) _then) = _$StockTransferItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'transfer_id') String transferId,@JsonKey(name: 'product_id') String productId, double quantity,@JsonKey(name: 'product_name') String? productName,@JsonKey(name: 'product_unit') String? productUnit
});




}
/// @nodoc
class _$StockTransferItemCopyWithImpl<$Res>
    implements $StockTransferItemCopyWith<$Res> {
  _$StockTransferItemCopyWithImpl(this._self, this._then);

  final StockTransferItem _self;
  final $Res Function(StockTransferItem) _then;

/// Create a copy of StockTransferItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? transferId = null,Object? productId = null,Object? quantity = null,Object? productName = freezed,Object? productUnit = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transferId: null == transferId ? _self.transferId : transferId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productUnit: freezed == productUnit ? _self.productUnit : productUnit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StockTransferItem].
extension StockTransferItemPatterns on StockTransferItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockTransferItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockTransferItem() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockTransferItem value)  $default,){
final _that = this;
switch (_that) {
case _StockTransferItem():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockTransferItem value)?  $default,){
final _that = this;
switch (_that) {
case _StockTransferItem() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'transfer_id')  String transferId, @JsonKey(name: 'product_id')  String productId,  double quantity, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'product_unit')  String? productUnit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockTransferItem() when $default != null:
return $default(_that.id,_that.transferId,_that.productId,_that.quantity,_that.productName,_that.productUnit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'transfer_id')  String transferId, @JsonKey(name: 'product_id')  String productId,  double quantity, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'product_unit')  String? productUnit)  $default,) {final _that = this;
switch (_that) {
case _StockTransferItem():
return $default(_that.id,_that.transferId,_that.productId,_that.quantity,_that.productName,_that.productUnit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'transfer_id')  String transferId, @JsonKey(name: 'product_id')  String productId,  double quantity, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'product_unit')  String? productUnit)?  $default,) {final _that = this;
switch (_that) {
case _StockTransferItem() when $default != null:
return $default(_that.id,_that.transferId,_that.productId,_that.quantity,_that.productName,_that.productUnit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockTransferItem implements StockTransferItem {
  const _StockTransferItem({required this.id, @JsonKey(name: 'transfer_id') required this.transferId, @JsonKey(name: 'product_id') required this.productId, required this.quantity, @JsonKey(name: 'product_name') this.productName, @JsonKey(name: 'product_unit') this.productUnit});
  factory _StockTransferItem.fromJson(Map<String, dynamic> json) => _$StockTransferItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'transfer_id') final  String transferId;
@override@JsonKey(name: 'product_id') final  String productId;
@override final  double quantity;
@override@JsonKey(name: 'product_name') final  String? productName;
@override@JsonKey(name: 'product_unit') final  String? productUnit;

/// Create a copy of StockTransferItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockTransferItemCopyWith<_StockTransferItem> get copyWith => __$StockTransferItemCopyWithImpl<_StockTransferItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockTransferItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockTransferItem&&(identical(other.id, id) || other.id == id)&&(identical(other.transferId, transferId) || other.transferId == transferId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productUnit, productUnit) || other.productUnit == productUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transferId,productId,quantity,productName,productUnit);

@override
String toString() {
  return 'StockTransferItem(id: $id, transferId: $transferId, productId: $productId, quantity: $quantity, productName: $productName, productUnit: $productUnit)';
}


}

/// @nodoc
abstract mixin class _$StockTransferItemCopyWith<$Res> implements $StockTransferItemCopyWith<$Res> {
  factory _$StockTransferItemCopyWith(_StockTransferItem value, $Res Function(_StockTransferItem) _then) = __$StockTransferItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'transfer_id') String transferId,@JsonKey(name: 'product_id') String productId, double quantity,@JsonKey(name: 'product_name') String? productName,@JsonKey(name: 'product_unit') String? productUnit
});




}
/// @nodoc
class __$StockTransferItemCopyWithImpl<$Res>
    implements _$StockTransferItemCopyWith<$Res> {
  __$StockTransferItemCopyWithImpl(this._self, this._then);

  final _StockTransferItem _self;
  final $Res Function(_StockTransferItem) _then;

/// Create a copy of StockTransferItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? transferId = null,Object? productId = null,Object? quantity = null,Object? productName = freezed,Object? productUnit = freezed,}) {
  return _then(_StockTransferItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transferId: null == transferId ? _self.transferId : transferId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productUnit: freezed == productUnit ? _self.productUnit : productUnit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
