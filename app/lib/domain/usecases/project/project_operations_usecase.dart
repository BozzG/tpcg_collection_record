import '../../models/project/project.dart';
import '../../repositories/project_repository.dart';

/// 项目操作用例（复制、合并等高级操作）
class ProjectOperationsUseCase {
  final ProjectRepository _repository;

  ProjectOperationsUseCase(this._repository);

  /// 复制项目（不包含卡片）
  /// 
  /// [projectId] 原项目ID
  /// [newName] 新项目名称
  Future<ProjectModel> duplicateProjectModel(int projectId, String newName) async {
    if (projectId <= 0) {
      throw ArgumentError('项目ID必须大于0');
    }
    
    if (newName.trim().isEmpty) {
      throw ArgumentError('新项目名称不能为空');
    }
    
    if (newName.trim().length > 100) {
      throw ArgumentError('项目名称不能超过100个字符');
    }
    
    // 检查新名称是否已存在
    await _checkProjectNameExists(newName.trim());
    
    return await _repository.duplicateProjectModel(projectId, newName.trim());
  }

  /// 复制项目（包含卡片）
  /// 
  /// [projectId] 原项目ID
  /// [newName] 新项目名称
  Future<ProjectModel> duplicateProjectWithCards(int projectId, String newName) async {
    if (projectId <= 0) {
      throw ArgumentError('项目ID必须大于0');
    }
    
    if (newName.trim().isEmpty) {
      throw ArgumentError('新项目名称不能为空');
    }
    
    if (newName.trim().length > 100) {
      throw ArgumentError('项目名称不能超过100个字符');
    }
    
    // 检查新名称是否已存在
    await _checkProjectNameExists(newName.trim());
    
    return await _repository.duplicateProjectWithCards(projectId, newName.trim());
  }

  /// 合并项目
  /// 
  /// [targetProjectId] 目标项目ID（保留的项目）
  /// [sourceProjectId] 源项目ID（将被删除的项目）
  Future<ProjectModel> mergeProjects(int targetProjectId, int sourceProjectId) async {
    if (targetProjectId <= 0) {
      throw ArgumentError('目标项目ID必须大于0');
    }
    
    if (sourceProjectId <= 0) {
      throw ArgumentError('源项目ID必须大于0');
    }
    
    if (targetProjectId == sourceProjectId) {
      throw ArgumentError('目标项目和源项目不能是同一个项目');
    }
    
    // 检查两个项目是否都存在
    final targetProject = await _repository.getProjectById(targetProjectId);
    final sourceProject = await _repository.getProjectById(sourceProjectId);
    
    if (targetProject == null) {
      throw ArgumentError('目标项目不存在');
    }
    
    if (sourceProject == null) {
      throw ArgumentError('源项目不存在');
    }
    
    return await _repository.mergeProjects(targetProjectId, sourceProjectId);
  }

  /// 获取项目统计信息
  /// 
  /// [projectId] 项目ID
  Future<Map<String, dynamic>> getProjectStatistics(int projectId) async {
    if (projectId <= 0) {
      throw ArgumentError('项目ID必须大于0');
    }
    
    return await _repository.getProjectStatistics(projectId);
  }

  /// 批量删除项目
  /// 
  /// [projectIds] 要删除的项目ID列表
  /// [forceDelete] 是否强制删除（即使项目中有卡片）
  Future<void> deleteProjects(List<int> projectIds, {bool forceDelete = false}) async {
    if (projectIds.isEmpty) {
      throw ArgumentError('项目ID列表不能为空');
    }
    
    // 验证所有项目ID
    for (final id in projectIds) {
      if (id <= 0) {
        throw ArgumentError('项目ID必须大于0');
      }
    }
    
    // 如果不是强制删除，检查是否有项目包含卡片
    if (!forceDelete) {
      for (final id in projectIds) {
        final project = await _repository.getProjectById(id);
        if (project != null && project.cards.isNotEmpty) {
          throw ArgumentError('项目 "${project.name}" 中还有卡片，无法删除。请先移除所有卡片或使用强制删除');
        }
      }
    }
    
    await _repository.deleteProjects(projectIds);
  }

  /// 获取项目总数
  Future<int> getProjectCount() async {
    return await _repository.getProjectCount();
  }

  /// 获取所有项目的总价值
  Future<double> getAllProjectsTotalValue() async {
    return await _repository.getAllProjectsTotalValue();
  }

  /// 获取全局项目统计信息
  Future<GlobalProjectStatistics> getGlobalStatistics() async {
    final allProjects = await _repository.getAllProjects();
    final totalProjects = allProjects.length;
    final totalValue = await _repository.getAllProjectsTotalValue();
    
    // 计算总卡片数
    var totalCards = 0;
    var totalEmptyProjects = 0;
    var maxCardsInProject = 0;
    var minCardsInProject = totalProjects > 0 ? allProjects.first.cards.length : 0;
    String? largestProject;
    String? smallestProject;
    
    // 按卡片数量统计
    final cardCountDistribution = <int, int>{};
    
    for (final project in allProjects) {
      final cardCount = project.cards.length;
      totalCards += cardCount;
      
      if (cardCount == 0) {
        totalEmptyProjects++;
      }
      
      if (cardCount > maxCardsInProject) {
        maxCardsInProject = cardCount;
        largestProject = project.name;
      }
      
      if (cardCount < minCardsInProject) {
        minCardsInProject = cardCount;
        smallestProject = project.name;
      }
      
      cardCountDistribution[cardCount] = (cardCountDistribution[cardCount] ?? 0) + 1;
    }
    
    // 计算平均值
    final averageCardsPerProject = totalProjects > 0 ? totalCards / totalProjects : 0.0;
    final averageValuePerProject = totalProjects > 0 ? totalValue / totalProjects : 0.0;
    
    return GlobalProjectStatistics(
      totalProjects: totalProjects,
      totalCards: totalCards,
      totalValue: totalValue,
      totalEmptyProjects: totalEmptyProjects,
      averageCardsPerProject: averageCardsPerProject,
      averageValuePerProject: averageValuePerProject,
      maxCardsInProject: maxCardsInProject,
      minCardsInProject: minCardsInProject,
      largestProject: largestProject,
      smallestProject: smallestProject,
      cardCountDistribution: cardCountDistribution,
    );
  }

  /// 检查项目名称是否已存在
  Future<void> _checkProjectNameExists(String name) async {
    final existingProjects = await _repository.searchProjectsByName(name);
    if (existingProjects.any((project) => project.name == name)) {
      throw ArgumentError('项目名称 "$name" 已存在');
    }
  }
}

/// 全局项目统计信息
class GlobalProjectStatistics {
  final int totalProjects;
  final int totalCards;
  final double totalValue;
  final int totalEmptyProjects;
  final double averageCardsPerProject;
  final double averageValuePerProject;
  final int maxCardsInProject;
  final int minCardsInProject;
  final String? largestProject;
  final String? smallestProject;
  final Map<int, int> cardCountDistribution;

  GlobalProjectStatistics({
    required this.totalProjects,
    required this.totalCards,
    required this.totalValue,
    required this.totalEmptyProjects,
    required this.averageCardsPerProject,
    required this.averageValuePerProject,
    required this.maxCardsInProject,
    required this.minCardsInProject,
    this.largestProject,
    this.smallestProject,
    required this.cardCountDistribution,
  });

  /// 获取非空项目数量
  int get nonEmptyProjects => totalProjects - totalEmptyProjects;

  /// 获取空项目比例
  double get emptyProjectsPercentage => 
      totalProjects > 0 ? (totalEmptyProjects / totalProjects) * 100 : 0.0;
}