import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 数据库帮助类
/// 负责数据库的创建、升级和基本操作
class DatabaseHelper {
  static const String _databaseName = 'tpcg_collection.db';
  static const int _databaseVersion = 1;

  // 表名
  static const String tableProjects = 'projects';
  static const String tableCards = 'cards';

  // Projects 表字段
  static const String columnProjectId = 'id';
  static const String columnProjectName = 'name';
  static const String columnProjectDescription = 'description';
  static const String columnProjectCreatedAt = 'created_at';
  static const String columnProjectUpdatedAt = 'updated_at';

  // Cards 表字段
  static const String columnCardId = 'id';
  static const String columnCardProjectId = 'project_id';
  static const String columnCardName = 'name';
  static const String columnCardIssueNumber = 'issue_number';
  static const String columnCardIssueDate = 'issue_date';
  static const String columnCardGrade = 'grade';
  static const String columnCardAcquiredDate = 'acquired_date';
  static const String columnCardAcquiredPrice = 'acquired_price';
  static const String columnCardFrontImage = 'front_image';
  static const String columnCardBackImage = 'back_image';
  static const String columnCardGradeImage = 'grade_image';
  static const String columnCardCreatedAt = 'created_at';
  static const String columnCardUpdatedAt = 'updated_at';

  static Database? _database;

  /// 获取数据库实例
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  static Future<void> _onCreate(Database db, int version) async {
    // 创建 projects 表
    await db.execute('''
      CREATE TABLE $tableProjects (
        $columnProjectId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnProjectName TEXT NOT NULL,
        $columnProjectDescription TEXT NOT NULL,
        $columnProjectCreatedAt TEXT NOT NULL,
        $columnProjectUpdatedAt TEXT NOT NULL
      )
    ''');

    // 创建 cards 表
    await db.execute('''
      CREATE TABLE $tableCards (
        $columnCardId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCardProjectId INTEGER,
        $columnCardName TEXT NOT NULL,
        $columnCardIssueNumber TEXT NOT NULL,
        $columnCardIssueDate TEXT NOT NULL,
        $columnCardGrade TEXT NOT NULL,
        $columnCardAcquiredDate TEXT NOT NULL,
        $columnCardAcquiredPrice REAL NOT NULL,
        $columnCardFrontImage TEXT NOT NULL,
        $columnCardBackImage TEXT,
        $columnCardGradeImage TEXT,
        $columnCardCreatedAt TEXT NOT NULL,
        $columnCardUpdatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnCardProjectId) REFERENCES $tableProjects ($columnProjectId) ON DELETE SET NULL
      )
    ''');

    // 创建索引
    await db.execute('''
      CREATE INDEX idx_cards_project_id ON $tableCards ($columnCardProjectId)
    ''');

    await db.execute('''
      CREATE INDEX idx_cards_name ON $tableCards ($columnCardName)
    ''');

    await db.execute('''
      CREATE INDEX idx_cards_issue_number ON $tableCards ($columnCardIssueNumber)
    ''');

    await db.execute('''
      CREATE INDEX idx_cards_grade ON $tableCards ($columnCardGrade)
    ''');
  }

  /// 数据库升级
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 处理数据库升级逻辑
    // 目前版本为1，暂无升级逻辑
  }

  /// 关闭数据库
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// 删除数据库（用于测试或重置）
  static Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}