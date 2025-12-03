import '../../domain/models/project/project.dart';
import '../../domain/models/card/card.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/local_project_datasource.dart';
import '../datasources/local_card_datasource.dart';

/// ProjectRepository 的具体实现
/// 使用本地数据源进行项目数据操作
class ProjectRepositoryImpl implements ProjectRepository {
  final LocalProjectDataSource _localProjectDataSource;
  final LocalCardDataSource _localCardDataSource;

  ProjectRepositoryImpl(
    this._localProjectDataSource,
    this._localCardDataSource,
  );

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    try {
      return await _localProjectDataSource.getAllProjects();
    } catch (e) {
      throw Exception('获取所有项目失败: $e');
    }
  }

  @override
  Future<ProjectModel?> getProjectById(int id) async {
    try {
      return await _localProjectDataSource.getProjectById(id);
    } catch (e) {
      throw Exception('根据ID获取项目失败: $e');
    }
  }

  @override
  Future<ProjectModel> addProjectModel(ProjectModel project) async {
    try {
      return await _localProjectDataSource.insertProjectModel(project);
    } catch (e) {
      throw Exception('添加项目失败: $e');
    }
  }

  @override
  Future<ProjectModel> updateProjectModel(ProjectModel project) async {
    try {
      if (project.id == null) {
        throw Exception('更新项目时ID不能为空');
      }
      return await _localProjectDataSource.updateProjectModel(project);
    } catch (e) {
      throw Exception('更新项目失败: $e');
    }
  }

  @override
  Future<void> deleteProjectModel(int id) async {
    try {
      await _localProjectDataSource.deleteProjectModel(id);
    } catch (e) {
      throw Exception('删除项目失败: $e');
    }
  }

  @override
  Future<List<ProjectModel>> searchProjectsByName(String name) async {
    try {
      if (name.trim().isEmpty) {
        return [];
      }
      return await _localProjectDataSource.searchProjectsByName(name.trim());
    } catch (e) {
      throw Exception('根据名称搜索项目失败: $e');
    }
  }

  @override
  Future<List<ProjectModel>> searchProjectsByDescription(
    String description,
  ) async {
    try {
      if (description.trim().isEmpty) {
        return [];
      }
      return await _localProjectDataSource.searchProjectsByDescription(
        description.trim(),
      );
    } catch (e) {
      throw Exception('根据描述搜索项目失败: $e');
    }
  }

  @override
  Future<ProjectModel> addCardToProjectModel(
    int projectId,
    CardModel card,
  ) async {
    try {
      // 先添加卡片（如果还没有ID）
      CardModel savedCard = card;
      if (card.id == null) {
        savedCard = await _localCardDataSource.insertCardModel(card);
      }

      // 将卡片关联到项目
      await _localProjectDataSource.addCardToProjectModel(
        projectId,
        savedCard.id!,
      );

      // 返回更新后的项目
      final project = await _localProjectDataSource.getProjectById(projectId);
      if (project == null) {
        throw Exception('项目不存在');
      }
      return project;
    } catch (e) {
      throw Exception('向项目添加卡片失败: $e');
    }
  }

  @override
  Future<ProjectModel> removeCardFromProjectModel(
    int projectId,
    int cardId,
  ) async {
    try {
      await _localProjectDataSource.removeCardFromProjectModel(cardId);

      // 返回更新后的项目
      final project = await _localProjectDataSource.getProjectById(projectId);
      if (project == null) {
        throw Exception('项目不存在');
      }
      return project;
    } catch (e) {
      throw Exception('从项目移除卡片失败: $e');
    }
  }

  @override
  Future<ProjectModel> addCardsToProjectModel(
    int projectId,
    List<CardModel> cards,
  ) async {
    try {
      if (cards.isEmpty) {
        final project = await _localProjectDataSource.getProjectById(projectId);
        if (project == null) {
          throw Exception('项目不存在');
        }
        return project;
      }

      // 先保存所有卡片
      final List<int> cardIds = [];
      for (final card in cards) {
        if (card.id == null) {
          final savedCard = await _localCardDataSource.insertCardModel(card);
          cardIds.add(savedCard.id!);
        } else {
          cardIds.add(card.id!);
        }
      }

      // 批量关联到项目
      await _localProjectDataSource.addCardsToProjectModel(projectId, cardIds);

      // 返回更新后的项目
      final project = await _localProjectDataSource.getProjectById(projectId);
      if (project == null) {
        throw Exception('项目不存在');
      }
      return project;
    } catch (e) {
      throw Exception('批量向项目添加卡片失败: $e');
    }
  }

  @override
  Future<ProjectModel> removeCardsFromProjectModel(
    int projectId,
    List<int> cardIds,
  ) async {
    try {
      if (cardIds.isEmpty) {
        final project = await _localProjectDataSource.getProjectById(projectId);
        if (project == null) {
          throw Exception('项目不存在');
        }
        return project;
      }

      await _localProjectDataSource.removeCardsFromProjectModel(cardIds);

      // 返回更新后的项目
      final project = await _localProjectDataSource.getProjectById(projectId);
      if (project == null) {
        throw Exception('项目不存在');
      }
      return project;
    } catch (e) {
      throw Exception('批量从项目移除卡片失败: $e');
    }
  }

  @override
  Future<int> getProjectCardCount(int projectId) async {
    try {
      return await _localProjectDataSource.getProjectCardCount(projectId);
    } catch (e) {
      throw Exception('获取项目卡片数量失败: $e');
    }
  }

  @override
  Future<double> getProjectTotalValue(int projectId) async {
    try {
      return await _localProjectDataSource.getProjectTotalValue(projectId);
    } catch (e) {
      throw Exception('获取项目总价值失败: $e');
    }
  }

  @override
  Future<List<CardModel>> getProjectCardsByGrade(
    int projectId,
    String grade,
  ) async {
    try {
      final projectCards = await _localCardDataSource.getCardsByProjectId(
        projectId,
      );
      return projectCards.where((card) => card.grade == grade).toList();
    } catch (e) {
      throw Exception('获取项目中特定评级的卡片失败: $e');
    }
  }

  @override
  Future<List<CardModel>> getProjectCardsByPriceRange(
    int projectId,
    double minPrice,
    double maxPrice,
  ) async {
    try {
      if (minPrice < 0 || maxPrice < 0 || minPrice > maxPrice) {
        throw Exception('价格范围参数无效');
      }
      final projectCards = await _localCardDataSource.getCardsByProjectId(
        projectId,
      );
      return projectCards.where((card) {
        return card.acquiredPrice >= minPrice && card.acquiredPrice <= maxPrice;
      }).toList();
    } catch (e) {
      throw Exception('获取项目中价格范围内的卡片失败: $e');
    }
  }

  @override
  Future<ProjectModel> duplicateProjectModel(
    int projectId,
    String newName,
  ) async {
    try {
      final originalProject = await _localProjectDataSource.getProjectById(
        projectId,
      );
      if (originalProject == null) {
        throw Exception('原项目不存在');
      }

      final newProject = ProjectModel(
        name: newName,
        description: originalProject.description,
        cards: [], // 不包含卡片
      );

      return await _localProjectDataSource.insertProjectModel(newProject);
    } catch (e) {
      throw Exception('复制项目失败: $e');
    }
  }

  @override
  Future<ProjectModel> duplicateProjectWithCards(
    int projectId,
    String newName,
  ) async {
    try {
      final originalProject = await _localProjectDataSource.getProjectById(
        projectId,
      );
      if (originalProject == null) {
        throw Exception('原项目不存在');
      }

      // 复制卡片（不包含ID，让数据库重新分配）
      final duplicatedCards = originalProject.cards
          .map(
            (card) => CardModel(
              name: card.name,
              issueNumber: card.issueNumber,
              issueDate: card.issueDate,
              grade: card.grade,
              acquiredDate: card.acquiredDate,
              acquiredPrice: card.acquiredPrice,
              frontImage: card.frontImage,
              backImage: card.backImage,
              gradeImage: card.gradeImage,
            ),
          )
          .toList();

      final newProject = ProjectModel(
        name: newName,
        description: originalProject.description,
        cards: duplicatedCards,
      );

      return await _localProjectDataSource.insertProjectModel(newProject);
    } catch (e) {
      throw Exception('复制项目（包含卡片）失败: $e');
    }
  }

  @override
  Future<ProjectModel> mergeProjects(
    int targetProjectId,
    int sourceProjectId,
  ) async {
    try {
      final targetProject = await _localProjectDataSource.getProjectById(
        targetProjectId,
      );
      final sourceProject = await _localProjectDataSource.getProjectById(
        sourceProjectId,
      );

      if (targetProject == null || sourceProject == null) {
        throw Exception('目标项目或源项目不存在');
      }

      // 将源项目的卡片移动到目标项目
      final sourceCardIds = sourceProject.cards
          .map((card) => card.id!)
          .toList();
      if (sourceCardIds.isNotEmpty) {
        await _localProjectDataSource.addCardsToProjectModel(
          targetProjectId,
          sourceCardIds,
        );
      }

      // 删除源项目
      await _localProjectDataSource.deleteProjectModel(sourceProjectId);

      // 返回更新后的目标项目
      final updatedProject = await _localProjectDataSource.getProjectById(
        targetProjectId,
      );
      if (updatedProject == null) {
        throw Exception('目标项目不存在');
      }
      return updatedProject;
    } catch (e) {
      throw Exception('合并项目失败: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getProjectStatistics(int projectId) async {
    try {
      final project = await _localProjectDataSource.getProjectById(projectId);
      if (project == null) {
        throw Exception('项目不存在');
      }

      final cardCount = project.cards.length;
      final totalValue = project.cards.fold<double>(
        0.0,
        (sum, card) => sum + card.acquiredPrice,
      );

      // 按评级统计
      final gradeStats = <String, int>{};
      for (final card in project.cards) {
        gradeStats[card.grade] = (gradeStats[card.grade] ?? 0) + 1;
      }

      // 平均价格
      final averagePrice = cardCount > 0 ? totalValue / cardCount : 0.0;

      return {
        'cardCount': cardCount,
        'totalValue': totalValue,
        'averagePrice': averagePrice,
        'gradeStatistics': gradeStats,
      };
    } catch (e) {
      throw Exception('获取项目统计信息失败: $e');
    }
  }

  @override
  Future<void> deleteProjects(List<int> ids) async {
    try {
      if (ids.isEmpty) {
        return;
      }
      await _localProjectDataSource.deleteProjects(ids);
    } catch (e) {
      throw Exception('批量删除项目失败: $e');
    }
  }

  @override
  Future<int> getProjectCount() async {
    try {
      return await _localProjectDataSource.getProjectCount();
    } catch (e) {
      throw Exception('获取项目总数失败: $e');
    }
  }

  @override
  Future<double> getAllProjectsTotalValue() async {
    try {
      return await _localProjectDataSource.getAllProjectsTotalValue();
    } catch (e) {
      throw Exception('获取所有项目总价值失败: $e');
    }
  }

  @override
  Future<List<ProjectModel>> getRecentProjects(int limit) async {
    try {
      final allProjects = await _localProjectDataSource.getAllProjects();
      return allProjects.take(limit).toList();
    } catch (e) {
      throw Exception('获取最近创建的项目失败: $e');
    }
  }

  @override
  Future<List<ProjectModel>> getMostValuableProjects(int limit) async {
    try {
      final allProjects = await _localProjectDataSource.getAllProjects();

      // 计算每个项目的总价值并排序
      final projectsWithValue = allProjects.map((project) {
        final totalValue = project.cards.fold<double>(
          0.0,
          (sum, card) => sum + card.acquiredPrice,
        );
        return {'project': project, 'value': totalValue};
      }).toList();

      projectsWithValue.sort(
        (a, b) => (b['value'] as double).compareTo(a['value'] as double),
      );

      return projectsWithValue
          .take(limit)
          .map((item) => item['project'] as ProjectModel)
          .toList();
    } catch (e) {
      throw Exception('获取最有价值的项目失败: $e');
    }
  }
}
