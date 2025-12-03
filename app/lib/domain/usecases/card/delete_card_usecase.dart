import '../../repositories/card_repository.dart';

/// 删除卡片用例
class DeleteCardUseCase {
  final CardRepository _repository;

  DeleteCardUseCase(this._repository);

  /// 执行删除卡片操作
  /// 
  /// [id] 要删除的卡片ID
  Future<void> execute(int id) async {
    if (id <= 0) {
      throw ArgumentError('卡片ID必须大于0');
    }
    
    // 检查卡片是否存在
    final existingCard = await _repository.getCardById(id);
    if (existingCard == null) {
      throw ArgumentError('要删除的卡片不存在');
    }
    
    await _repository.deleteCardModel(id);
  }
}