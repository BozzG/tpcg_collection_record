import '../../domain/models/project/project.dart';
import '../../domain/models/card/card.dart';
import 'database_helper.dart';

/// 项目本地数据源
/// 负责项目数据的本地存储操作
class LocalProjectDataSource {
  /// 获取所有项目
  Future<List<ProjectModel>> getAllProjects() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableProjects,
      orderBy: '${DatabaseHelper.columnProjectCreatedAt} DESC',
    );

    final List<ProjectModel> projects = [];
    for (final map in maps) {
      final project = await _mapToProjectModel(map);
      projects.add(project);
    }

    return projects;
  }

  /// 根据ID获取项目
  Future<ProjectModel?> getProjectById(int id) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableProjects,
      where: '${DatabaseHelper.columnProjectId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return await _mapToProjectModel(maps.first);
    }
    return null;
  }

  /// 添加项目
  Future<ProjectModel> insertProjectModel(ProjectModel project) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now().toIso8601String();

    final id = await db.insert(DatabaseHelper.tableProjects, {
      DatabaseHelper.columnProjectName: project.name,
      DatabaseHelper.columnProjectDescription: project.description,
      DatabaseHelper.columnProjectCreatedAt: now,
      DatabaseHelper.columnProjectUpdatedAt: now,
    });

    // 如果项目包含卡片，需要更新卡片的项目ID
    if (project.cards.isNotEmpty) {
      await _updateCardsProjectId(project.cards, id);
    }

    return project.copyWith(id: id);
  }

  /// 更新项目
  Future<ProjectModel> updateProjectModel(ProjectModel project) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      DatabaseHelper.tableProjects,
      {
        DatabaseHelper.columnProjectName: project.name,
        DatabaseHelper.columnProjectDescription: project.description,
        DatabaseHelper.columnProjectUpdatedAt: now,
      },
      where: '${DatabaseHelper.columnProjectId} = ?',
      whereArgs: [project.id],
    );

    return project;
  }

  /// 删除项目
  Future<void> deleteProjectModel(int id) async {
    final db = await DatabaseHelper.database;

    // 先将关联的卡片的项目ID设为null
    await db.update(
      DatabaseHelper.tableCards,
      {DatabaseHelper.columnCardProjectId: null},
      where: '${DatabaseHelper.columnCardProjectId} = ?',
      whereArgs: [id],
    );

    // 删除项目
    await db.delete(
      DatabaseHelper.tableProjects,
      where: '${DatabaseHelper.columnProjectId} = ?',
      whereArgs: [id],
    );
  }

  /// 根据名称搜索项目
  Future<List<ProjectModel>> searchProjectsByName(String name) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableProjects,
      where: '${DatabaseHelper.columnProjectName} LIKE ?',
      whereArgs: ['%$name%'],
      orderBy: '${DatabaseHelper.columnProjectCreatedAt} DESC',
    );

    final List<ProjectModel> projects = [];
    for (final map in maps) {
      final project = await _mapToProjectModel(map);
      projects.add(project);
    }

    return projects;
  }

  /// 根据描述搜索项目
  Future<List<ProjectModel>> searchProjectsByDescription(String description) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableProjects,
      where: '${DatabaseHelper.columnProjectDescription} LIKE ?',
      whereArgs: ['%$description%'],
      orderBy: '${DatabaseHelper.columnProjectCreatedAt} DESC',
    );

    final List<ProjectModel> projects = [];
    for (final map in maps) {
      final project = await _mapToProjectModel(map);
      projects.add(project);
    }

    return projects;
  }

  /// 向项目添加卡片
  Future<void> addCardToProjectModel(int projectId, int cardId) async {
    final db = await DatabaseHelper.database;
    await db.update(
      DatabaseHelper.tableCards,
      {
        DatabaseHelper.columnCardProjectId: projectId,
        DatabaseHelper.columnCardUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseHelper.columnCardId} = ?',
      whereArgs: [cardId],
    );
  }

  /// 从项目移除卡片
  Future<void> removeCardFromProjectModel(int cardId) async {
    final db = await DatabaseHelper.database;
    await db.update(
      DatabaseHelper.tableCards,
      {
        DatabaseHelper.columnCardProjectId: null,
        DatabaseHelper.columnCardUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseHelper.columnCardId} = ?',
      whereArgs: [cardId],
    );
  }

  /// 批量向项目添加卡片
  Future<void> addCardsToProjectModel(int projectId, List<int> cardIds) async {
    final db = await DatabaseHelper.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (final cardId in cardIds) {
      batch.update(
        DatabaseHelper.tableCards,
        {
          DatabaseHelper.columnCardProjectId: projectId,
          DatabaseHelper.columnCardUpdatedAt: now,
        },
        where: '${DatabaseHelper.columnCardId} = ?',
        whereArgs: [cardId],
      );
    }

    await batch.commit();
  }

  /// 批量从项目移除卡片
  Future<void> removeCardsFromProjectModel(List<int> cardIds) async {
    final db = await DatabaseHelper.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (final cardId in cardIds) {
      batch.update(
        DatabaseHelper.tableCards,
        {
          DatabaseHelper.columnCardProjectId: null,
          DatabaseHelper.columnCardUpdatedAt: now,
        },
        where: '${DatabaseHelper.columnCardId} = ?',
        whereArgs: [cardId],
      );
    }

    await batch.commit();
  }

  /// 获取项目中的卡片数量
  Future<int> getProjectCardCount(int projectId) async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableCards} WHERE ${DatabaseHelper.columnCardProjectId} = ?',
      [projectId],
    );
    return result.first['count'] as int;
  }

  /// 获取项目中卡片的总价值
  Future<double> getProjectTotalValue(int projectId) async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(${DatabaseHelper.columnCardAcquiredPrice}) as total FROM ${DatabaseHelper.tableCards} WHERE ${DatabaseHelper.columnCardProjectId} = ?',
      [projectId],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  /// 批量删除项目
  Future<void> deleteProjects(List<int> ids) async {
    final db = await DatabaseHelper.database;
    final batch = db.batch();

    for (final id in ids) {
      // 先将关联的卡片的项目ID设为null
      batch.update(
        DatabaseHelper.tableCards,
        {DatabaseHelper.columnCardProjectId: null},
        where: '${DatabaseHelper.columnCardProjectId} = ?',
        whereArgs: [id],
      );

      // 删除项目
      batch.delete(
        DatabaseHelper.tableProjects,
        where: '${DatabaseHelper.columnProjectId} = ?',
        whereArgs: [id],
      );
    }

    await batch.commit();
  }

  /// 获取项目总数
  Future<int> getProjectCount() async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableProjects}',
    );
    return result.first['count'] as int;
  }

  /// 获取所有项目的总价值
  Future<double> getAllProjectsTotalValue() async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(${DatabaseHelper.columnCardAcquiredPrice}) as total FROM ${DatabaseHelper.tableCards}',
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  /// 获取项目关联的卡片
  Future<List<CardModel>> _getProjectCards(int projectId) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCards,
      where: '${DatabaseHelper.columnCardProjectId} = ?',
      whereArgs: [projectId],
      orderBy: '${DatabaseHelper.columnCardCreatedAt} DESC',
    );

    return maps.map((map) => _mapToCardModel(map)).toList();
  }

  /// 更新卡片的项目ID
  Future<void> _updateCardsProjectId(List<CardModel> cards, int projectId) async {
    final db = await DatabaseHelper.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (final card in cards) {
      if (card.id != null) {
        batch.update(
          DatabaseHelper.tableCards,
          {
            DatabaseHelper.columnCardProjectId: projectId,
            DatabaseHelper.columnCardUpdatedAt: now,
          },
          where: '${DatabaseHelper.columnCardId} = ?',
          whereArgs: [card.id],
        );
      }
    }

    await batch.commit();
  }

  /// 将数据库映射转换为 Project 对象
  Future<ProjectModel> _mapToProjectModel(Map<String, dynamic> map) async {
    final projectId = map[DatabaseHelper.columnProjectId] as int;
    final cards = await _getProjectCards(projectId);

    return ProjectModel(
      id: projectId,
      name: map[DatabaseHelper.columnProjectName] as String,
      description: map[DatabaseHelper.columnProjectDescription] as String,
      cards: cards,
    );
  }

  /// 将数据库映射转换为 CardModel 对象
  CardModel _mapToCardModel(Map<String, dynamic> map) {
    return CardModel(
      id: map[DatabaseHelper.columnCardId] as int,
      name: map[DatabaseHelper.columnCardName] as String,
      issueNumber: map[DatabaseHelper.columnCardIssueNumber] as String,
      issueDate: map[DatabaseHelper.columnCardIssueDate] as String,
      grade: map[DatabaseHelper.columnCardGrade] as String,
      acquiredDate: map[DatabaseHelper.columnCardAcquiredDate] as String,
      acquiredPrice: map[DatabaseHelper.columnCardAcquiredPrice] as double,
      frontImage: map[DatabaseHelper.columnCardFrontImage] as String? ?? '',
      backImage: map[DatabaseHelper.columnCardBackImage] as String? ?? '',
      gradeImage: map[DatabaseHelper.columnCardGradeImage] as String? ?? '',
    );
  }
}
