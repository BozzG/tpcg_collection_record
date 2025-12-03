import '../../domain/models/project/project.dart';
import '../../domain/models/card/card.dart';
import '../../domain/usecases/project/get_all_projects_usecase.dart';
import '../../domain/usecases/project/search_projects_usecase.dart';
import '../../domain/usecases/project/project_operations_usecase.dart';
import '../../domain/usecases/card/get_all_cards_usecase.dart';
import '../../domain/usecases/card/get_card_statistics_usecase.dart';
import '../../core/di/service_locator.dart';
import 'base_viewmodel.dart';

/// 主页 ViewModel
class HomeViewModel extends BaseViewModel {
  final GetAllProjectsUseCase _getAllProjectsUseCase = sl<GetAllProjectsUseCase>();
  final SearchProjectsUseCase _searchProjectsUseCase = sl<SearchProjectsUseCase>();
  final ProjectOperationsUseCase _projectOperationsUseCase = sl<ProjectOperationsUseCase>();
  final GetAllCardsUseCase _getAllCardsUseCase = sl<GetAllCardsUseCase>();
  final GetCardStatisticsUseCase _getCardStatisticsUseCase = sl<GetCardStatisticsUseCase>();

  List<ProjectModel> _recentProjects = [];
  List<ProjectModel> _valuableProjects = [];
  List<CardModel> _recentCards = [];
  CardStatistics? _cardStatistics;
  GlobalProjectStatistics? _projectStatistics;
  HomeData? _homeData;

  /// 最近项目
  List<ProjectModel> get recentProjects => _recentProjects;

  /// 最有价值项目
  List<ProjectModel> get valuableProjects => _valuableProjects;

  /// 最近卡片
  List<CardModel> get recentCards => _recentCards;

  /// 卡片统计
  CardStatistics? get cardStatistics => _cardStatistics;

  /// 项目统计
  GlobalProjectStatistics? get projectStatistics => _projectStatistics;

  /// 主页数据
  HomeData? get homeData => _homeData;

  /// 加载仪表板数据 (UI兼容方法)
  Future<void> loadDashboardData() async {
    await loadHomeData();
  }

  /// 总卡片数 (UI便捷访问)
  int get totalCards => _homeData?.totalCards ?? 0;

  /// 总项目数 (UI便捷访问)
  int get totalProjects => _homeData?.totalProjects ?? 0;

  /// 总价值 (UI便捷访问)
  double get totalValue => _homeData?.totalValue ?? 0.0;

  /// 平均价值 (UI便捷访问)
  double get averageValue => _homeData?.averageValuePerProject ?? 0.0;

  /// 初始化主页数据
  Future<void> initialize() async {
    await loadHomeData();
  }

  /// 加载主页数据
  Future<void> loadHomeData() async {
    await Future.wait([
      loadRecentProjects(),
      loadValuableProjects(),
      loadRecentCards(),
      loadCardStatistics(),
      loadProjectStatistics(),
    ]);
    
    _generateHomeData();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadHomeData();
  }

  /// 加载最近项目
  Future<void> loadRecentProjects() async {
    final projects = await executeAsync(
      () => _searchProjectsUseCase.getRecentProjects(5),
      showLoading: false,
      errorPrefix: '加载最近项目失败',
    );

    if (projects != null) {
      _recentProjects = projects;
    }
  }

  /// 加载最有价值项目
  Future<void> loadValuableProjects() async {
    final projects = await executeAsync(
      () => _searchProjectsUseCase.getMostValuableProjects(5),
      showLoading: false,
      errorPrefix: '加载最有价值项目失败',
    );

    if (projects != null) {
      _valuableProjects = projects;
    }
  }

  /// 加载最近卡片
  Future<void> loadRecentCards() async {
    final cards = await executeAsync(
      () => _getAllCardsUseCase.execute(),
      showLoading: false,
      errorPrefix: '加载最近卡片失败',
    );

    if (cards != null) {
      // 按入手时间排序，取最近的5张
      cards.sort((a, b) => b.acquiredDate.compareTo(a.acquiredDate));
      _recentCards = cards.take(5).toList();
    }
  }

  /// 加载卡片统计
  Future<void> loadCardStatistics() async {
    final stats = await executeAsync(
      () => _getCardStatisticsUseCase.getFullStatistics(),
      showLoading: false,
      errorPrefix: '加载卡片统计失败',
    );

    if (stats != null) {
      _cardStatistics = stats;
    }
  }

  /// 加载项目统计
  Future<void> loadProjectStatistics() async {
    final stats = await executeAsync(
      () => _projectOperationsUseCase.getGlobalStatistics(),
      showLoading: false,
      errorPrefix: '加载项目统计失败',
    );

    if (stats != null) {
      _projectStatistics = stats;
    }
  }

  /// 生成主页数据
  void _generateHomeData() {
    if (_cardStatistics == null || _projectStatistics == null) return;

    _homeData = HomeData(
      totalProjects: _projectStatistics!.totalProjects,
      totalCards: _projectStatistics!.totalCards,
      totalValue: _projectStatistics!.totalValue,
      averageValuePerProject: _projectStatistics!.averageValuePerProject,
      averageCardsPerProject: _projectStatistics!.averageCardsPerProject,
      mostPopularGrade: _cardStatistics!.mostPopularGrade,
      mostValuableGrade: _cardStatistics!.mostValuableGrade,
      mostActiveYear: _cardStatistics!.mostActiveYear,
      recentProjectsCount: _recentProjects.length,
      emptyProjectsCount: _projectStatistics!.totalEmptyProjects,
    );

    notifyListeners();
  }

  /// 获取快速统计数据
  List<QuickStat> getQuickStats() {
    if (_homeData == null) return [];

    return [
      QuickStat(
        title: '项目总数',
        value: _homeData!.totalProjects.toString(),
        icon: 'folder',
        color: 'blue',
      ),
      QuickStat(
        title: '卡片总数',
        value: _homeData!.totalCards.toString(),
        icon: 'card',
        color: 'green',
      ),
      QuickStat(
        title: '总价值',
        value: '¥${_homeData!.totalValue.toStringAsFixed(2)}',
        icon: 'money',
        color: 'orange',
      ),
      QuickStat(
        title: '平均价值',
        value: '¥${_homeData!.averageValuePerProject.toStringAsFixed(2)}',
        icon: 'chart',
        color: 'purple',
      ),
    ];
  }

  /// 获取趋势数据
  List<TrendData> getTrendData() {
    if (_cardStatistics == null) return [];

    return _cardStatistics!.yearStatistics.entries.map((entry) => 
      TrendData(
        year: entry.key,
        count: entry.value,
      )
    ).toList()..sort((a, b) => a.year.compareTo(b.year));
  }

  /// 获取评级分布数据
  List<GradeDistribution> getGradeDistribution() {
    if (_cardStatistics == null) return [];

    return _cardStatistics!.gradeStatistics.entries.map((entry) => 
      GradeDistribution(
        grade: entry.key,
        count: entry.value,
        value: _cardStatistics!.gradeValues[entry.key] ?? 0.0,
      )
    ).toList()..sort((a, b) => b.count.compareTo(a.count));
  }
}

/// 主页数据
class HomeData {
  final int totalProjects;
  final int totalCards;
  final double totalValue;
  final double averageValuePerProject;
  final double averageCardsPerProject;
  final String? mostPopularGrade;
  final String? mostValuableGrade;
  final String? mostActiveYear;
  final int recentProjectsCount;
  final int emptyProjectsCount;

  HomeData({
    required this.totalProjects,
    required this.totalCards,
    required this.totalValue,
    required this.averageValuePerProject,
    required this.averageCardsPerProject,
    this.mostPopularGrade,
    this.mostValuableGrade,
    this.mostActiveYear,
    required this.recentProjectsCount,
    required this.emptyProjectsCount,
  });
}

/// 快速统计数据
class QuickStat {
  final String title;
  final String value;
  final String icon;
  final String color;

  QuickStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

/// 趋势数据
class TrendData {
  final String year;
  final int count;

  TrendData({
    required this.year,
    required this.count,
  });
}

/// 评级分布数据
class GradeDistribution {
  final String grade;
  final int count;
  final double value;

  GradeDistribution({
    required this.grade,
    required this.count,
    required this.value,
  });
}