import '../../models/project/project.dart';
import '../../models/card/card.dart';
import '../../repositories/project_repository.dart';

/// 管理项目卡片用例
class ManageProjectCardsUseCase {
  final ProjectRepository _repository;

  ManageProjectCardsUseCase(this._repository);

  /// 向项目添加卡片
  /// 
  /// [projectId] 项目ID
  /// [card] 要添加的卡片
  Future<ProjectModel> addCardToProjectModel(int projectId, CardModel card) async {
    if (projectId <= 0) {
      throw ArgumentError('项目ID必须大于0');
    }
    
    _validateCardModel(card);
    
    return await _repository.addCardToProjectModel(projectId, card);
  }

  /// 从项目中移除卡片
  /// 
  /// [projectId] 项目ID
  /// [cardId] 要移除的卡片ID
  Future<ProjectModel> removeCardFromProjectModel(int projectId, int cardId) async {
    if (projectId <= 0) {
      throw ArgumentError('项目ID必须大于0');
    }
    
    if (cardId <= 0) {
      throw ArgumentError('卡片ID必须大于0');
    }
    
    return await _repository.removeCardFromProjectModel(projectId, cardId);
  }

  /// 批量向项目添加卡片
  /// 
  /// [projectId] 项目ID
  /// [cards] 要添加的卡片列表
  Future<ProjectModel> addCardsToProjectModel(int projectId, List<CardModel> cards) async {
    if (projectId <= 0) {
      throw ArgumentError('项目ID必须大于0');
    }
    
    if (cards.isEmpty) {
      throw ArgumentError('卡片列表不能为空');
    }
    
    // 验证所有卡片
    for (final card in cards) {
      _validateCardModel(card);
    }
    
    return await _repository.addCardsToProjectModel(projectId, cards);
  }

  /// 批量从项目中移除卡片
  /// 
  /// [projectId] 项目ID
  /// [cardIds] 要移除的卡片ID列表
  Future<ProjectModel> removeCardsFromProjectModel(int projectId, List<int> cardIds) async {
    if (projectId <= 0) {
      throw ArgumentError('项目ID必须大于0');
    }
    
    if (cardIds.isEmpty) {
      throw ArgumentError('卡片ID列表不能为空');
    }
    
    // 验证所有卡片ID
    for (final cardId in cardIds) {
      if (cardId <= 0) {
        throw ArgumentError('卡片ID必须大于0');
      }
    }
    
    return await _repository.removeCardsFromProjectModel(projectId, cardIds);
  }

  /// 获取项目中特定评级的卡片
  /// 
  /// [projectId] 项目ID
  /// [grade] 评级
  Future<List<CardModel>> getProjectCardsByGrade(int projectId, String grade) async {
    if (projectId <= 0) {
      throw ArgumentError('项目ID必须大于0');
    }
    
    if (grade.trim().isEmpty) {
      throw ArgumentError('评级不能为空');
    }
    
    return await _repository.getProjectCardsByGrade(projectId, grade.trim());
  }

  /// 获取项目中价格范围内的卡片
  /// 
  /// [projectId] 项目ID
  /// [minPrice] 最低价格
  /// [maxPrice] 最高价格
  Future<List<CardModel>> getProjectCardsByPriceRange(
    int projectId,
    double minPrice,
    double maxPrice,
  ) async {
    if (projectId <= 0) {
      throw ArgumentError('项目ID必须大于0');
    }
    
    if (minPrice < 0) {
      throw ArgumentError('最低价格不能为负数');
    }
    
    if (maxPrice < 0) {
      throw ArgumentError('最高价格不能为负数');
    }
    
    if (minPrice > maxPrice) {
      throw ArgumentError('最低价格不能大于最高价格');
    }
    
    return await _repository.getProjectCardsByPriceRange(projectId, minPrice, maxPrice);
  }

  /// 验证卡片数据
  void _validateCardModel(CardModel card) {
    if (card.name.trim().isEmpty) {
      throw ArgumentError('卡片名称不能为空');
    }
    
    if (card.issueNumber.trim().isEmpty) {
      throw ArgumentError('发行编号不能为空');
    }
    
    if (card.issueDate.trim().isEmpty) {
      throw ArgumentError('发行时间不能为空');
    }
    
    if (card.grade.trim().isEmpty) {
      throw ArgumentError('评级不能为空');
    }
    
    if (card.acquiredDate.trim().isEmpty) {
      throw ArgumentError('入手时间不能为空');
    }
    
    if (card.acquiredPrice < 0) {
      throw ArgumentError('入手价格不能为负数');
    }
    
    if (card.frontImage.trim().isEmpty) {
      throw ArgumentError('正面图不能为空');
    }
  }
}