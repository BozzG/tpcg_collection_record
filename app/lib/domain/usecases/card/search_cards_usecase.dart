import '../../models/card/card.dart';
import '../../repositories/card_repository.dart';

/// 搜索卡片用例
class SearchCardsUseCase {
  final CardRepository _repository;

  SearchCardsUseCase(this._repository);

  /// 根据名称搜索卡片
  /// 
  /// [name] 搜索关键词
  Future<List<CardModel>> searchByName(String name) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('搜索关键词不能为空');
    }
    
    return await _repository.searchCardsByName(name.trim());
  }

  /// 根据发行编号搜索卡片
  /// 
  /// [issueNumber] 发行编号关键词
  Future<List<CardModel>> searchByIssueNumber(String issueNumber) async {
    if (issueNumber.trim().isEmpty) {
      throw ArgumentError('发行编号不能为空');
    }
    
    return await _repository.searchCardsByIssueNumber(issueNumber.trim());
  }

  /// 根据评级筛选卡片
  /// 
  /// [grade] 评级
  Future<List<CardModel>> filterByGrade(String grade) async {
    if (grade.trim().isEmpty) {
      throw ArgumentError('评级不能为空');
    }
    
    return await _repository.getCardsByGrade(grade.trim());
  }

  /// 根据价格范围筛选卡片
  /// 
  /// [minPrice] 最低价格
  /// [maxPrice] 最高价格
  Future<List<CardModel>> filterByPriceRange(double minPrice, double maxPrice) async {
    if (minPrice < 0) {
      throw ArgumentError('最低价格不能为负数');
    }
    
    if (maxPrice < 0) {
      throw ArgumentError('最高价格不能为负数');
    }
    
    if (minPrice > maxPrice) {
      throw ArgumentError('最低价格不能大于最高价格');
    }
    
    return await _repository.getCardsByPriceRange(minPrice, maxPrice);
  }

  /// 根据入手时间范围筛选卡片
  /// 
  /// [startDate] 开始日期 (YYYY-MM-DD)
  /// [endDate] 结束日期 (YYYY-MM-DD)
  Future<List<CardModel>> filterByAcquiredDateRange(String startDate, String endDate) async {
    if (startDate.trim().isEmpty || endDate.trim().isEmpty) {
      throw ArgumentError('开始日期和结束日期不能为空');
    }
    
    // 验证日期格式
    if (!_isValidDateFormat(startDate) || !_isValidDateFormat(endDate)) {
      throw ArgumentError('日期格式无效，请使用 YYYY-MM-DD 格式');
    }
    
    // 验证日期范围
    if (startDate.compareTo(endDate) > 0) {
      throw ArgumentError('开始日期不能晚于结束日期');
    }
    
    return await _repository.getCardsByAcquiredDateRange(startDate, endDate);
  }

  /// 综合搜索（支持多个条件）
  /// 
  /// [searchParams] 搜索参数
  Future<List<CardModel>> searchWithMultipleFilters(CardSearchParams searchParams) async {
    List<CardModel> results = await _repository.getAllCards();
    
    // 按名称筛选
    if (searchParams.name != null && searchParams.name!.trim().isNotEmpty) {
      final nameResults = await _repository.searchCardsByName(searchParams.name!.trim());
      results = results.where((card) => nameResults.any((nameCard) => nameCard.id == card.id)).toList();
    }
    
    // 按发行编号筛选
    if (searchParams.issueNumber != null && searchParams.issueNumber!.trim().isNotEmpty) {
      results = results.where((card) => 
        card.issueNumber.toLowerCase().contains(searchParams.issueNumber!.toLowerCase())).toList();
    }
    
    // 按评级筛选
    if (searchParams.grade != null && searchParams.grade!.trim().isNotEmpty) {
      results = results.where((card) => card.grade == searchParams.grade).toList();
    }
    
    // 按价格范围筛选
    if (searchParams.minPrice != null && searchParams.maxPrice != null) {
      results = results.where((card) => 
        card.acquiredPrice >= searchParams.minPrice! && 
        card.acquiredPrice <= searchParams.maxPrice!).toList();
    }
    
    // 按入手时间范围筛选
    if (searchParams.startDate != null && searchParams.endDate != null) {
      results = results.where((card) => 
        card.acquiredDate.compareTo(searchParams.startDate!) >= 0 && 
        card.acquiredDate.compareTo(searchParams.endDate!) <= 0).toList();
    }
    
    return results;
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

/// 卡片搜索参数
class CardSearchParams {
  final String? name;
  final String? issueNumber;
  final String? grade;
  final double? minPrice;
  final double? maxPrice;
  final String? startDate;
  final String? endDate;

  CardSearchParams({
    this.name,
    this.issueNumber,
    this.grade,
    this.minPrice,
    this.maxPrice,
    this.startDate,
    this.endDate,
  });
}