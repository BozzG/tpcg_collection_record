// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CardModel _$CardModelFromJson(Map<String, dynamic> json) => _CardModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  issueNumber: json['issueNumber'] as String,
  issueDate: json['issueDate'] as String,
  grade: json['grade'] as String,
  acquiredDate: json['acquiredDate'] as String,
  acquiredPrice: (json['acquiredPrice'] as num).toDouble(),
  frontImage: json['frontImage'] as String,
  backImage: json['backImage'] as String,
  gradeImage: json['gradeImage'] as String,
);

Map<String, dynamic> _$CardModelToJson(_CardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'issueNumber': instance.issueNumber,
      'issueDate': instance.issueDate,
      'grade': instance.grade,
      'acquiredDate': instance.acquiredDate,
      'acquiredPrice': instance.acquiredPrice,
      'frontImage': instance.frontImage,
      'backImage': instance.backImage,
      'gradeImage': instance.gradeImage,
    };
