// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_section_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeSectionDto {

 String get id; String get title; String get viewType; List<HomeItemDto> get items;
/// Create a copy of HomeSectionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeSectionDtoCopyWith<HomeSectionDto> get copyWith => _$HomeSectionDtoCopyWithImpl<HomeSectionDto>(this as HomeSectionDto, _$identity);

  /// Serializes this HomeSectionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HomeSectionDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeSectionDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.viewType, _this.viewType) || other.viewType == _this.viewType)&&const DeepCollectionEquality().equals(other.items, _this.items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HomeSectionDto;
  return Object.hash(runtimeType,_this.id,_this.title,_this.viewType,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as HomeSectionDto;
  return 'HomeSectionDto(id: ${_this.id}, title: ${_this.title}, viewType: ${_this.viewType}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $HomeSectionDtoCopyWith<$Res>  {
  factory $HomeSectionDtoCopyWith(HomeSectionDto value, $Res Function(HomeSectionDto) _then) = _$HomeSectionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String title, String viewType, List<HomeItemDto> items
});




}
/// @nodoc
class _$HomeSectionDtoCopyWithImpl<$Res>
    implements $HomeSectionDtoCopyWith<$Res> {
  _$HomeSectionDtoCopyWithImpl(this._self, this._then);

  final HomeSectionDto _self;
  final $Res Function(HomeSectionDto) _then;

/// Create a copy of HomeSectionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? viewType = null,Object? items = null,}) {
  return _then(HomeSectionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,viewType: null == viewType ? _self.viewType : viewType // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<HomeItemDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeSectionDto].
extension HomeSectionDtoPatterns on HomeSectionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeSectionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeSectionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeSectionDto value)  $default,){
final _that = this;
switch (_that) {
case _HomeSectionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeSectionDto value)?  $default,){
final _that = this;
switch (_that) {
case _HomeSectionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String viewType,  List<HomeItemDto> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeSectionDto() when $default != null:
return $default(_that.id,_that.title,_that.viewType,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String viewType,  List<HomeItemDto> items)  $default,) {final _that = this;
switch (_that) {
case _HomeSectionDto():
return $default(_that.id,_that.title,_that.viewType,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String viewType,  List<HomeItemDto> items)?  $default,) {final _that = this;
switch (_that) {
case _HomeSectionDto() when $default != null:
return $default(_that.id,_that.title,_that.viewType,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeSectionDto implements HomeSectionDto {
  const _HomeSectionDto({required this.id, required this.title, required this.viewType, required  List<HomeItemDto> items}): _items = items;
  factory _HomeSectionDto.fromJson(Map<String, dynamic> json) => _$HomeSectionDtoFromJson(json);

@override final  String id;
@override final  String title;
@override final  String viewType;
 final  List<HomeItemDto> _items;
@override List<HomeItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of HomeSectionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeSectionDtoCopyWith<_HomeSectionDto> get copyWith => __$HomeSectionDtoCopyWithImpl<_HomeSectionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeSectionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeSectionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.viewType, viewType) || other.viewType == viewType)&&const DeepCollectionEquality().equals(other.items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,viewType,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'HomeSectionDto(id: $id, title: $title, viewType: $viewType, items: $items)';
}


}

/// @nodoc
abstract mixin class _$HomeSectionDtoCopyWith<$Res> implements $HomeSectionDtoCopyWith<$Res> {
  factory _$HomeSectionDtoCopyWith(_HomeSectionDto value, $Res Function(_HomeSectionDto) _then) = __$HomeSectionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String viewType, List<HomeItemDto> items
});




}
/// @nodoc
class __$HomeSectionDtoCopyWithImpl<$Res>
    implements _$HomeSectionDtoCopyWith<$Res> {
  __$HomeSectionDtoCopyWithImpl(this._self, this._then);

  final _HomeSectionDto _self;
  final $Res Function(_HomeSectionDto) _then;

/// Create a copy of HomeSectionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? viewType = null,Object? items = null,}) {
  return _then(_HomeSectionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,viewType: null == viewType ? _self.viewType : viewType // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<HomeItemDto>,
  ));
}


}

// dart format on
