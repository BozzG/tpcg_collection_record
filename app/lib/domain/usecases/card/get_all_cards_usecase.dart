import '../../models/card/card.dart';
import '../../repositories/card_repository.dart';

/// 获取所有卡片用例
class GetAllCardsUseCase {
  final CardRepository _repository;

  GetAllCardsUseCase(this._repository);

  /// 执行获取所有卡片操作
  Future<List<CardModel>> execute() async {
    return await _repository.getAllCards();
  }
}