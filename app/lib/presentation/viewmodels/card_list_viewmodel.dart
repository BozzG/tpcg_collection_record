import '../../domain/models/card/card.dart';
import '../../domain/usecases/card/get_all_cards_usecase.dart';
import '../../domain/usecases/card/search_cards_usecase.dart';
import '../../domain/usecases/card/delete_card_usecase.dart';
import '../../domain/usecases/card/add_card_usecase.dart';
import '../../domain/usecases/card/get_card_statistics_usecase.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/data_sync_service.dart';
import 'base_viewmodel.dart';

/// 卡片列表 ViewModel
class CardListViewModel extends BaseViewModel {
  final GetAllCardsUseCase _getAllCardsUseCase = sl<GetAllCardsUseCase>();
  final SearchCardsUseCase _searchCardsUseCase = sl<SearchCardsUseCase>();
  final DeleteCardUseCase _deleteCardUseCase = sl<DeleteCardUseCase>();
  final AddCardUseCase _addCardUseCase = sl<AddCardUseCase>();
  final GetCardStatisticsUseCase _getCardStatisticsUseCase = sl<GetCardStatisticsUseCase>();

  List<CardModel> _cards = [];
  List<CardModel> _filteredCards = [];
  String _searchQuery = '';
  CardSortType _sortType = CardSortType.nameAsc;
  CardStatistics? _statistics;

  /// 所有卡片
  List<CardModel> get cards => _filteredCards;

  /// 搜索查询
  String get searchQuery => _searchQuery;

  /// 排序类型
  CardSortType get sortType => _sortType;

  /// 统计信息
  CardStatistics? get statistics => _statistics;

  /// 是否有卡片
  bool get hasCards => _cards.isNotEmpty;

  /// 卡片数量
  int get cardCount => _cards.length;

  /// 筛选后的卡片数量
  int get filteredCardCount => _filteredCards.length;

  /// 初始化数据
  Future<void> initialize() async {
    await loadCards();
    await loadStatistics();
  }

  /// 加载所有卡片
  Future<void> loadCards() async {
    final cards = await executeAsync(
      () => _getAllCardsUseCase.execute(),
      errorPrefix: '加载卡片失败',
    );

    if (cards != null) {
      _cards = cards;
      _applyFiltersAndSort();
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadCards();
    await loadStatistics();
  }

  /// 搜索卡片
  Future<void> searchCards(String query) async {
    _searchQuery = query.trim();
    
    if (_searchQuery.isEmpty) {
      _filteredCards = List.from(_cards);
    } else {
      final searchResults = await executeAsync(
        () => _searchCardsUseCase.searchByName(_searchQuery),
        showLoading: false,
        errorPrefix: '搜索失败',
      );

      if (searchResults != null) {
        // 从原始列表中筛选出搜索结果
        _filteredCards = _cards.where((card) => 
          searchResults.any((result) => result.id == card.id)).toList();
      }
    }
    
    _applySorting();
    notifyListeners();
  }

  /// 按评级筛选
  Future<void> filterByGrade(String grade) async {
    if (grade.isEmpty) {
      _filteredCards = List.from(_cards);
    } else {
      final filterResults = await executeAsync(
        () => _searchCardsUseCase.filterByGrade(grade),
        showLoading: false,
        errorPrefix: '筛选失败',
      );

      if (filterResults != null) {
        _filteredCards = _cards.where((card) => 
          filterResults.any((result) => result.id == card.id)).toList();
      }
    }
    
    _applySorting();
    notifyListeners();
  }

  /// 按价格范围筛选
  Future<void> filterByPriceRange(double minPrice, double maxPrice) async {
    final filterResults = await executeAsync(
      () => _searchCardsUseCase.filterByPriceRange(minPrice, maxPrice),
      showLoading: false,
      errorPrefix: '筛选失败',
    );

    if (filterResults != null) {
      _filteredCards = _cards.where((card) => 
        filterResults.any((result) => result.id == card.id)).toList();
      _applySorting();
      notifyListeners();
    }
  }

  /// 综合搜索
  Future<void> searchWithFilters(CardSearchParams params) async {
    final searchResults = await executeAsync(
      () => _searchCardsUseCase.searchWithMultipleFilters(params),
      errorPrefix: '搜索失败',
    );

    if (searchResults != null) {
      _filteredCards = searchResults;
      _applySorting();
    }
  }

  /// 设置排序类型
  void setSortType(CardSortType sortType) {
    _sortType = sortType;
    _applySorting();
    notifyListeners();
  }

  /// 添加卡片
  Future<CardModel?> addCard(CardModel card) async {
    final addedCard = await executeAsync(
      () => _addCardUseCase.execute(card),
      errorPrefix: '添加卡片失败',
    );

    if (addedCard != null) {
      _cards.add(addedCard);
      _applyFiltersAndSort();
      await loadStatistics(); // 重新加载统计信息
    }

    return addedCard;
  }

  /// 删除卡片
  Future<bool> deleteCardModel(int cardId) async {
    final success = await executeAsyncVoid(
      () => _deleteCardUseCase.execute(cardId),
      errorPrefix: '删除卡片失败',
    );

    if (success) {
      _cards.removeWhere((card) => card.id == cardId);
      _filteredCards.removeWhere((card) => card.id == cardId);
      await loadStatistics(); // 重新加载统计信息
      notifyListeners();
      
      // 通知所有监听器刷新数据
      DataSyncService().notifyListeners(DataSyncEvents.cardDeleted);
      DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
    }

    return success;
  }

  /// 批量删除卡片
  Future<bool> deleteCards(List<int> cardIds) async {
    final success = await executeAsyncVoid(
      () => Future.wait(cardIds.map((id) => _deleteCardUseCase.execute(id))),
      errorPrefix: '批量删除失败',
    );

    if (success) {
      _cards.removeWhere((card) => cardIds.contains(card.id));
      _filteredCards.removeWhere((card) => cardIds.contains(card.id));
      await loadStatistics();
      notifyListeners();
      
      // 通知所有监听器刷新数据
      DataSyncService().notifyListeners(DataSyncEvents.cardDeleted);
      DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
    }

    return success;
  }

  /// 加载统计信息
  Future<void> loadStatistics() async {
    final stats = await executeAsync(
      () => _getCardStatisticsUseCase.getFullStatistics(),
      showLoading: false,
      errorPrefix: '加载统计信息失败',
    );

    if (stats != null) {
      _statistics = stats;
      notifyListeners();
    }
  }

  /// 清除筛选
  void clearFilters() {
    _searchQuery = '';
    _filteredCards = List.from(_cards);
    _applySorting();
    notifyListeners();
  }

  /// 应用筛选和排序
  void _applyFiltersAndSort() {
    _filteredCards = List.from(_cards);
    _applySorting();
    notifyListeners();
  }

  /// 应用排序
  void _applySorting() {
    switch (_sortType) {
      case CardSortType.nameAsc:
        _filteredCards.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CardSortType.nameDesc:
        _filteredCards.sort((a, b) => b.name.compareTo(a.name));
        break;
      case CardSortType.priceAsc:
        _filteredCards.sort((a, b) => a.acquiredPrice.compareTo(b.acquiredPrice));
        break;
      case CardSortType.priceDesc:
        _filteredCards.sort((a, b) => b.acquiredPrice.compareTo(a.acquiredPrice));
        break;
      case CardSortType.dateAsc:
        _filteredCards.sort((a, b) => a.acquiredDate.compareTo(b.acquiredDate));
        break;
      case CardSortType.dateDesc:
        _filteredCards.sort((a, b) => b.acquiredDate.compareTo(a.acquiredDate));
        break;
      case CardSortType.gradeAsc:
        _filteredCards.sort((a, b) => a.grade.compareTo(b.grade));
        break;
      case CardSortType.gradeDesc:
        _filteredCards.sort((a, b) => b.grade.compareTo(a.grade));
        break;
    }
  }
}

/// 卡片排序类型
enum CardSortType {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  dateAsc,
  dateDesc,
  gradeAsc,
  gradeDesc,
}