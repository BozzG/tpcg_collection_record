import '../../domain/models/project/project.dart';
import '../../domain/usecases/project/get_all_projects_usecase.dart';
import '../../domain/usecases/project/search_projects_usecase.dart';
import '../../domain/usecases/project/delete_project_usecase.dart';
import '../../domain/usecases/project/project_operations_usecase.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/data_sync_service.dart';
import 'base_viewmodel.dart';

/// 项目列表 ViewModel
class ProjectListViewModel extends BaseViewModel {
  final GetAllProjectsUseCase _getAllProjectsUseCase = sl<GetAllProjectsUseCase>();
  final SearchProjectsUseCase _searchProjectsUseCase = sl<SearchProjectsUseCase>();
  final DeleteProjectUseCase _deleteProjectUseCase = sl<DeleteProjectUseCase>();
  final ProjectOperationsUseCase _projectOperationsUseCase = sl<ProjectOperationsUseCase>();

  List<ProjectModel> _projects = [];
  List<ProjectModel> _filteredProjects = [];
  String _searchQuery = '';
  ProjectSortType _sortType = ProjectSortType.nameAsc;
  GlobalProjectStatistics? _statistics;

  /// 所有项目
  List<ProjectModel> get projects => _filteredProjects;

  /// 搜索查询
  String get searchQuery => _searchQuery;

  /// 排序类型
  ProjectSortType get sortType => _sortType;

  /// 统计信息
  GlobalProjectStatistics? get statistics => _statistics;

  /// 是否有项目
  bool get hasProjects => _projects.isNotEmpty;

  /// 项目数量
  int get projectCount => _projects.length;

  /// 筛选后的项目数量
  int get filteredProjectCount => _filteredProjects.length;

  /// 初始化数据
  Future<void> initialize() async {
    await loadProjects();
    await loadStatistics();
  }

  /// 加载所有项目
  Future<void> loadProjects() async {
    final projects = await executeAsync(
      () => _getAllProjectsUseCase.execute(),
      errorPrefix: '加载项目失败',
    );

    if (projects != null) {
      _projects = projects;
      _applyFiltersAndSort();
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadProjects();
    await loadStatistics();
  }

  /// 搜索项目
  Future<void> searchProjects(String query) async {
    _searchQuery = query.trim();
    
    if (_searchQuery.isEmpty) {
      _filteredProjects = List.from(_projects);
    } else {
      final searchResults = await executeAsync(
        () => _searchProjectsUseCase.searchByName(_searchQuery),
        showLoading: false,
        errorPrefix: '搜索失败',
      );

      if (searchResults != null) {
        _filteredProjects = _projects.where((project) => 
          searchResults.any((result) => result.id == project.id)).toList();
      }
    }
    
    _applySorting();
    notifyListeners();
  }

  /// 按描述搜索
  Future<void> searchByDescription(String description) async {
    if (description.trim().isEmpty) {
      _filteredProjects = List.from(_projects);
    } else {
      final searchResults = await executeAsync(
        () => _searchProjectsUseCase.searchByDescription(description.trim()),
        showLoading: false,
        errorPrefix: '搜索失败',
      );

      if (searchResults != null) {
        _filteredProjects = _projects.where((project) => 
          searchResults.any((result) => result.id == project.id)).toList();
      }
    }
    
    _applySorting();
    notifyListeners();
  }

  /// 综合搜索
  Future<void> searchWithFilters(ProjectSearchParams params) async {
    final searchResults = await executeAsync(
      () => _searchProjectsUseCase.searchWithMultipleFilters(params),
      errorPrefix: '搜索失败',
    );

    if (searchResults != null) {
      _filteredProjects = searchResults;
      _applySorting();
    }
  }

  /// 获取空项目
  Future<void> showEmptyProjects() async {
    final emptyProjects = await executeAsync(
      () => _searchProjectsUseCase.getEmptyProjects(),
      showLoading: false,
      errorPrefix: '获取空项目失败',
    );

    if (emptyProjects != null) {
      _filteredProjects = emptyProjects;
      _applySorting();
      notifyListeners();
    }
  }

  /// 获取最近项目
  Future<void> showRecentProjects(int limit) async {
    final recentProjects = await executeAsync(
      () => _searchProjectsUseCase.getRecentProjects(limit),
      showLoading: false,
      errorPrefix: '获取最近项目失败',
    );

    if (recentProjects != null) {
      _filteredProjects = recentProjects;
      _applySorting();
      notifyListeners();
    }
  }

  /// 获取最有价值项目
  Future<void> showMostValuableProjects(int limit) async {
    final valuableProjects = await executeAsync(
      () => _searchProjectsUseCase.getMostValuableProjects(limit),
      showLoading: false,
      errorPrefix: '获取最有价值项目失败',
    );

    if (valuableProjects != null) {
      _filteredProjects = valuableProjects;
      _applySorting();
      notifyListeners();
    }
  }

  /// 设置排序类型
  void setSortType(ProjectSortType sortType) {
    _sortType = sortType;
    _applySorting();
    notifyListeners();
  }

  /// 排序项目 (UI兼容方法)
  void sortProjects(String sortBy) {
    final sortType = _getSortType(sortBy);
    setSortType(sortType);
  }

  /// 将字符串转换为排序类型
  ProjectSortType _getSortType(String sortBy) {
    switch (sortBy) {
      case 'name':
        return ProjectSortType.nameAsc;
      case 'cardCount':
        return ProjectSortType.cardCountDesc; // 卡片数量默认降序
      case 'totalValue':
        return ProjectSortType.valueDesc; // 总价值默认降序
      default:
        return ProjectSortType.nameAsc;
    }
  }

  /// 删除项目
  Future<bool> deleteProjectModel(int projectId, {bool forceDelete = false}) async {
    final success = await executeAsyncVoid(
      () => _deleteProjectUseCase.execute(projectId, forceDelete: forceDelete),
      errorPrefix: '删除项目失败',
    );

    if (success) {
      _projects.removeWhere((project) => project.id == projectId);
      _filteredProjects.removeWhere((project) => project.id == projectId);
      await loadStatistics();
      notifyListeners();
      
      // 通知所有监听器刷新数据
      DataSyncService().notifyListeners(DataSyncEvents.projectDeleted);
      DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
    }

    return success;
  }

  /// 批量删除项目
  Future<bool> deleteProjects(List<int> projectIds, {bool forceDelete = false}) async {
    final success = await executeAsyncVoid(
      () => _projectOperationsUseCase.deleteProjects(projectIds, forceDelete: forceDelete),
      errorPrefix: '批量删除失败',
    );

    if (success) {
      _projects.removeWhere((project) => projectIds.contains(project.id));
      _filteredProjects.removeWhere((project) => projectIds.contains(project.id));
      await loadStatistics();
      notifyListeners();
    }

    return success;
  }

  /// 复制项目
  Future<ProjectModel?> duplicateProjectModel(int projectId, String newName, {bool includeCards = false}) async {
    final duplicatedProject = await executeAsync(
      () => includeCards 
        ? _projectOperationsUseCase.duplicateProjectWithCards(projectId, newName)
        : _projectOperationsUseCase.duplicateProjectModel(projectId, newName),
      errorPrefix: '复制项目失败',
    );

    if (duplicatedProject != null) {
      _projects.add(duplicatedProject);
      _applyFiltersAndSort();
      await loadStatistics();
    }

    return duplicatedProject;
  }

  /// 合并项目
  Future<ProjectModel?> mergeProjects(int targetProjectId, int sourceProjectId) async {
    final mergedProject = await executeAsync(
      () => _projectOperationsUseCase.mergeProjects(targetProjectId, sourceProjectId),
      errorPrefix: '合并项目失败',
    );

    if (mergedProject != null) {
      // 移除源项目，更新目标项目
      _projects.removeWhere((project) => project.id == sourceProjectId);
      final targetIndex = _projects.indexWhere((project) => project.id == targetProjectId);
      if (targetIndex != -1) {
        _projects[targetIndex] = mergedProject;
      }
      _applyFiltersAndSort();
      await loadStatistics();
    }

    return mergedProject;
  }

  /// 加载统计信息
  Future<void> loadStatistics() async {
    final stats = await executeAsync(
      () => _projectOperationsUseCase.getGlobalStatistics(),
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
    _filteredProjects = List.from(_projects);
    _applySorting();
    notifyListeners();
  }

  /// 应用筛选和排序
  void _applyFiltersAndSort() {
    _filteredProjects = List.from(_projects);
    _applySorting();
    notifyListeners();
  }

  /// 应用排序
  void _applySorting() {
    switch (_sortType) {
      case ProjectSortType.nameAsc:
        _filteredProjects.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProjectSortType.nameDesc:
        _filteredProjects.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProjectSortType.cardCountAsc:
        _filteredProjects.sort((a, b) => a.cards.length.compareTo(b.cards.length));
        break;
      case ProjectSortType.cardCountDesc:
        _filteredProjects.sort((a, b) => b.cards.length.compareTo(a.cards.length));
        break;
      case ProjectSortType.valueAsc:
        _filteredProjects.sort((a, b) {
          final aValue = a.cards.fold<double>(0.0, (sum, card) => sum + card.acquiredPrice);
          final bValue = b.cards.fold<double>(0.0, (sum, card) => sum + card.acquiredPrice);
          return aValue.compareTo(bValue);
        });
        break;
      case ProjectSortType.valueDesc:
        _filteredProjects.sort((a, b) {
          final aValue = a.cards.fold<double>(0.0, (sum, card) => sum + card.acquiredPrice);
          final bValue = b.cards.fold<double>(0.0, (sum, card) => sum + card.acquiredPrice);
          return bValue.compareTo(aValue);
        });
        break;
    }
  }
}

/// 项目排序类型
enum ProjectSortType {
  nameAsc,
  nameDesc,
  cardCountAsc,
  cardCountDesc,
  valueAsc,
  valueDesc,
}