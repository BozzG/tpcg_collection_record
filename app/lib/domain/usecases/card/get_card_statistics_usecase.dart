import '../../repositories/card_repository.dart';

/// 获取卡片统计信息用例
class GetCardStatisticsUseCase {
  final CardRepository _repository;

  GetCardStatisticsUseCase(this._repository);

  /// 获取卡片总数
  Future<int> getTotalCount() async {
    return await _repository.getCardCount();
  }

  /// 获取卡片总价值
  Future<double> getTotalValue() async {
    return await _repository.getTotalValue();
  }

  /// 获取完整的卡片统计信息
  Future<CardStatistics> getFullStatistics() async {
    final totalCount = await _repository.getCardCount();
    final totalValue = await _repository.getTotalValue();
    final allCards = await _repository.getAllCards();
    
    // 计算平均价格
    final averagePrice = totalCount > 0 ? totalValue / totalCount : 0.0;
    
    // 按评级统计
    final gradeStats = <String, int>{};
    final gradeValues = <String, double>{};
    
    for (final card in allCards) {
      gradeStats[card.grade] = (gradeStats[card.grade] ?? 0) + 1;
      gradeValues[card.grade] = (gradeValues[card.grade] ?? 0.0) + card.acquiredPrice;
    }
    
    // 找出最贵和最便宜的卡片
    double? maxPrice;
    double? minPrice;
    String? mostExpensiveCard;
    String? cheapestCard;
    
    if (allCards.isNotEmpty) {
      var sortedByPrice = List.from(allCards);
      sortedByPrice.sort((a, b) => a.acquiredPrice.compareTo(b.acquiredPrice));
      
      minPrice = sortedByPrice.first.acquiredPrice;
      maxPrice = sortedByPrice.last.acquiredPrice;
      cheapestCard = sortedByPrice.first.name;
      mostExpensiveCard = sortedByPrice.last.name;
    }
    
    // 按年份统计（基于入手时间）
    final yearStats = <String, int>{};
    for (final card in allCards) {
      final year = card.acquiredDate.substring(0, 4);
      yearStats[year] = (yearStats[year] ?? 0) + 1;
    }
    
    return CardStatistics(
      totalCount: totalCount,
      totalValue: totalValue,
      averagePrice: averagePrice,
      maxPrice: maxPrice,
      minPrice: minPrice,
      mostExpensiveCard: mostExpensiveCard,
      cheapestCard: cheapestCard,
      gradeStatistics: gradeStats,
      gradeValues: gradeValues,
      yearStatistics: yearStats,
    );
  }
}

/// 卡片统计信息
class CardStatistics {
  final int totalCount;
  final double totalValue;
  final double averagePrice;
  final double? maxPrice;
  final double? minPrice;
  final String? mostExpensiveCard;
  final String? cheapestCard;
  final Map<String, int> gradeStatistics;
  final Map<String, double> gradeValues;
  final Map<String, int> yearStatistics;

  CardStatistics({
    required this.totalCount,
    required this.totalValue,
    required this.averagePrice,
    this.maxPrice,
    this.minPrice,
    this.mostExpensiveCard,
    this.cheapestCard,
    required this.gradeStatistics,
    required this.gradeValues,
    required this.yearStatistics,
  });

  /// 获取最受欢迎的评级
  String? get mostPopularGrade {
    if (gradeStatistics.isEmpty) return null;
    
    var maxCount = 0;
    String? popularGrade;
    
    gradeStatistics.forEach((grade, count) {
      if (count > maxCount) {
        maxCount = count;
        popularGrade = grade;
      }
    });
    
    return popularGrade;
  }

  /// 获取最有价值的评级
  String? get mostValuableGrade {
    if (gradeValues.isEmpty) return null;
    
    var maxValue = 0.0;
    String? valuableGrade;
    
    gradeValues.forEach((grade, value) {
      if (value > maxValue) {
        maxValue = value;
        valuableGrade = grade;
      }
    });
    
    return valuableGrade;
  }

  /// 获取收藏最活跃的年份
  String? get mostActiveYear {
    if (yearStatistics.isEmpty) return null;
    
    var maxCount = 0;
    String? activeYear;
    
    yearStatistics.forEach((year, count) {
      if (count > maxCount) {
        maxCount = count;
        activeYear = year;
      }
    });
    
    return activeYear;
  }
}