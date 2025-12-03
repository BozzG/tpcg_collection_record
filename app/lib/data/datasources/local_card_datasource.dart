import '../../domain/models/card/card.dart';
import 'database_helper.dart';

/// 卡片本地数据源
/// 负责卡片数据的本地存储操作
class LocalCardDataSource {
  /// 获取所有卡片
  Future<List<CardModel>> getAllCards() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCards,
      orderBy: '${DatabaseHelper.columnCardCreatedAt} DESC',
    );

    return maps.map((map) => _mapToCardModel(map)).toList();
  }

  /// 根据ID获取卡片
  Future<CardModel?> getCardById(int id) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCards,
      where: '${DatabaseHelper.columnCardId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToCardModel(maps.first);
    }
    return null;
  }

  /// 根据项目ID获取卡片列表
  Future<List<CardModel>> getCardsByProjectId(int projectId) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCards,
      where: '${DatabaseHelper.columnCardProjectId} = ?',
      whereArgs: [projectId],
      orderBy: '${DatabaseHelper.columnCardCreatedAt} DESC',
    );

    return maps.map((map) => _mapToCardModel(map)).toList();
  }

  /// 添加卡片
  Future<CardModel> insertCardModel(CardModel card) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now().toIso8601String();

    final id = await db.insert(DatabaseHelper.tableCards, {
      DatabaseHelper.columnCardProjectId: null, // 暂时不关联项目
      DatabaseHelper.columnCardName: card.name,
      DatabaseHelper.columnCardIssueNumber: card.issueNumber,
      DatabaseHelper.columnCardIssueDate: card.issueDate,
      DatabaseHelper.columnCardGrade: card.grade,
      DatabaseHelper.columnCardAcquiredDate: card.acquiredDate,
      DatabaseHelper.columnCardAcquiredPrice: card.acquiredPrice,
      DatabaseHelper.columnCardFrontImage: card.frontImage,
      DatabaseHelper.columnCardBackImage: card.backImage,
      DatabaseHelper.columnCardGradeImage: card.gradeImage,
      DatabaseHelper.columnCardCreatedAt: now,
      DatabaseHelper.columnCardUpdatedAt: now,
    });

    return card.copyWith(id: id);
  }

  /// 更新卡片
  Future<CardModel> updateCardModel(CardModel card) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      DatabaseHelper.tableCards,
      {
        DatabaseHelper.columnCardName: card.name,
        DatabaseHelper.columnCardIssueNumber: card.issueNumber,
        DatabaseHelper.columnCardIssueDate: card.issueDate,
        DatabaseHelper.columnCardGrade: card.grade,
        DatabaseHelper.columnCardAcquiredDate: card.acquiredDate,
        DatabaseHelper.columnCardAcquiredPrice: card.acquiredPrice,
        DatabaseHelper.columnCardFrontImage: card.frontImage,
        DatabaseHelper.columnCardBackImage: card.backImage,
        DatabaseHelper.columnCardGradeImage: card.gradeImage,
        DatabaseHelper.columnCardUpdatedAt: now,
      },
      where: '${DatabaseHelper.columnCardId} = ?',
      whereArgs: [card.id],
    );

    return card;
  }

  /// 删除卡片
  Future<void> deleteCardModel(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      DatabaseHelper.tableCards,
      where: '${DatabaseHelper.columnCardId} = ?',
      whereArgs: [id],
    );
  }

  /// 根据名称搜索卡片
  Future<List<CardModel>> searchCardsByName(String name) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCards,
      where: '${DatabaseHelper.columnCardName} LIKE ?',
      whereArgs: ['%$name%'],
      orderBy: '${DatabaseHelper.columnCardCreatedAt} DESC',
    );

    return maps.map((map) => _mapToCardModel(map)).toList();
  }

  /// 根据发行编号搜索卡片
  Future<List<CardModel>> searchCardsByIssueNumber(String issueNumber) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCards,
      where: '${DatabaseHelper.columnCardIssueNumber} LIKE ?',
      whereArgs: ['%$issueNumber%'],
      orderBy: '${DatabaseHelper.columnCardCreatedAt} DESC',
    );

    return maps.map((map) => _mapToCardModel(map)).toList();
  }

  /// 根据评级筛选卡片
  Future<List<CardModel>> getCardsByGrade(String grade) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCards,
      where: '${DatabaseHelper.columnCardGrade} = ?',
      whereArgs: [grade],
      orderBy: '${DatabaseHelper.columnCardCreatedAt} DESC',
    );

    return maps.map((map) => _mapToCardModel(map)).toList();
  }

  /// 根据价格范围筛选卡片
  Future<List<CardModel>> getCardsByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCards,
      where: '${DatabaseHelper.columnCardAcquiredPrice} BETWEEN ? AND ?',
      whereArgs: [minPrice, maxPrice],
      orderBy: '${DatabaseHelper.columnCardAcquiredPrice} DESC',
    );

    return maps.map((map) => _mapToCardModel(map)).toList();
  }

  /// 批量添加卡片
  Future<List<CardModel>> insertCards(List<CardModel> cards) async {
    final db = await DatabaseHelper.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();
    final List<CardModel> insertedCards = [];

    for (final card in cards) {
      batch.insert(DatabaseHelper.tableCards, {
        DatabaseHelper.columnCardProjectId: null,
        DatabaseHelper.columnCardName: card.name,
        DatabaseHelper.columnCardIssueNumber: card.issueNumber,
        DatabaseHelper.columnCardIssueDate: card.issueDate,
        DatabaseHelper.columnCardGrade: card.grade,
        DatabaseHelper.columnCardAcquiredDate: card.acquiredDate,
        DatabaseHelper.columnCardAcquiredPrice: card.acquiredPrice,
        DatabaseHelper.columnCardFrontImage: card.frontImage,
        DatabaseHelper.columnCardBackImage: card.backImage,
        DatabaseHelper.columnCardGradeImage: card.gradeImage,
        DatabaseHelper.columnCardCreatedAt: now,
        DatabaseHelper.columnCardUpdatedAt: now,
      });
    }

    final results = await batch.commit();

    for (int i = 0; i < cards.length; i++) {
      insertedCards.add(cards[i].copyWith(id: results[i] as int));
    }

    return insertedCards;
  }

  /// 批量删除卡片
  Future<void> deleteCards(List<int> ids) async {
    final db = await DatabaseHelper.database;
    final batch = db.batch();

    for (final id in ids) {
      batch.delete(
        DatabaseHelper.tableCards,
        where: '${DatabaseHelper.columnCardId} = ?',
        whereArgs: [id],
      );
    }

    await batch.commit();
  }

  /// 获取卡片总数
  Future<int> getCardCount() async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableCards}',
    );
    return result.first['count'] as int;
  }

  /// 获取卡片总价值
  Future<double> getTotalValue() async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(${DatabaseHelper.columnCardAcquiredPrice}) as total FROM ${DatabaseHelper.tableCards}',
    );
    return (result.first['total'] as double?) ?? 0.0;
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
