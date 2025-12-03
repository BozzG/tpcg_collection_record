import '../../models/card/card.dart';
import '../../repositories/card_repository.dart';

/// 添加卡片用例
class AddCardUseCase {
  final CardRepository _repository;

  AddCardUseCase(this._repository);

  /// 执行添加卡片操作
  /// 
  /// [card] 要添加的卡片对象
  /// 返回添加后的卡片对象（包含生成的ID）
  Future<CardModel> execute(CardModel card) async {
    // 业务规则验证
    _validateCardModel(card);
    
    return await _repository.addCardModel(card);
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