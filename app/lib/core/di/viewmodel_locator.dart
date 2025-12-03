import '../../presentation/viewmodels/home_viewmodel.dart';
import '../../presentation/viewmodels/project_list_viewmodel.dart';

/// ViewModel 定位器
/// 用于在整个应用中共享 ViewModel 实例
class ViewModelLocator {
  static final ViewModelLocator _instance = ViewModelLocator._internal();
  factory ViewModelLocator() => _instance;
  ViewModelLocator._internal();

  HomeViewModel? _homeViewModel;
  ProjectListViewModel? _projectListViewModel;

  /// 获取首页 ViewModel
  HomeViewModel get homeViewModel {
    _homeViewModel ??= HomeViewModel();
    return _homeViewModel!;
  }

  /// 获取项目列表 ViewModel
  ProjectListViewModel get projectListViewModel {
    _projectListViewModel ??= ProjectListViewModel();
    return _projectListViewModel!;
  }

  /// 重置所有 ViewModel
  void resetAll() {
    _homeViewModel = null;
    _projectListViewModel = null;
  }
}