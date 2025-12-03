import '../../models/card/card.dart';
import '../../repositories/card_repository.dart';

/// 更新卡片用例
class UpdateCardUseCase {
  final CardRepository _repository;

  UpdateCardUseCase(this._repository);

  /// 执行更新卡片操作
  /// 
  /// [card] 要更新的卡片对象（必须包含ID）
  /// 返回更新后的卡片对象
  Future<CardModel> execute(CardModel card) async {
    // 业务规则验证
    _validateCardModel(card);
    
    // 检查卡片是否存在
    final existingCard = await _repository.getCardById(card.id!);
    if (existingCard == null) {
      throw ArgumentError('要更新的卡片不存在');
    }
    
    return await _repository.updateCardModel(card);
  }

  /// 验证卡片数据
  void _validateCardModel(CardModel card) {
    if (card.id == null || card.id! <= 0) {
      throw ArgumentError('更新卡片时ID不能为空且必须大于0');
    }
    
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
    
    // 验证日期格式（简单验证）
    if (!_isValidDateFormat(card.issueDate)) {
      throw ArgumentError('发行时间格式无效');
    }
    
    if (!_isValidDateFormat(card.acquiredDate)) {
      throw ArgumentError('入手时间格式无效');
    }
  }

  /// 简单的日期格式验证（YYYY-MM-DD）
  bool _isValidDateFormat(String date) {
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(date)) {
      return false;
    }
    
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }
}