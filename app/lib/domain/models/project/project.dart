import 'package:freezed_annotation/freezed_annotation.dart';
import '../card/card.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
class ProjectModel with _$ProjectModel {
  const factory ProjectModel({
    int? id, // 系统分配的id，可以为空
    required String name, // 计划名字
    required String description, // 计划描述
    required List<CardModel> cards, // 卡片列表
  }) = _ProjectModel;

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);
}
