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

 String get id; String get videoUrl; String get trailerUrl; String get thumbnailUrl; String get vastUrl; String get title; String get description; String? get ageRestriction; String get logoUrl; String get kind; List<HomeItemDto> get episodes;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeItemDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.videoUrl, _this.videoUrl) || other.videoUrl == _this.videoUrl)&&(identical(other.trailerUrl, _this.trailerUrl) || other.trailerUrl == _this.trailerUrl)&&(identical(other.thumbnailUrl, _this.thumbnailUrl) || other.thumbnailUrl == _this.thumbnailUrl)&&(identical(other.vastUrl, _this.vastUrl) || other.vastUrl == _this.vastUrl)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.ageRestriction, _this.ageRestriction) || other.ageRestriction == _this.ageRestriction)&&(identical(other.logoUrl, _this.logoUrl) || other.logoUrl == _this.logoUrl)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&const DeepCollectionEquality().equals(other.episodes, _this.episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HomeItemDto;
  return Object.hash(runtimeType,_this.id,_this.videoUrl,_this.trailerUrl,_this.thumbnailUrl,_this.vastUrl,_this.title,_this.description,_this.ageRestriction,_this.logoUrl,_this.kind,const DeepCollectionEquality().hash(_this.episodes));
}

@override
String toString() {
  final _this = this as HomeItemDto;
  return 'HomeItemDto(id: ${_this.id}, videoUrl: ${_this.videoUrl}, trailerUrl: ${_this.trailerUrl}, thumbnailUrl: ${_this.thumbnailUrl}, vastUrl: ${_this.vastUrl}, title: ${_this.title}, description: ${_this.description}, ageRestriction: ${_this.ageRestriction}, logoUrl: ${_this.logoUrl}, kind: ${_this.kind}, episodes: ${_this.episodes})';
}


}

/// @nodoc
abstract mixin class $HomeItemDtoCopyWith<$Res>  {
  factory $HomeItemDtoCopyWith(HomeItemDto value, $Res Function(HomeItemDto) _then) = _$HomeItemDtoCopyWithImpl;
@useResult
$Res call({
 String id, String videoUrl, String trailerUrl, String thumbnailUrl, String vastUrl, String title, String description, String? ageRestriction, String logoUrl, String kind, List<HomeItemDto> episodes
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? videoUrl = null,Object? trailerUrl = null,Object? thumbnailUrl = null,Object? vastUrl = null,Object? title = null,Object? description = null,Object? ageRestriction = freezed,Object? logoUrl = null,Object? kind = null,Object? episodes = null,}) {
  return _then(HomeItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,trailerUrl: null == trailerUrl ? _self.trailerUrl : trailerUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,vastUrl: null == vastUrl ? _self.vastUrl : vastUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,ageRestriction: freezed == ageRestriction ? _self.ageRestriction : ageRestriction // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,episodes: null == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<HomeItemDto>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String videoUrl,  String trailerUrl,  String thumbnailUrl,  String vastUrl,  String title,  String description,  String? ageRestriction,  String logoUrl,  String kind,  List<HomeItemDto> episodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeItemDto() when $default != null:
return $default(_that.id,_that.videoUrl,_that.trailerUrl,_that.thumbnailUrl,_that.vastUrl,_that.title,_that.description,_that.ageRestriction,_that.logoUrl,_that.kind,_that.episodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String videoUrl,  String trailerUrl,  String thumbnailUrl,  String vastUrl,  String title,  String description,  String? ageRestriction,  String logoUrl,  String kind,  List<HomeItemDto> episodes)  $default,) {final _that = this;
switch (_that) {
case _HomeItemDto():
return $default(_that.id,_that.videoUrl,_that.trailerUrl,_that.thumbnailUrl,_that.vastUrl,_that.title,_that.description,_that.ageRestriction,_that.logoUrl,_that.kind,_that.episodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String videoUrl,  String trailerUrl,  String thumbnailUrl,  String vastUrl,  String title,  String description,  String? ageRestriction,  String logoUrl,  String kind,  List<HomeItemDto> episodes)?  $default,) {final _that = this;
switch (_that) {
case _HomeItemDto() when $default != null:
return $default(_that.id,_that.videoUrl,_that.trailerUrl,_that.thumbnailUrl,_that.vastUrl,_that.title,_that.description,_that.ageRestriction,_that.logoUrl,_that.kind,_that.episodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeItemDto implements HomeItemDto {
  const _HomeItemDto({required this.id, this.videoUrl = '', this.trailerUrl = '', required this.thumbnailUrl, this.vastUrl = '', required this.title, required this.description, this.ageRestriction, this.logoUrl = '', required this.kind,  List<HomeItemDto> episodes = const <HomeItemDto>[]}): _episodes = episodes;
  factory _HomeItemDto.fromJson(Map<String, dynamic> json) => _$HomeItemDtoFromJson(json);

@override final  String id;
@override@JsonKey() final  String videoUrl;
@override@JsonKey() final  String trailerUrl;
@override final  String thumbnailUrl;
@override@JsonKey() final  String vastUrl;
@override final  String title;
@override final  String description;
@override final  String? ageRestriction;
@override@JsonKey() final  String logoUrl;
@override final  String kind;
 final  List<HomeItemDto> _episodes;
@override@JsonKey() List<HomeItemDto> get episodes {
  if (_episodes is EqualUnmodifiableListView) return _episodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_episodes);
}


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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.trailerUrl, trailerUrl) || other.trailerUrl == trailerUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.vastUrl, vastUrl) || other.vastUrl == vastUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.ageRestriction, ageRestriction) || other.ageRestriction == ageRestriction)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.episodes, _episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,videoUrl,trailerUrl,thumbnailUrl,vastUrl,title,description,ageRestriction,logoUrl,kind,const DeepCollectionEquality().hash(_episodes));
}

@override
String toString() {
    return 'HomeItemDto(id: $id, videoUrl: $videoUrl, trailerUrl: $trailerUrl, thumbnailUrl: $thumbnailUrl, vastUrl: $vastUrl, title: $title, description: $description, ageRestriction: $ageRestriction, logoUrl: $logoUrl, kind: $kind, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class _$HomeItemDtoCopyWith<$Res> implements $HomeItemDtoCopyWith<$Res> {
  factory _$HomeItemDtoCopyWith(_HomeItemDto value, $Res Function(_HomeItemDto) _then) = __$HomeItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String videoUrl, String trailerUrl, String thumbnailUrl, String vastUrl, String title, String description, String? ageRestriction, String logoUrl, String kind, List<HomeItemDto> episodes
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? videoUrl = null,Object? trailerUrl = null,Object? thumbnailUrl = null,Object? vastUrl = null,Object? title = null,Object? description = null,Object? ageRestriction = freezed,Object? logoUrl = null,Object? kind = null,Object? episodes = null,}) {
  return _then(_HomeItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,trailerUrl: null == trailerUrl ? _self.trailerUrl : trailerUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,vastUrl: null == vastUrl ? _self.vastUrl : vastUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,ageRestriction: freezed == ageRestriction ? _self.ageRestriction : ageRestriction // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,episodes: null == episodes ? _self._episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<HomeItemDto>,
  ));
}


}

// dart format on
