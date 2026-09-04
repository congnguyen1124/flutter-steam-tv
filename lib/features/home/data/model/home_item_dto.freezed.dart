// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeItemDto {

 String get id; String get title; String get description; String get kind;
/// Create a copy of HomeItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeItemDtoCopyWith<HomeItemDto> get copyWith => _$HomeItemDtoCopyWithImpl<HomeItemDto>(this as HomeItemDto, _$identity);

  /// Serializes this HomeItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HomeItemDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeItemDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.kind, _this.kind) || other.kind == _this.kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HomeItemDto;
  return Object.hash(runtimeType,_this.id,_this.title,_this.description,_this.kind);
}

@override
String toString() {
  final _this = this as HomeItemDto;
  return 'HomeItemDto(id: ${_this.id}, title: ${_this.title}, description: ${_this.description}, kind: ${_this.kind})';
}


}

/// @nodoc
abstract mixin class $HomeItemDtoCopyWith<$Res>  {
  factory $HomeItemDtoCopyWith(HomeItemDto value, $Res Function(HomeItemDto) _then) = _$HomeItemDtoCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String kind
});




}
/// @nodoc
class _$HomeItemDtoCopyWithImpl<$Res>
    implements $HomeItemDtoCopyWith<$Res> {
  _$HomeItemDtoCopyWithImpl(this._self, this._then);

  final HomeItemDto _self;
  final $Res Function(HomeItemDto) _then;

/// Create a copy of HomeItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? kind = null,}) {
  return _then(HomeItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeItemDto].
extension HomeItemDtoPatterns on HomeItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeItemDto value)  $default,){
final _that = this;
switch (_that) {
case _HomeItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _HomeItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeItemDto() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String kind)  $default,) {final _that = this;
switch (_that) {
case _HomeItemDto():
return $default(_that.id,_that.title,_that.description,_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String kind)?  $default,) {final _that = this;
switch (_that) {
case _HomeItemDto() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.kind);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeItemDto implements HomeItemDto {
  const _HomeItemDto({required this.id, required this.title, required this.description, required this.kind});
  factory _HomeItemDto.fromJson(Map<String, dynamic> json) => _$HomeItemDtoFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String kind;

/// Create a copy of HomeItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeItemDtoCopyWith<_HomeItemDto> get copyWith => __$HomeItemDtoCopyWithImpl<_HomeItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,description,kind);
}

@override
String toString() {
    return 'HomeItemDto(id: $id, title: $title, description: $description, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$HomeItemDtoCopyWith<$Res> implements $HomeItemDtoCopyWith<$Res> {
  factory _$HomeItemDtoCopyWith(_HomeItemDto value, $Res Function(_HomeItemDto) _then) = __$HomeItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String kind
});




}
/// @nodoc
class __$HomeItemDtoCopyWithImpl<$Res>
    implements _$HomeItemDtoCopyWith<$Res> {
  __$HomeItemDtoCopyWithImpl(this._self, this._then);

  final _HomeItemDto _self;
  final $Res Function(_HomeItemDto) _then;

/// Create a copy of HomeItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? kind = null,}) {
  return _then(_HomeItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
