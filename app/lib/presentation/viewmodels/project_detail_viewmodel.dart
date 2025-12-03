import '../../domain/models/project/project.dart';
import '../../domain/models/card/card.dart';
import '../../domain/usecases/project/get_project_by_id_usecase.dart';
import '../../domain/usecases/project/add_project_usecase.dart';
import '../../domain/usecases/project/update_project_usecase.dart';
import '../../domain/usecases/project/delete_project_usecase.dart';
import '../../domain/usecases/project/manage_project_cards_usecase.dart';
import '../../domain/usecases/project/project_operations_usecase.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/data_sync_service.dart';
import 'base_viewmodel.dart';

/// 项目详情 ViewModel
class ProjectDetailViewModel extends BaseViewModel {
  final GetProjectByIdUseCase _getProjectByIdUseCase = sl<GetProjectByIdUseCase>();
  final AddProjectUseCase _addProjectUseCase = sl<AddProjectUseCase>();
  final UpdateProjectUseCase _updateProjectUseCase = sl<UpdateProjectUseCase>();
  final DeleteProjectUseCase _deleteProjectUseCase = sl<DeleteProjectUseCase>();
  final ManageProjectCardsUseCase _manageProjectCardsUseCase = sl<ManageProjectCardsUseCase>();
  final ProjectOperationsUseCase _projectOperationsUseCase = sl<ProjectOperationsUseCase>();

  ProjectModel? _project;
  bool _isEditing = false;
  bool _isNewProject = false;
  Map<String, dynamic>? _statistics;

  /// 当前项目
  ProjectModel? get project => _project;

  /// 是否正在编辑
  bool get isEditing => _isEditing;

  /// 是否是新项目
  bool get isNewProject => _isNewProject;

  /// 是否可以编辑
  bool get canEdit => _project != null;

  /// 是否可以删除
  bool get canDelete => _project != null && _project!.id != null;

  /// 项目统计信息
  Map<String, dynamic>? get statistics => _statistics;

  /// 项目中的卡片
  List<CardModel> get cards => _project?.cards ?? [];

  /// 卡片数量
  int get cardCount => cards.length;

  /// 项目总价值
  double get totalValue => cards.fold<double>(0.0, (sum, card) => sum + card.acquiredPrice);

  /// 初始化新项目
  void initializeNewProjectModel() {
    _isNewProject = true;
    _isEditing = true;
    _project = const ProjectModel(
      name: '',
      description: '',
      cards: [],
    );
    notifyListeners();
  }

  /// 加载项目详情
  Future<void> loadProjectModel(int projectId) async {
    _isNewProject = false;
    _isEditing = false;
    
    final project = await executeAsync(
      () => _getProjectByIdUseCase.execute(projectId),
      errorPrefix: '加载项目详情失败',
    );

    if (project != null) {
      _project = project;
      await loadStatistics();
    } else if (!hasError) {
      setError('项目不存在');
    }
  }

  /// 开始编辑
  void startEditing() {
    if (_project != null) {
      _isEditing = true;
      notifyListeners();
    }
  }

  /// 取消编辑
  void cancelEditing() {
    if (_isNewProject) {
      _project = null;
      _isNewProject = false;
    }
    _isEditing = false;
    notifyListeners();
  }

  /// 更新项目字段
  void updateProjectModel({
    String? name,
    String? description,
  }) {
    if (_project == null) return;

    _project = _project!.copyWith(
      name: name ?? _project!.name,
      description: description ?? _project!.description,
    );
    notifyListeners();
  }

  /// 保存项目
  Future<bool> saveProjectModel() async {
    if (_project == null) return false;

    ProjectModel? savedProject;
    
    if (_isNewProject) {
      savedProject = await executeAsync(
        () => _addProjectUseCase.execute(_project!),
        errorPrefix: '添加项目失败',
      );
    } else {
      savedProject = await executeAsync(
        () => _updateProjectUseCase.execute(_project!),
        errorPrefix: '更新项目失败',
      );
    }

    if (savedProject != null) {
      _project = savedProject;
      _isEditing = false;
      _isNewProject = false;
      await loadStatistics();
      notifyListeners();
      return true;
    }

    return false;
  }

  /// 删除项目
  Future<bool> deleteProjectModel({bool forceDelete = false}) async {
    if (_project?.id == null) return false;

    final success = await executeAsyncVoid(
      () => _deleteProjectUseCase.execute(_project!.id!, forceDelete: forceDelete),
      errorPrefix: '删除项目失败',
    );

    if (success) {
      _project = null;
      _isEditing = false;
      _isNewProject = false;
      _statistics = null;
      notifyListeners();
      
      // 通知所有监听器刷新数据
      DataSyncService().notifyListeners(DataSyncEvents.projectDeleted);
      DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
    }

    return success;
  }

  /// 向项目添加卡片
  Future<bool> addCardToProjectModel(CardModel card) async {
    if (_project?.id == null) return false;

    final updatedProject = await executeAsync(
      () => _manageProjectCardsUseCase.addCardToProjectModel(_project!.id!, card),
      errorPrefix: '添加卡片失败',
    );

    if (updatedProject != null) {
      _project = updatedProject;
      await loadStatistics();
      notifyListeners();
      
      // 通知所有监听器刷新数据
      DataSyncService().notifyListeners(DataSyncEvents.cardCreated);
      DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
      return true;
    }

    return false;
  }

  /// 从项目移除卡片
  Future<bool> removeCardFromProjectModel(int cardId) async {
    if (_project?.id == null) return false;

    final updatedProject = await executeAsync(
      () => _manageProjectCardsUseCase.removeCardFromProjectModel(_project!.id!, cardId),
      errorPrefix: '移除卡片失败',
    );

    if (updatedProject != null) {
      _project = updatedProject;
      await loadStatistics();
      notifyListeners();
      
      // 通知所有监听器刷新数据
      DataSyncService().notifyListeners(DataSyncEvents.cardDeleted);
      DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
      return true;
    }

    return false;
  }

  /// 批量添加卡片
  Future<bool> addCardsToProjectModel(List<CardModel> cards) async {
    if (_project?.id == null || cards.isEmpty) return false;

    final updatedProject = await executeAsync(
      () => _manageProjectCardsUseCase.addCardsToProjectModel(_project!.id!, cards),
      errorPrefix: '批量添加卡片失败',
    );

    if (updatedProject != null) {
      _project = updatedProject;
      await loadStatistics();
      notifyListeners();
      
      // 通知所有监听器刷新数据
      DataSyncService().notifyListeners(DataSyncEvents.cardCreated);
      DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
      return true;
    }

    return false;
  }

  /// 批量移除卡片
  Future<bool> removeCardsFromProjectModel(List<int> cardIds) async {
    if (_project?.id == null || cardIds.isEmpty) return false;

    final updatedProject = await executeAsync(
      () => _manageProjectCardsUseCase.removeCardsFromProjectModel(_project!.id!, cardIds),
      errorPrefix: '批量移除卡片失败',
    );

    if (updatedProject != null) {
      _project = updatedProject;
      await loadStatistics();
      notifyListeners();
      
      // 通知所有监听器刷新数据
      DataSyncService().notifyListeners(DataSyncEvents.cardDeleted);
      DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
      return true;
    }

    return false;
  }

  /// 获取特定评级的卡片
  Future<List<CardModel>> getCardsByGrade(String grade) async {
    if (_project?.id == null) return [];

    final cards = await executeAsync(
      () => _manageProjectCardsUseCase.getProjectCardsByGrade(_project!.id!, grade),
      showLoading: false,
      errorPrefix: '获取卡片失败',
    );

    return cards ?? [];
  }

  /// 获取价格范围内的卡片
  Future<List<CardModel>> getCardsByPriceRange(double minPrice, double maxPrice) async {
    if (_project?.id == null) return [];

    final cards = await executeAsync(
      () => _manageProjectCardsUseCase.getProjectCardsByPriceRange(_project!.id!, minPrice, maxPrice),
      showLoading: false,
      errorPrefix: '获取卡片失败',
    );

    return cards ?? [];
  }

  /// 复制项目
  Future<ProjectModel?> duplicateProjectModel(String newName, {bool includeCards = false}) async {
    if (_project?.id == null) return null;

    final duplicatedProject = await executeAsync(
      () => includeCards 
        ? _projectOperationsUseCase.duplicateProjectWithCards(_project!.id!, newName)
        : _projectOperationsUseCase.duplicateProjectModel(_project!.id!, newName),
      errorPrefix: '复制项目失败',
    );

    return duplicatedProject;
  }

  /// 加载统计信息
  Future<void> loadStatistics() async {
    if (_project?.id == null) return;

    final stats = await executeAsync(
      () => _projectOperationsUseCase.getProjectStatistics(_project!.id!),
      showLoading: false,
      errorPrefix: '加载统计信息失败',
    );

    if (stats != null) {
      _statistics = stats;
      notifyListeners();
    }
  }

  /// 验证项目数据
  Map<String, String?> validateProjectModel() {
    final errors = <String, String?>{};
    
    if (_project == null) {
      errors['general'] = '项目数据不能为空';
      return errors;
    }

    if (_project!.name.trim().isEmpty) {
      errors['name'] = '项目名称不能为空';
    } else if (_project!.name.trim().length > 100) {
      errors['name'] = '项目名称不能超过100个字符';
    }

    if (_project!.description.trim().isEmpty) {
      errors['description'] = '项目描述不能为空';
    } else if (_project!.description.trim().length > 500) {
      errors['description'] = '项目描述不能超过500个字符';
    }

    return errors;
  }

  /// 检查是否有未保存的更改
  bool hasUnsavedChanges() {
    return _isEditing;
  }

  /// 重置项目数据
  void resetProjectModel() {
    if (_isNewProject) {
      initializeNewProjectModel();
    } else if (_project?.id != null) {
      loadProjectModel(_project!.id!);
    }
  }

  /// 获取评级统计
  Map<String, int> getGradeStatistics() {
    final gradeStats = <String, int>{};
    for (final card in cards) {
      gradeStats[card.grade] = (gradeStats[card.grade] ?? 0) + 1;
    }
    return gradeStats;
  }

  /// 获取平均价格
  double getAveragePrice() {
    if (cards.isEmpty) return 0.0;
    return totalValue / cards.length;
  }

  /// 获取最贵的卡片
  CardModel? getMostExpensiveCardModel() {
    if (cards.isEmpty) return null;
    return cards.reduce((a, b) => a.acquiredPrice > b.acquiredPrice ? a : b);
  }

  /// 获取最便宜的卡片
  CardModel? getCheapestCardModel() {
    if (cards.isEmpty) return null;
    return cards.reduce((a, b) => a.acquiredPrice < b.acquiredPrice ? a : b);
  }
}