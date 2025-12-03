/// 路由常量
class RouteConstants {
  // 主要路由
  static const String home = '/';
  static const String projects = '/projects';
  static const String cards = '/cards';
  static const String settings = '/settings';
  
  // 项目相关路由
  static const String projectDetail = '/projects/:id';
  static const String addProject = '/projects/add';
  static const String editProject = '/projects/:id/edit';
  
  // 卡片相关路由
  static const String cardDetail = '/cards/:id';
  static const String addCard = '/cards/add';
  static const String editCard = '/cards/:id/edit';
  static const String addCardToProject = '/projects/:projectId/cards/add';
  
  // 搜索和筛选
  static const String searchCards = '/search/cards';
  static const String searchProjects = '/search/projects';
  static const String filterCards = '/filter/cards';
  static const String filterProjects = '/filter/projects';
  
  // 统计和报告
  static const String statistics = '/statistics';
  static const String cardStatistics = '/statistics/cards';
  static const String projectStatistics = '/statistics/projects';
  
  // 工具和设置
  static const String backup = '/backup';
  static const String restore = '/restore';
  static const String about = '/about';
  
  // 路由参数名称
  static const String paramId = 'id';
  static const String paramProjectId = 'projectId';
  static const String paramCardId = 'cardId';
  
  // 查询参数
  static const String querySearch = 'search';
  static const String queryFilter = 'filter';
  static const String querySort = 'sort';
  static const String queryPage = 'page';
  static const String queryLimit = 'limit';
}