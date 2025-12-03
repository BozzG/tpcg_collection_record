import 'package:flutter/material.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/cards/card_list_page.dart';
import '../presentation/pages/cards/card_detail_page.dart';
import '../presentation/pages/cards/edit_card_page.dart';
import '../presentation/pages/projects/project_list_page.dart';
import '../presentation/pages/projects/project_detail_page.dart';
import '../presentation/pages/projects/add_project_page.dart';
import '../presentation/pages/projects/edit_project_page.dart';
import '../presentation/pages/debug/file_picker_test_page.dart';

class AppRouter {
  static const String home = '/';
  static const String cardList = '/cards';
  static const String cardDetail = '/cards/detail';
  static const String editCard = '/cards/edit';
  static const String projectList = '/projects';
  static const String projectDetail = '/projects/detail';
  static const String addProject = '/projects/add';
  static const String editProject = '/projects/edit';
  static const String filePickerTest = '/debug/file_picker';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
        
      case cardList:
        return MaterialPageRoute(
          builder: (_) => const CardListPage(),
          settings: settings,
        );
        
      case cardDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final cardIdStr = args?['cardId'] as String?;
        
        if (cardIdStr == null) {
          return _errorRoute('卡片ID不能为空');
        }
        
        final cardId = int.tryParse(cardIdStr);
        if (cardId == null) {
          return _errorRoute('无效的卡片ID');
        }
        
        return MaterialPageRoute(
          builder: (_) => CardDetailPage(cardId: cardId),
          settings: settings,
        );
        
      case editCard:
        final args = settings.arguments as Map<String, dynamic>?;
        final cardIdStr = args?['cardId'] as String?;
        
        if (cardIdStr == null) {
          return _errorRoute('卡片ID不能为空');
        }
        
        final cardId = int.tryParse(cardIdStr);
        if (cardId == null) {
          return _errorRoute('无效的卡片ID');
        }
        
        return MaterialPageRoute(
          builder: (_) => EditCardPage(cardId: cardId),
          settings: settings,
        );
        
      case projectList:
        return MaterialPageRoute(
          builder: (_) => const ProjectListPage(),
          settings: settings,
        );
        
      case projectDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final projectIdStr = args?['projectId'] as String?;
        
        if (projectIdStr == null) {
          return _errorRoute('项目ID不能为空');
        }
        
        final projectId = int.tryParse(projectIdStr);
        if (projectId == null) {
          return _errorRoute('无效的项目ID');
        }
        
        return MaterialPageRoute(
          builder: (_) => ProjectDetailPage(projectId: projectId),
          settings: settings,
        );
        
      case addProject:
        return MaterialPageRoute(
          builder: (_) => const AddProjectPage(),
          settings: settings,
        );
        
      case editProject:
        final args = settings.arguments as Map<String, dynamic>?;
        final projectIdStr = args?['projectId'] as String?;
        
        if (projectIdStr == null) {
          return _errorRoute('项目ID不能为空');
        }
        
        final projectId = int.tryParse(projectIdStr);
        if (projectId == null) {
          return _errorRoute('无效的项目ID');
        }
        
        return MaterialPageRoute(
          builder: (_) => EditProjectPage(projectId: projectId),
          settings: settings,
        );
        
      case filePickerTest:
        return MaterialPageRoute(
          builder: (_) => const FilePickerTestPage(),
          settings: settings,
        );
        
      default:
        return _errorRoute('页面不存在: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('错误'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                '页面错误',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  home,
                  (route) => false,
                ),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 路由扩展方法，方便使用
extension AppRouterExtension on NavigatorState {
  // 导航到卡片详情页
  Future<T?> pushCardDetail<T extends Object?>(String cardId) {
    return pushNamed<T>(
      AppRouter.cardDetail,
      arguments: {'cardId': cardId},
    );
  }

  // 导航到编辑卡片页
  Future<T?> pushEditCard<T extends Object?>(String cardId) {
    return pushNamed<T>(
      AppRouter.editCard,
      arguments: {'cardId': cardId},
    );
  }

  // 导航到项目详情页
  Future<T?> pushProjectDetail<T extends Object?>(String projectId) {
    return pushNamed<T>(
      AppRouter.projectDetail,
      arguments: {'projectId': projectId},
    );
  }

  // 导航到添加项目页
  Future<T?> pushAddProject<T extends Object?>() {
    return pushNamed<T>(AppRouter.addProject);
  }

  // 导航到编辑项目页
  Future<T?> pushEditProject<T extends Object?>(String projectId) {
    return pushNamed<T>(
      AppRouter.editProject,
      arguments: {'projectId': projectId},
    );
  }

  // 导航到卡片列表页
  Future<T?> pushCardList<T extends Object?>() {
    return pushNamed<T>(AppRouter.cardList);
  }

  // 导航到项目列表页
  Future<T?> pushProjectList<T extends Object?>() {
    return pushNamed<T>(AppRouter.projectList);
  }

  // 返回首页
  void popToHome() {
    pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
  }
}