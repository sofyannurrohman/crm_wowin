// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InventoryEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'InventoryEvent()';
}


}

/// @nodoc
class $InventoryEventCopyWith<$Res>  {
$InventoryEventCopyWith(InventoryEvent _, $Res Function(InventoryEvent) __);
}


/// Adds pattern-matching-related methods to [InventoryEvent].
extension InventoryEventPatterns on InventoryEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FetchInventory value)?  fetchInventory,TResult Function( FetchTransfers value)?  fetchTransfers,TResult Function( SubmitStockTransfer value)?  submitStockTransfer,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FetchInventory() when fetchInventory != null:
return fetchInventory(_that);case FetchTransfers() when fetchTransfers != null:
return fetchTransfers(_that);case SubmitStockTransfer() when submitStockTransfer != null:
return submitStockTransfer(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FetchInventory value)  fetchInventory,required TResult Function( FetchTransfers value)  fetchTransfers,required TResult Function( SubmitStockTransfer value)  submitStockTransfer,}){
final _that = this;
switch (_that) {
case FetchInventory():
return fetchInventory(_that);case FetchTransfers():
return fetchTransfers(_that);case SubmitStockTransfer():
return submitStockTransfer(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FetchInventory value)?  fetchInventory,TResult? Function( FetchTransfers value)?  fetchTransfers,TResult? Function( SubmitStockTransfer value)?  submitStockTransfer,}){
final _that = this;
switch (_that) {
case FetchInventory() when fetchInventory != null:
return fetchInventory(_that);case FetchTransfers() when fetchTransfers != null:
return fetchTransfers(_that);case SubmitStockTransfer() when submitStockTransfer != null:
return submitStockTransfer(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  fetchInventory,TResult Function( String? status)?  fetchTransfers,TResult Function( StockTransfer transfer)?  submitStockTransfer,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FetchInventory() when fetchInventory != null:
return fetchInventory();case FetchTransfers() when fetchTransfers != null:
return fetchTransfers(_that.status);case SubmitStockTransfer() when submitStockTransfer != null:
return submitStockTransfer(_that.transfer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  fetchInventory,required TResult Function( String? status)  fetchTransfers,required TResult Function( StockTransfer transfer)  submitStockTransfer,}) {final _that = this;
switch (_that) {
case FetchInventory():
return fetchInventory();case FetchTransfers():
return fetchTransfers(_that.status);case SubmitStockTransfer():
return submitStockTransfer(_that.transfer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  fetchInventory,TResult? Function( String? status)?  fetchTransfers,TResult? Function( StockTransfer transfer)?  submitStockTransfer,}) {final _that = this;
switch (_that) {
case FetchInventory() when fetchInventory != null:
return fetchInventory();case FetchTransfers() when fetchTransfers != null:
return fetchTransfers(_that.status);case SubmitStockTransfer() when submitStockTransfer != null:
return submitStockTransfer(_that.transfer);case _:
  return null;

}
}

}

/// @nodoc


class FetchInventory implements InventoryEvent {
  const FetchInventory();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FetchInventory);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'InventoryEvent.fetchInventory()';
}


}




/// @nodoc


class FetchTransfers implements InventoryEvent {
  const FetchTransfers({this.status});
  

 final  String? status;

/// Create a copy of InventoryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FetchTransfersCopyWith<FetchTransfers> get copyWith => _$FetchTransfersCopyWithImpl<FetchTransfers>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FetchTransfers&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'InventoryEvent.fetchTransfers(status: $status)';
}


}

/// @nodoc
abstract mixin class $FetchTransfersCopyWith<$Res> implements $InventoryEventCopyWith<$Res> {
  factory $FetchTransfersCopyWith(FetchTransfers value, $Res Function(FetchTransfers) _then) = _$FetchTransfersCopyWithImpl;
@useResult
$Res call({
 String? status
});




}
/// @nodoc
class _$FetchTransfersCopyWithImpl<$Res>
    implements $FetchTransfersCopyWith<$Res> {
  _$FetchTransfersCopyWithImpl(this._self, this._then);

  final FetchTransfers _self;
  final $Res Function(FetchTransfers) _then;

/// Create a copy of InventoryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = freezed,}) {
  return _then(FetchTransfers(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class SubmitStockTransfer implements InventoryEvent {
  const SubmitStockTransfer(this.transfer);
  

 final  StockTransfer transfer;

/// Create a copy of InventoryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmitStockTransferCopyWith<SubmitStockTransfer> get copyWith => _$SubmitStockTransferCopyWithImpl<SubmitStockTransfer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitStockTransfer&&(identical(other.transfer, transfer) || other.transfer == transfer));
}


@override
int get hashCode => Object.hash(runtimeType,transfer);

@override
String toString() {
  return 'InventoryEvent.submitStockTransfer(transfer: $transfer)';
}


}

/// @nodoc
abstract mixin class $SubmitStockTransferCopyWith<$Res> implements $InventoryEventCopyWith<$Res> {
  factory $SubmitStockTransferCopyWith(SubmitStockTransfer value, $Res Function(SubmitStockTransfer) _then) = _$SubmitStockTransferCopyWithImpl;
@useResult
$Res call({
 StockTransfer transfer
});


$StockTransferCopyWith<$Res> get transfer;

}
/// @nodoc
class _$SubmitStockTransferCopyWithImpl<$Res>
    implements $SubmitStockTransferCopyWith<$Res> {
  _$SubmitStockTransferCopyWithImpl(this._self, this._then);

  final SubmitStockTransfer _self;
  final $Res Function(SubmitStockTransfer) _then;

/// Create a copy of InventoryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? transfer = null,}) {
  return _then(SubmitStockTransfer(
null == transfer ? _self.transfer : transfer // ignore: cast_nullable_to_non_nullable
as StockTransfer,
  ));
}

/// Create a copy of InventoryEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StockTransferCopyWith<$Res> get transfer {
  
  return $StockTransferCopyWith<$Res>(_self.transfer, (value) {
    return _then(_self.copyWith(transfer: value));
  });
}
}

// dart format on
