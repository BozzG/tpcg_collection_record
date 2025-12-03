import '../../models/card/card.dart';
import '../../repositories/card_repository.dart';

/// 根据ID获取卡片用例
class GetCardByIdUseCase {
  final CardRepository _repository;

  GetCardByIdUseCase(this._repository);

  /// 执行根据ID获取卡片操作
  /// 
  /// [id] 卡片ID
  /// 返回卡片对象，如果不存在则返回null
  Future<CardModel?> execute(int id) async {
    if (id <= 0) {
      throw ArgumentError('卡片ID必须大于0');
    }
    
    return await _repository.getCardById(id);
  }
}