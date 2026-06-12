// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visit_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VisitSummary {

 String get id; String get visitNo; String get status; String get flowStatus; String get openedAt; String? get branchId;
/// Create a copy of VisitSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisitSummaryCopyWith<VisitSummary> get copyWith => _$VisitSummaryCopyWithImpl<VisitSummary>(this as VisitSummary, _$identity);

  /// Serializes this VisitSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisitSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.visitNo, visitNo) || other.visitNo == visitNo)&&(identical(other.status, status) || other.status == status)&&(identical(other.flowStatus, flowStatus) || other.flowStatus == flowStatus)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.branchId, branchId) || other.branchId == branchId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,visitNo,status,flowStatus,openedAt,branchId);

@override
String toString() {
  return 'VisitSummary(id: $id, visitNo: $visitNo, status: $status, flowStatus: $flowStatus, openedAt: $openedAt, branchId: $branchId)';
}


}

/// @nodoc
abstract mixin class $VisitSummaryCopyWith<$Res>  {
  factory $VisitSummaryCopyWith(VisitSummary value, $Res Function(VisitSummary) _then) = _$VisitSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String visitNo, String status, String flowStatus, String openedAt, String? branchId
});




}
/// @nodoc
class _$VisitSummaryCopyWithImpl<$Res>
    implements $VisitSummaryCopyWith<$Res> {
  _$VisitSummaryCopyWithImpl(this._self, this._then);

  final VisitSummary _self;
  final $Res Function(VisitSummary) _then;

/// Create a copy of VisitSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? visitNo = null,Object? status = null,Object? flowStatus = null,Object? openedAt = null,Object? branchId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,visitNo: null == visitNo ? _self.visitNo : visitNo // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,flowStatus: null == flowStatus ? _self.flowStatus : flowStatus // ignore: cast_nullable_to_non_nullable
as String,openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VisitSummary].
extension VisitSummaryPatterns on VisitSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisitSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisitSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisitSummary value)  $default,){
final _that = this;
switch (_that) {
case _VisitSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisitSummary value)?  $default,){
final _that = this;
switch (_that) {
case _VisitSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String visitNo,  String status,  String flowStatus,  String openedAt,  String? branchId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisitSummary() when $default != null:
return $default(_that.id,_that.visitNo,_that.status,_that.flowStatus,_that.openedAt,_that.branchId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String visitNo,  String status,  String flowStatus,  String openedAt,  String? branchId)  $default,) {final _that = this;
switch (_that) {
case _VisitSummary():
return $default(_that.id,_that.visitNo,_that.status,_that.flowStatus,_that.openedAt,_that.branchId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String visitNo,  String status,  String flowStatus,  String openedAt,  String? branchId)?  $default,) {final _that = this;
switch (_that) {
case _VisitSummary() when $default != null:
return $default(_that.id,_that.visitNo,_that.status,_that.flowStatus,_that.openedAt,_that.branchId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VisitSummary extends VisitSummary {
  const _VisitSummary({required this.id, required this.visitNo, required this.status, this.flowStatus = 'registered', required this.openedAt, this.branchId}): super._();
  factory _VisitSummary.fromJson(Map<String, dynamic> json) => _$VisitSummaryFromJson(json);

@override final  String id;
@override final  String visitNo;
@override final  String status;
@override@JsonKey() final  String flowStatus;
@override final  String openedAt;
@override final  String? branchId;

/// Create a copy of VisitSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisitSummaryCopyWith<_VisitSummary> get copyWith => __$VisitSummaryCopyWithImpl<_VisitSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisitSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisitSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.visitNo, visitNo) || other.visitNo == visitNo)&&(identical(other.status, status) || other.status == status)&&(identical(other.flowStatus, flowStatus) || other.flowStatus == flowStatus)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.branchId, branchId) || other.branchId == branchId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,visitNo,status,flowStatus,openedAt,branchId);

@override
String toString() {
  return 'VisitSummary(id: $id, visitNo: $visitNo, status: $status, flowStatus: $flowStatus, openedAt: $openedAt, branchId: $branchId)';
}


}

/// @nodoc
abstract mixin class _$VisitSummaryCopyWith<$Res> implements $VisitSummaryCopyWith<$Res> {
  factory _$VisitSummaryCopyWith(_VisitSummary value, $Res Function(_VisitSummary) _then) = __$VisitSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String visitNo, String status, String flowStatus, String openedAt, String? branchId
});




}
/// @nodoc
class __$VisitSummaryCopyWithImpl<$Res>
    implements _$VisitSummaryCopyWith<$Res> {
  __$VisitSummaryCopyWithImpl(this._self, this._then);

  final _VisitSummary _self;
  final $Res Function(_VisitSummary) _then;

/// Create a copy of VisitSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? visitNo = null,Object? status = null,Object? flowStatus = null,Object? openedAt = null,Object? branchId = freezed,}) {
  return _then(_VisitSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,visitNo: null == visitNo ? _self.visitNo : visitNo // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,flowStatus: null == flowStatus ? _self.flowStatus : flowStatus // ignore: cast_nullable_to_non_nullable
as String,openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
