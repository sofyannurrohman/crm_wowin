// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Invoice {

 String get id;@JsonKey(name: 'customer_id') String get customerId;@JsonKey(name: 'deal_id') String? get dealId;@JsonKey(name: 'invoice_no') String get invoiceNo; double get amount;@JsonKey(name: 'paid_amount') double get paidAmount; InvoiceStatus get status;@JsonKey(name: 'due_at') DateTime? get dueAt;@JsonKey(name: 'signature_path') String? get signaturePath;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt; List<InvoiceItem> get items;
/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceCopyWith<Invoice> get copyWith => _$InvoiceCopyWithImpl<Invoice>(this as Invoice, _$identity);

  /// Serializes this Invoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.dealId, dealId) || other.dealId == dealId)&&(identical(other.invoiceNo, invoiceNo) || other.invoiceNo == invoiceNo)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.signaturePath, signaturePath) || other.signaturePath == signaturePath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,dealId,invoiceNo,amount,paidAmount,status,dueAt,signaturePath,createdAt,updatedAt,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'Invoice(id: $id, customerId: $customerId, dealId: $dealId, invoiceNo: $invoiceNo, amount: $amount, paidAmount: $paidAmount, status: $status, dueAt: $dueAt, signaturePath: $signaturePath, createdAt: $createdAt, updatedAt: $updatedAt, items: $items)';
}


}

/// @nodoc
abstract mixin class $InvoiceCopyWith<$Res>  {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) _then) = _$InvoiceCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'customer_id') String customerId,@JsonKey(name: 'deal_id') String? dealId,@JsonKey(name: 'invoice_no') String invoiceNo, double amount,@JsonKey(name: 'paid_amount') double paidAmount, InvoiceStatus status,@JsonKey(name: 'due_at') DateTime? dueAt,@JsonKey(name: 'signature_path') String? signaturePath,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt, List<InvoiceItem> items
});




}
/// @nodoc
class _$InvoiceCopyWithImpl<$Res>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._self, this._then);

  final Invoice _self;
  final $Res Function(Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerId = null,Object? dealId = freezed,Object? invoiceNo = null,Object? amount = null,Object? paidAmount = null,Object? status = null,Object? dueAt = freezed,Object? signaturePath = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,dealId: freezed == dealId ? _self.dealId : dealId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNo: null == invoiceNo ? _self.invoiceNo : invoiceNo // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,signaturePath: freezed == signaturePath ? _self.signaturePath : signaturePath // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<InvoiceItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Invoice].
extension InvoicePatterns on Invoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invoice value)  $default,){
final _that = this;
switch (_that) {
case _Invoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invoice value)?  $default,){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'deal_id')  String? dealId, @JsonKey(name: 'invoice_no')  String invoiceNo,  double amount, @JsonKey(name: 'paid_amount')  double paidAmount,  InvoiceStatus status, @JsonKey(name: 'due_at')  DateTime? dueAt, @JsonKey(name: 'signature_path')  String? signaturePath, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  List<InvoiceItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.customerId,_that.dealId,_that.invoiceNo,_that.amount,_that.paidAmount,_that.status,_that.dueAt,_that.signaturePath,_that.createdAt,_that.updatedAt,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'deal_id')  String? dealId, @JsonKey(name: 'invoice_no')  String invoiceNo,  double amount, @JsonKey(name: 'paid_amount')  double paidAmount,  InvoiceStatus status, @JsonKey(name: 'due_at')  DateTime? dueAt, @JsonKey(name: 'signature_path')  String? signaturePath, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  List<InvoiceItem> items)  $default,) {final _that = this;
switch (_that) {
case _Invoice():
return $default(_that.id,_that.customerId,_that.dealId,_that.invoiceNo,_that.amount,_that.paidAmount,_that.status,_that.dueAt,_that.signaturePath,_that.createdAt,_that.updatedAt,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'deal_id')  String? dealId, @JsonKey(name: 'invoice_no')  String invoiceNo,  double amount, @JsonKey(name: 'paid_amount')  double paidAmount,  InvoiceStatus status, @JsonKey(name: 'due_at')  DateTime? dueAt, @JsonKey(name: 'signature_path')  String? signaturePath, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  List<InvoiceItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.customerId,_that.dealId,_that.invoiceNo,_that.amount,_that.paidAmount,_that.status,_that.dueAt,_that.signaturePath,_that.createdAt,_that.updatedAt,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invoice implements Invoice {
  const _Invoice({required this.id, @JsonKey(name: 'customer_id') required this.customerId, @JsonKey(name: 'deal_id') this.dealId, @JsonKey(name: 'invoice_no') required this.invoiceNo, required this.amount, @JsonKey(name: 'paid_amount') required this.paidAmount, required this.status, @JsonKey(name: 'due_at') this.dueAt, @JsonKey(name: 'signature_path') this.signaturePath, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, final  List<InvoiceItem> items = const []}): _items = items;
  factory _Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

@override final  String id;
@override@JsonKey(name: 'customer_id') final  String customerId;
@override@JsonKey(name: 'deal_id') final  String? dealId;
@override@JsonKey(name: 'invoice_no') final  String invoiceNo;
@override final  double amount;
@override@JsonKey(name: 'paid_amount') final  double paidAmount;
@override final  InvoiceStatus status;
@override@JsonKey(name: 'due_at') final  DateTime? dueAt;
@override@JsonKey(name: 'signature_path') final  String? signaturePath;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
 final  List<InvoiceItem> _items;
@override@JsonKey() List<InvoiceItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceCopyWith<_Invoice> get copyWith => __$InvoiceCopyWithImpl<_Invoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.dealId, dealId) || other.dealId == dealId)&&(identical(other.invoiceNo, invoiceNo) || other.invoiceNo == invoiceNo)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.signaturePath, signaturePath) || other.signaturePath == signaturePath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,dealId,invoiceNo,amount,paidAmount,status,dueAt,signaturePath,createdAt,updatedAt,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'Invoice(id: $id, customerId: $customerId, dealId: $dealId, invoiceNo: $invoiceNo, amount: $amount, paidAmount: $paidAmount, status: $status, dueAt: $dueAt, signaturePath: $signaturePath, createdAt: $createdAt, updatedAt: $updatedAt, items: $items)';
}


}

/// @nodoc
abstract mixin class _$InvoiceCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$InvoiceCopyWith(_Invoice value, $Res Function(_Invoice) _then) = __$InvoiceCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'customer_id') String customerId,@JsonKey(name: 'deal_id') String? dealId,@JsonKey(name: 'invoice_no') String invoiceNo, double amount,@JsonKey(name: 'paid_amount') double paidAmount, InvoiceStatus status,@JsonKey(name: 'due_at') DateTime? dueAt,@JsonKey(name: 'signature_path') String? signaturePath,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt, List<InvoiceItem> items
});




}
/// @nodoc
class __$InvoiceCopyWithImpl<$Res>
    implements _$InvoiceCopyWith<$Res> {
  __$InvoiceCopyWithImpl(this._self, this._then);

  final _Invoice _self;
  final $Res Function(_Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerId = null,Object? dealId = freezed,Object? invoiceNo = null,Object? amount = null,Object? paidAmount = null,Object? status = null,Object? dueAt = freezed,Object? signaturePath = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? items = null,}) {
  return _then(_Invoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,dealId: freezed == dealId ? _self.dealId : dealId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNo: null == invoiceNo ? _self.invoiceNo : invoiceNo // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,signaturePath: freezed == signaturePath ? _self.signaturePath : signaturePath // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<InvoiceItem>,
  ));
}


}


/// @nodoc
mixin _$InvoiceItem {

 String get id;@JsonKey(name: 'invoice_id') String get invoiceId;@JsonKey(name: 'product_id') String get productId; String get name; double get quantity; String get unit;@JsonKey(name: 'unit_price') double get unitPrice; double get subtotal;
/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceItemCopyWith<InvoiceItem> get copyWith => _$InvoiceItemCopyWithImpl<InvoiceItem>(this as InvoiceItem, _$identity);

  /// Serializes this InvoiceItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceItem&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,invoiceId,productId,name,quantity,unit,unitPrice,subtotal);

@override
String toString() {
  return 'InvoiceItem(id: $id, invoiceId: $invoiceId, productId: $productId, name: $name, quantity: $quantity, unit: $unit, unitPrice: $unitPrice, subtotal: $subtotal)';
}


}

/// @nodoc
abstract mixin class $InvoiceItemCopyWith<$Res>  {
  factory $InvoiceItemCopyWith(InvoiceItem value, $Res Function(InvoiceItem) _then) = _$InvoiceItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'invoice_id') String invoiceId,@JsonKey(name: 'product_id') String productId, String name, double quantity, String unit,@JsonKey(name: 'unit_price') double unitPrice, double subtotal
});




}
/// @nodoc
class _$InvoiceItemCopyWithImpl<$Res>
    implements $InvoiceItemCopyWith<$Res> {
  _$InvoiceItemCopyWithImpl(this._self, this._then);

  final InvoiceItem _self;
  final $Res Function(InvoiceItem) _then;

/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? invoiceId = null,Object? productId = null,Object? name = null,Object? quantity = null,Object? unit = null,Object? unitPrice = null,Object? subtotal = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceItem].
extension InvoiceItemPatterns on InvoiceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceItem value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceItem value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'invoice_id')  String invoiceId, @JsonKey(name: 'product_id')  String productId,  String name,  double quantity,  String unit, @JsonKey(name: 'unit_price')  double unitPrice,  double subtotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
return $default(_that.id,_that.invoiceId,_that.productId,_that.name,_that.quantity,_that.unit,_that.unitPrice,_that.subtotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'invoice_id')  String invoiceId, @JsonKey(name: 'product_id')  String productId,  String name,  double quantity,  String unit, @JsonKey(name: 'unit_price')  double unitPrice,  double subtotal)  $default,) {final _that = this;
switch (_that) {
case _InvoiceItem():
return $default(_that.id,_that.invoiceId,_that.productId,_that.name,_that.quantity,_that.unit,_that.unitPrice,_that.subtotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'invoice_id')  String invoiceId, @JsonKey(name: 'product_id')  String productId,  String name,  double quantity,  String unit, @JsonKey(name: 'unit_price')  double unitPrice,  double subtotal)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
return $default(_that.id,_that.invoiceId,_that.productId,_that.name,_that.quantity,_that.unit,_that.unitPrice,_that.subtotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoiceItem implements InvoiceItem {
  const _InvoiceItem({required this.id, @JsonKey(name: 'invoice_id') required this.invoiceId, @JsonKey(name: 'product_id') required this.productId, required this.name, required this.quantity, required this.unit, @JsonKey(name: 'unit_price') required this.unitPrice, required this.subtotal});
  factory _InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'invoice_id') final  String invoiceId;
@override@JsonKey(name: 'product_id') final  String productId;
@override final  String name;
@override final  double quantity;
@override final  String unit;
@override@JsonKey(name: 'unit_price') final  double unitPrice;
@override final  double subtotal;

/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceItemCopyWith<_InvoiceItem> get copyWith => __$InvoiceItemCopyWithImpl<_InvoiceItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceItem&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,invoiceId,productId,name,quantity,unit,unitPrice,subtotal);

@override
String toString() {
  return 'InvoiceItem(id: $id, invoiceId: $invoiceId, productId: $productId, name: $name, quantity: $quantity, unit: $unit, unitPrice: $unitPrice, subtotal: $subtotal)';
}


}

/// @nodoc
abstract mixin class _$InvoiceItemCopyWith<$Res> implements $InvoiceItemCopyWith<$Res> {
  factory _$InvoiceItemCopyWith(_InvoiceItem value, $Res Function(_InvoiceItem) _then) = __$InvoiceItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'invoice_id') String invoiceId,@JsonKey(name: 'product_id') String productId, String name, double quantity, String unit,@JsonKey(name: 'unit_price') double unitPrice, double subtotal
});




}
/// @nodoc
class __$InvoiceItemCopyWithImpl<$Res>
    implements _$InvoiceItemCopyWith<$Res> {
  __$InvoiceItemCopyWithImpl(this._self, this._then);

  final _InvoiceItem _self;
  final $Res Function(_InvoiceItem) _then;

/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? invoiceId = null,Object? productId = null,Object? name = null,Object? quantity = null,Object? unit = null,Object? unitPrice = null,Object? subtotal = null,}) {
  return _then(_InvoiceItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
