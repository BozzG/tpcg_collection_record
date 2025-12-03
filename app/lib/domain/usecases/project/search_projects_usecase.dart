import '../../models/project/project.dart';
import '../../repositories/project_repository.dart';

/// 搜索项目用例
class SearchProjectsUseCase {
  final ProjectRepository _repository;

  SearchProjectsUseCase(this._repository);

  /// 根据名称搜索项目
  /// 
  /// [name] 搜索关键词
  Future<List<ProjectModel>> searchByName(String name) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('搜索关键词不能为空');
    }
    
    return await _repository.searchProjectsByName(name.trim());
  }

  /// 根据描述搜索项目
  /// 
  /// [description] 描述关键词
  Future<List<ProjectModel>> searchByDescription(String description) async {
    if (description.trim().isEmpty) {
      throw ArgumentError('描述关键词不能为空');
    }
    
    return await _repository.searchProjectsByDescription(description.trim());
  }

  /// 综合搜索（支持多个条件）
  /// 
  /// [searchParams] 搜索参数
  Future<List<ProjectModel>> searchWithMultipleFilters(ProjectSearchParams searchParams) async {
    List<ProjectModel> results = await _repository.getAllProjects();
    
    // 按名称筛选
    if (searchParams.name != null && searchParams.name!.trim().isNotEmpty) {
      final nameResults = await _repository.searchProjectsByName(searchParams.name!.trim());
      results = results.where((project) => 
        nameResults.any((nameProject) => nameProject.id == project.id)).toList();
    }
    
    // 按描述筛选
    if (searchParams.description != null && searchParams.description!.trim().isNotEmpty) {
      results = results.where((project) => 
        project.description.toLowerCase().contains(searchParams.description!.toLowerCase())).toList();
    }
    
    // 按卡片数量范围筛选
    if (searchParams.minCardCount != null && searchParams.maxCardCount != null) {
      results = results.where((project) => 
        project.cards.length >= searchParams.minCardCount! && 
        project.cards.length <= searchParams.maxCardCount!).toList();
    }
    
    // 按项目价值范围筛选
    if (searchParams.minValue != null && searchParams.maxValue != null) {
      results = results.where((project) {
        final totalValue = project.cards.fold<double>(
          0.0, (sum, card) => sum + card.acquiredPrice);
        return totalValue >= searchParams.minValue! && totalValue <= searchParams.maxValue!;
      }).toList();
    }
    
    // 按是否包含特定评级的卡片筛选
    if (searchParams.containsGrade != null && searchParams.containsGrade!.trim().isNotEmpty) {
      results = results.where((project) => 
        project.cards.any((card) => card.grade == searchParams.containsGrade)).toList();
    }
    
    return results;
  }

  /// 获取最近创建的项目
  /// 
  /// [limit] 限制数量
  Future<List<ProjectModel>> getRecentProjects(int limit) async {
    if (limit <= 0) {
      throw ArgumentError('限制数量必须大于0');
    }
    
    return await _repository.getRecentProjects(limit);
  }

  /// 获取最有价值的项目
  /// 
  /// [limit] 限制数量
  Future<List<ProjectModel>> getMostValuableProjects(int limit) async {
    if (limit <= 0) {
      throw ArgumentError('限制数量必须大于0');
    }
    
    return await _repository.getMostValuableProjects(limit);
  }

  /// 获取空项目（没有卡片的项目）
  Future<List<ProjectModel>> getEmptyProjects() async {
    final allProjects = await _repository.getAllProjects();
    return allProjects.where((project) => project.cards.isEmpty).toList();
  }

  /// 获取包含特定数量卡片的项目
  /// 
  /// [cardCount] 卡片数量
  Future<List<ProjectModel>> getProjectsByCardCount(int cardCount) async {
    if (cardCount < 0) {
      throw ArgumentError('卡片数量不能为负数');
    }
    
    final allProjects = await _repository.getAllProjects();
    return allProjects.where((project) => project.cards.length == cardCount).toList();
  }
}

/// 项目搜索参数
class ProjectSearchParams {
  final String? name;
  final String? description;
  final int? minCardCount;
  final int? maxCardCount;
  final double? minValue;
  final double? maxValue;
  final String? containsGrade;

  ProjectSearchParams({
    this.name,
    this.description,
    this.minCardCount,
    this.maxCardCount,
    this.minValue,
    this.maxValue,
    this.containsGrade,
  });
}