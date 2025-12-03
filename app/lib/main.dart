import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'routing/app_router.dart';
import 'core/di/service_locator.dart';
import 'core/services/image_service.dart';

void main() async {
  // 确保 Flutter 绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置日志级别
  Logger.root.level = Level.ALL;

  // 初始化依赖注入
  await initializeDependencies();
  
  // 初始化图片服务
  await ImageService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TPCG Collection Record',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.home,
      debugShowCheckedModeBanner: false,
    );
  }
}
