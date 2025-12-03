import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.freezed.dart';
part 'card.g.dart';

@freezed
class CardModel with _$CardModel {
  const factory CardModel({
    int? id, // 系统分配的id，可以为空
    required String name, // 卡片名字
    required String issueNumber, // 卡片发行编号
    required String issueDate, // 发行时间
    required String grade, // 评级
    required String acquiredDate, // 入手时间
    required double acquiredPrice, // 入手价格
    required String frontImage, // 正面图
    required String backImage, // 背面图
    required String gradeImage, // 评级图
  }) = _CardModel;

  factory CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);
}
