import 'package:get_it/get_it.dart';

// Services
import '../services/image_service.dart';

// Data Sources
import '../../data/datasources/local_card_datasource.dart';
import '../../data/datasources/local_project_datasource.dart';

// Repositories
import '../../domain/repositories/card_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../data/repositories/project_repository_impl.dart';

// Use Cases - Card
import '../../domain/usecases/card/get_all_cards_usecase.dart';
import '../../domain/usecases/card/get_card_by_id_usecase.dart';
import '../../domain/usecases/card/add_card_usecase.dart';
import '../../domain/usecases/card/update_card_usecase.dart';
import '../../domain/usecases/card/delete_card_usecase.dart';
import '../../domain/usecases/card/search_cards_usecase.dart';
import '../../domain/usecases/card/get_card_statistics_usecase.dart';

// Use Cases - Project
import '../../domain/usecases/project/get_all_projects_usecase.dart';
import '../../domain/usecases/project/get_project_by_id_usecase.dart';
import '../../domain/usecases/project/add_project_usecase.dart';
import '../../domain/usecases/project/update_project_usecase.dart';
import '../../domain/usecases/project/delete_project_usecase.dart';
import '../../domain/usecases/project/manage_project_cards_usecase.dart';
import '../../domain/usecases/project/search_projects_usecase.dart';
import '../../domain/usecases/project/project_operations_usecase.dart';

// ViewModels
import '../../presentation/viewmodels/home_viewmodel.dart';
import '../../presentation/viewmodels/card_list_viewmodel.dart';
import '../../presentation/viewmodels/card_detail_viewmodel.dart';
import '../../presentation/viewmodels/add_card_viewmodel.dart';
import '../../presentation/viewmodels/edit_card_viewmodel.dart';
import '../../presentation/viewmodels/project_list_viewmodel.dart';
import '../../presentation/viewmodels/project_detail_viewmodel.dart';
import '../../presentation/viewmodels/add_project_viewmodel.dart';
import '../../presentation/viewmodels/edit_project_viewmodel.dart';

/// 服务定位器
/// 负责管理应用程序中所有依赖项的注册和获取
final GetIt sl = GetIt.instance;

/// 初始化依赖注入
/// 必须在应用启动时调用
Future<void> initializeDependencies() async {
  // 注册数据源 (Data Sources)
  _registerDataSources();
  
  // 注册服务 (Services)
  _registerServices();
  
  // 注册仓储 (Repositories)
  _registerRepositories();
  
  // 注册用例 (Use Cases)
  _registerUseCases();
  
  // 注册 ViewModels
  _registerViewModels();
}

/// 注册服务
void _registerServices() {
  // 图片处理服务 - 单例模式
  sl.registerLazySingleton<ImageService>(() => ImageService());
}

/// 注册数据源
void _registerDataSources() {
  // 本地数据源 - 单例模式
  sl.registerLazySingleton<LocalCardDataSource>(
    () => LocalCardDataSource(),
  );
  
  sl.registerLazySingleton<LocalProjectDataSource>(
    () => LocalProjectDataSource(),
  );
}

/// 注册仓储
void _registerRepositories() {
  // 卡片仓储
  sl.registerLazySingleton<CardRepository>(
    () => CardRepositoryImpl(sl<LocalCardDataSource>()),
  );
  
  // 项目仓储
  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(
      sl<LocalProjectDataSource>(),
      sl<LocalCardDataSource>(),
    ),
  );
}

/// 注册用例
void _registerUseCases() {
  // 卡片相关用例
  _registerCardUseCases();
  
  // 项目相关用例
  _registerProjectUseCases();
}

/// 注册卡片相关用例
void _registerCardUseCases() {
  // 基础 CRUD 操作
  sl.registerLazySingleton(() => GetAllCardsUseCase(sl<CardRepository>()));
  sl.registerLazySingleton(() => GetCardByIdUseCase(sl<CardRepository>()));
  sl.registerLazySingleton(() => AddCardUseCase(sl<CardRepository>()));
  sl.registerLazySingleton(() => UpdateCardUseCase(sl<CardRepository>()));
  sl.registerLazySingleton(() => DeleteCardUseCase(sl<CardRepository>()));
  
  // 搜索和统计
  sl.registerLazySingleton(() => SearchCardsUseCase(sl<CardRepository>()));
  sl.registerLazySingleton(() => GetCardStatisticsUseCase(sl<CardRepository>()));
}

/// 注册项目相关用例
void _registerProjectUseCases() {
  // 基础 CRUD 操作
  sl.registerLazySingleton(() => GetAllProjectsUseCase(sl<ProjectRepository>()));
  sl.registerLazySingleton(() => GetProjectByIdUseCase(sl<ProjectRepository>()));
  sl.registerLazySingleton(() => AddProjectUseCase(sl<ProjectRepository>()));
  sl.registerLazySingleton(() => UpdateProjectUseCase(sl<ProjectRepository>()));
  sl.registerLazySingleton(() => DeleteProjectUseCase(sl<ProjectRepository>()));
  
  // 项目管理
  sl.registerLazySingleton(() => ManageProjectCardsUseCase(sl<ProjectRepository>()));
  sl.registerLazySingleton(() => SearchProjectsUseCase(sl<ProjectRepository>()));
  sl.registerLazySingleton(() => ProjectOperationsUseCase(sl<ProjectRepository>()));
}

/// 注册 ViewModels
void _registerViewModels() {
  // 主页 ViewModel
  sl.registerFactory(() => HomeViewModel());
  
  // 卡片相关 ViewModels
  sl.registerFactory(() => CardListViewModel());
  sl.registerFactory(() => CardDetailViewModel());
  sl.registerFactory(() => AddCardViewModel());
  sl.registerFactory(() => EditCardViewModel());
  
  // 项目相关 ViewModels
  sl.registerFactory(() => ProjectListViewModel());
  sl.registerFactory(() => ProjectDetailViewModel());
  sl.registerFactory(() => AddProjectViewModel());
  sl.registerFactory(() => EditProjectViewModel());
}

/// 重置所有依赖（主要用于测试）
Future<void> resetDependencies() async {
  await sl.reset();
}

/// 检查依赖是否已注册
bool isDependencyRegistered<T extends Object>() {
  return sl.isRegistered<T>();
}

/// 获取依赖实例的便捷方法
T getDependency<T extends Object>() {
  return sl<T>();
}