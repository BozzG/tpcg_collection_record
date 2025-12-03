import '../models/card/card.dart';

/// 卡片仓储接口
/// 定义卡片数据操作的抽象方法
abstract class CardRepository {
  /// 获取所有卡片
  Future<List<CardModel>> getAllCards();

  /// 根据ID获取卡片
  Future<CardModel?> getCardById(int id);

  /// 根据项目ID获取卡片列表
  Future<List<CardModel>> getCardsByProjectId(int projectId);

  /// 添加新卡片
  Future<CardModel> addCardModel(CardModel card);

  /// 更新卡片信息
  Future<CardModel> updateCardModel(CardModel card);

  /// 删除卡片
  Future<void> deleteCardModel(int id);

  /// 根据名称搜索卡片
  Future<List<CardModel>> searchCardsByName(String name);

  /// 根据发行编号搜索卡片
  Future<List<CardModel>> searchCardsByIssueNumber(String issueNumber);

  /// 根据评级筛选卡片
  Future<List<CardModel>> getCardsByGrade(String grade);

  /// 根据价格范围筛选卡片
  Future<List<CardModel>> getCardsByPriceRange(double minPrice, double maxPrice);

  /// 根据入手时间范围筛选卡片
  Future<List<CardModel>> getCardsByAcquiredDateRange(
    String startDate,
    String endDate,
  );

  /// 批量添加卡片
  Future<List<CardModel>> addCards(List<CardModel> cards);

  /// 批量删除卡片
  Future<void> deleteCards(List<int> ids);

  /// 获取卡片总数
  Future<int> getCardCount();

  /// 获取卡片总价值
  Future<double> getTotalValue();
}