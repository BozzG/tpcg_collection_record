/// 应用程序常量
class AppConstants {
  // 应用信息
  static const String appName = 'TPCG Collection Record';
  static const String appVersion = '1.0.0';
  
  // 数据库相关
  static const String databaseName = 'tpcg_collection.db';
  static const int databaseVersion = 1;
  
  // 分页相关
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // 图片相关
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxImageSizeInMB = 10;
  
  // 验证规则
  static const int maxProjectNameLength = 100;
  static const int maxProjectDescriptionLength = 500;
  static const int maxCardNameLength = 200;
  static const int maxIssueNumberLength = 50;
  static const int maxGradeLength = 20;
  
  // 日期格式
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  // 价格相关
  static const double minPrice = 0.0;
  static const double maxPrice = 999999.99;
  static const int priceDecimalPlaces = 2;
  
  // 缓存相关
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100;
  
  // 搜索相关
  static const int minSearchLength = 2;
  static const int maxSearchResults = 500;
  
  // UI 相关
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  
  // 错误消息
  static const String networkErrorMessage = '网络连接失败，请检查网络设置';
  static const String databaseErrorMessage = '数据库操作失败，请重试';
  static const String unknownErrorMessage = '发生未知错误，请重试';
  
  // 成功消息
  static const String saveSuccessMessage = '保存成功';
  static const String deleteSuccessMessage = '删除成功';
  static const String updateSuccessMessage = '更新成功';
  
  // 默认值
  static const String defaultGrade = 'Ungraded';
  static const String defaultImagePath = 'assets/images/default_card.png';
}