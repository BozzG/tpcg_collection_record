// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CardModel {

 int? get id => throw _privateConstructorUsedError; // 系统分配的id，可以为空
 String get name => throw _privateConstructorUsedError; // 卡片名字
 String get issueNumber => throw _privateConstructorUsedError; // 卡片发行编号
 String get issueDate => throw _privateConstructorUsedError; // 发行时间
 String get grade => throw _privateConstructorUsedError; // 评级
 String get acquiredDate => throw _privateConstructorUsedError; // 入手时间
 double get acquiredPrice => throw _privateConstructorUsedError; // 入手价格
 String get frontImage => throw _privateConstructorUsedError; // 正面图
 String get backImage => throw _privateConstructorUsedError; // 背面图
 String get gradeImage => throw _privateConstructorUsedError; 
/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardModelCopyWith<CardModel> get copyWith => _$CardModelCopyWithImpl<CardModel>(this as CardModel, _$identity);

  /// Serializes this CardModel to a JSON map.
  // Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.issueNumber, issueNumber) || other.issueNumber == issueNumber)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.acquiredDate, acquiredDate) || other.acquiredDate == acquiredDate)&&(identical(other.acquiredPrice, acquiredPrice) || other.acquiredPrice == acquiredPrice)&&(identical(other.frontImage, frontImage) || other.frontImage == frontImage)&&(identical(other.backImage, backImage) || other.backImage == backImage)&&(identical(other.gradeImage, gradeImage) || other.gradeImage == gradeImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,issueNumber,issueDate,grade,acquiredDate,acquiredPrice,frontImage,backImage,gradeImage);

@override
String toString() {
  return 'CardModel(id: $id, name: $name, issueNumber: $issueNumber, issueDate: $issueDate, grade: $grade, acquiredDate: $acquiredDate, acquiredPrice: $acquiredPrice, frontImage: $frontImage, backImage: $backImage, gradeImage: $gradeImage)';
}


}

/// @nodoc
abstract mixin class $CardModelCopyWith<$Res>  {
  factory $CardModelCopyWith(CardModel value, $Res Function(CardModel) _then) = _$CardModelCopyWithImpl;
@useResult
$Res call({
 int? id, String name, String issueNumber, String issueDate, String grade, String acquiredDate, double acquiredPrice, String frontImage, String backImage, String gradeImage
});




}
/// @nodoc
class _$CardModelCopyWithImpl<$Res>
    implements $CardModelCopyWith<$Res> {
  _$CardModelCopyWithImpl(this._self, this._then);

  final CardModel _self;
  final $Res Function(CardModel) _then;

/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? issueNumber = null,Object? issueDate = null,Object? grade = null,Object? acquiredDate = null,Object? acquiredPrice = null,Object? frontImage = null,Object? backImage = null,Object? gradeImage = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,issueNumber: null == issueNumber ? _self.issueNumber : issueNumber // ignore: cast_nullable_to_non_nullable
as String,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,acquiredDate: null == acquiredDate ? _self.acquiredDate : acquiredDate // ignore: cast_nullable_to_non_nullable
as String,acquiredPrice: null == acquiredPrice ? _self.acquiredPrice : acquiredPrice // ignore: cast_nullable_to_non_nullable
as double,frontImage: null == frontImage ? _self.frontImage : frontImage // ignore: cast_nullable_to_non_nullable
as String,backImage: null == backImage ? _self.backImage : backImage // ignore: cast_nullable_to_non_nullable
as String,gradeImage: null == gradeImage ? _self.gradeImage : gradeImage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CardModel].
extension CardModelPatterns on CardModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardModel value)  $default,){
final _that = this;
switch (_that) {
case _CardModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardModel value)?  $default,){
final _that = this;
switch (_that) {
case _CardModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name,  String issueNumber,  String issueDate,  String grade,  String acquiredDate,  double acquiredPrice,  String frontImage,  String backImage,  String gradeImage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardModel() when $default != null:
return $default(_that.id,_that.name,_that.issueNumber,_that.issueDate,_that.grade,_that.acquiredDate,_that.acquiredPrice,_that.frontImage,_that.backImage,_that.gradeImage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name,  String issueNumber,  String issueDate,  String grade,  String acquiredDate,  double acquiredPrice,  String frontImage,  String backImage,  String gradeImage)  $default,) {final _that = this;
switch (_that) {
case _CardModel():
return $default(_that.id,_that.name,_that.issueNumber,_that.issueDate,_that.grade,_that.acquiredDate,_that.acquiredPrice,_that.frontImage,_that.backImage,_that.gradeImage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name,  String issueNumber,  String issueDate,  String grade,  String acquiredDate,  double acquiredPrice,  String frontImage,  String backImage,  String gradeImage)?  $default,) {final _that = this;
switch (_that) {
case _CardModel() when $default != null:
return $default(_that.id,_that.name,_that.issueNumber,_that.issueDate,_that.grade,_that.acquiredDate,_that.acquiredPrice,_that.frontImage,_that.backImage,_that.gradeImage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardModel implements CardModel {
  const _CardModel({this.id, required this.name, required this.issueNumber, required this.issueDate, required this.grade, required this.acquiredDate, required this.acquiredPrice, required this.frontImage, required this.backImage, required this.gradeImage});
  factory _CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);

@override final  int? id;
// 系统分配的id，可以为空
@override final  String name;
// 卡片名字
@override final  String issueNumber;
// 卡片发行编号
@override final  String issueDate;
// 发行时间
@override final  String grade;
// 评级
@override final  String acquiredDate;
// 入手时间
@override final  double acquiredPrice;
// 入手价格
@override final  String frontImage;
// 正面图
@override final  String backImage;
// 背面图
@override final  String gradeImage;

/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardModelCopyWith<_CardModel> get copyWith => __$CardModelCopyWithImpl<_CardModel>(this, _$identity);

// @override
Map<String, dynamic> toJson() {
  return _$CardModelToJson(this);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.issueNumber, issueNumber) || other.issueNumber == issueNumber)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.acquiredDate, acquiredDate) || other.acquiredDate == acquiredDate)&&(identical(other.acquiredPrice, acquiredPrice) || other.acquiredPrice == acquiredPrice)&&(identical(other.frontImage, frontImage) || other.frontImage == frontImage)&&(identical(other.backImage, backImage) || other.backImage == backImage)&&(identical(other.gradeImage, gradeImage) || other.gradeImage == gradeImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,issueNumber,issueDate,grade,acquiredDate,acquiredPrice,frontImage,backImage,gradeImage);

@override
String toString() {
  return 'CardModel(id: $id, name: $name, issueNumber: $issueNumber, issueDate: $issueDate, grade: $grade, acquiredDate: $acquiredDate, acquiredPrice: $acquiredPrice, frontImage: $frontImage, backImage: $backImage, gradeImage: $gradeImage)';
}


}

/// @nodoc
abstract mixin class _$CardModelCopyWith<$Res> implements $CardModelCopyWith<$Res> {
  factory _$CardModelCopyWith(_CardModel value, $Res Function(_CardModel) _then) = __$CardModelCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name, String issueNumber, String issueDate, String grade, String acquiredDate, double acquiredPrice, String frontImage, String backImage, String gradeImage
});




}
/// @nodoc
class __$CardModelCopyWithImpl<$Res>
    implements _$CardModelCopyWith<$Res> {
  __$CardModelCopyWithImpl(this._self, this._then);

  final _CardModel _self;
  final $Res Function(_CardModel) _then;

/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? issueNumber = null,Object? issueDate = null,Object? grade = null,Object? acquiredDate = null,Object? acquiredPrice = null,Object? frontImage = null,Object? backImage = null,Object? gradeImage = null,}) {
  return _then(_CardModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,issueNumber: null == issueNumber ? _self.issueNumber : issueNumber // ignore: cast_nullable_to_non_nullable
as String,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,acquiredDate: null == acquiredDate ? _self.acquiredDate : acquiredDate // ignore: cast_nullable_to_non_nullable
as String,acquiredPrice: null == acquiredPrice ? _self.acquiredPrice : acquiredPrice // ignore: cast_nullable_to_non_nullable
as double,frontImage: null == frontImage ? _self.frontImage : frontImage // ignore: cast_nullable_to_non_nullable
as String,backImage: null == backImage ? _self.backImage : backImage // ignore: cast_nullable_to_non_nullable
as String,gradeImage: null == gradeImage ? _self.gradeImage : gradeImage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
