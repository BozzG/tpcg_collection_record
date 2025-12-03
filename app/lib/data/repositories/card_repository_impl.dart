import '../../domain/models/card/card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/local_card_datasource.dart';

/// CardRepository 的具体实现
/// 使用本地数据源进行卡片数据操作
class CardRepositoryImpl implements CardRepository {
  final LocalCardDataSource _localDataSource;

  CardRepositoryImpl(this._localDataSource);

  @override
  Future<List<CardModel>> getAllCards() async {
    try {
      return await _localDataSource.getAllCards();
    } catch (e) {
      throw Exception('获取所有卡片失败: $e');
    }
  }

  @override
  Future<CardModel?> getCardById(int id) async {
    try {
      return await _localDataSource.getCardById(id);
    } catch (e) {
      throw Exception('根据ID获取卡片失败: $e');
    }
  }

  @override
  Future<List<CardModel>> getCardsByProjectId(int projectId) async {
    try {
      return await _localDataSource.getCardsByProjectId(projectId);
    } catch (e) {
      throw Exception('根据项目ID获取卡片失败: $e');
    }
  }

  @override
  Future<CardModel> addCardModel(CardModel card) async {
    try {
      return await _localDataSource.insertCardModel(card);
    } catch (e) {
      throw Exception('添加卡片失败: $e');
    }
  }

  @override
  Future<CardModel> updateCardModel(CardModel card) async {
    try {
      if (card.id == null) {
        throw Exception('更新卡片时ID不能为空');
      }
      return await _localDataSource.updateCardModel(card);
    } catch (e) {
      throw Exception('更新卡片失败: $e');
    }
  }

  @override
  Future<void> deleteCardModel(int id) async {
    try {
      await _localDataSource.deleteCardModel(id);
    } catch (e) {
      throw Exception('删除卡片失败: $e');
    }
  }

  @override
  Future<List<CardModel>> searchCardsByName(String name) async {
    try {
      if (name.trim().isEmpty) {
        return [];
      }
      return await _localDataSource.searchCardsByName(name.trim());
    } catch (e) {
      throw Exception('根据名称搜索卡片失败: $e');
    }
  }

  @override
  Future<List<CardModel>> searchCardsByIssueNumber(String issueNumber) async {
    try {
      if (issueNumber.trim().isEmpty) {
        return [];
      }
      return await _localDataSource.searchCardsByIssueNumber(issueNumber.trim());
    } catch (e) {
      throw Exception('根据发行编号搜索卡片失败: $e');
    }
  }

  @override
  Future<List<CardModel>> getCardsByGrade(String grade) async {
    try {
      if (grade.trim().isEmpty) {
        return [];
      }
      return await _localDataSource.getCardsByGrade(grade.trim());
    } catch (e) {
      throw Exception('根据评级筛选卡片失败: $e');
    }
  }

  @override
  Future<List<CardModel>> getCardsByPriceRange(double minPrice, double maxPrice) async {
    try {
      if (minPrice < 0 || maxPrice < 0 || minPrice > maxPrice) {
        throw Exception('价格范围参数无效');
      }
      return await _localDataSource.getCardsByPriceRange(minPrice, maxPrice);
    } catch (e) {
      throw Exception('根据价格范围筛选卡片失败: $e');
    }
  }

  @override
  Future<List<CardModel>> getCardsByAcquiredDateRange(String startDate, String endDate) async {
    try {
      // 这里可以添加日期格式验证
      final allCards = await _localDataSource.getAllCards();
      return allCards.where((card) {
        final acquiredDate = card.acquiredDate;
        return acquiredDate.compareTo(startDate) >= 0 && 
               acquiredDate.compareTo(endDate) <= 0;
      }).toList();
    } catch (e) {
      throw Exception('根据入手时间范围筛选卡片失败: $e');
    }
  }

  @override
  Future<List<CardModel>> addCards(List<CardModel> cards) async {
    try {
      if (cards.isEmpty) {
        return [];
      }
      return await _localDataSource.insertCards(cards);
    } catch (e) {
      throw Exception('批量添加卡片失败: $e');
    }
  }

  @override
  Future<void> deleteCards(List<int> ids) async {
    try {
      if (ids.isEmpty) {
        return;
      }
      await _localDataSource.deleteCards(ids);
    } catch (e) {
      throw Exception('批量删除卡片失败: $e');
    }
  }

  @override
  Future<int> getCardCount() async {
    try {
      return await _localDataSource.getCardCount();
    } catch (e) {
      throw Exception('获取卡片总数失败: $e');
    }
  }

  @override
  Future<double> getTotalValue() async {
    try {
      return await _localDataSource.getTotalValue();
    } catch (e) {
      throw Exception('获取卡片总价值失败: $e');
    }
  }
}