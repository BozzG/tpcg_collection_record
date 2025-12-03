import '../models/project/project.dart';
import '../models/card/card.dart';

/// 项目仓储接口
/// 定义项目数据操作的抽象方法
abstract class ProjectRepository {
  /// 获取所有项目
  Future<List<ProjectModel>> getAllProjects();

  /// 根据ID获取项目
  Future<ProjectModel?> getProjectById(int id);

  /// 添加新项目
  Future<ProjectModel> addProjectModel(ProjectModel project);

  /// 更新项目信息
  Future<ProjectModel> updateProjectModel(ProjectModel project);

  /// 删除项目
  Future<void> deleteProjectModel(int id);

  /// 根据名称搜索项目
  Future<List<ProjectModel>> searchProjectsByName(String name);

  /// 根据描述搜索项目
  Future<List<ProjectModel>> searchProjectsByDescription(String description);

  /// 向项目中添加卡片
  Future<ProjectModel> addCardToProjectModel(int projectId, CardModel card);

  /// 从项目中移除卡片
  Future<ProjectModel> removeCardFromProjectModel(int projectId, int cardId);

  /// 批量向项目中添加卡片
  Future<ProjectModel> addCardsToProjectModel(int projectId, List<CardModel> cards);

  /// 批量从项目中移除卡片
  Future<ProjectModel> removeCardsFromProjectModel(int projectId, List<int> cardIds);

  /// 获取项目中的卡片数量
  Future<int> getProjectCardCount(int projectId);

  /// 获取项目中卡片的总价值
  Future<double> getProjectTotalValue(int projectId);

  /// 获取项目中特定评级的卡片
  Future<List<CardModel>> getProjectCardsByGrade(int projectId, String grade);

  /// 获取项目中价格范围内的卡片
  Future<List<CardModel>> getProjectCardsByPriceRange(
    int projectId,
    double minPrice,
    double maxPrice,
  );

  /// 复制项目（不包含卡片）
  Future<ProjectModel> duplicateProjectModel(int projectId, String newName);

  /// 复制项目（包含卡片）
  Future<ProjectModel> duplicateProjectWithCards(int projectId, String newName);

  /// 合并项目（将源项目的卡片合并到目标项目）
  Future<ProjectModel> mergeProjects(int targetProjectId, int sourceProjectId);

  /// 获取项目统计信息
  Future<Map<String, dynamic>> getProjectStatistics(int projectId);

  /// 批量删除项目
  Future<void> deleteProjects(List<int> ids);

  /// 获取项目总数
  Future<int> getProjectCount();

  /// 获取所有项目的总价值
  Future<double> getAllProjectsTotalValue();

  /// 获取最近创建的项目
  Future<List<ProjectModel>> getRecentProjects(int limit);

  /// 获取最有价值的项目
  Future<List<ProjectModel>> getMostValuableProjects(int limit);
}