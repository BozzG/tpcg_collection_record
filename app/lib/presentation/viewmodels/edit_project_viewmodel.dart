import '../../domain/models/project/project.dart';
import '../../domain/usecases/project/update_project_usecase.dart';
import '../../domain/usecases/project/get_project_by_id_usecase.dart';
import '../../core/di/service_locator.dart';
import 'base_viewmodel.dart';

/// 编辑项目 ViewModel
class EditProjectViewModel extends BaseViewModel {
  final UpdateProjectUseCase _updateProjectUseCase = sl<UpdateProjectUseCase>();
  final GetProjectByIdUseCase _getProjectByIdUseCase =
      sl<GetProjectByIdUseCase>();

  ProjectModel? _originalProject;
  ProjectModel? get originalProject => _originalProject;

  /// 加载要编辑的项目数据
  ///
  /// [projectId] 项目ID
  Future<ProjectModel?> loadProject(int projectId) async {
    final project = await executeAsync(
      () => _getProjectByIdUseCase.execute(projectId),
      errorPrefix: '加载项目失败',
    );

    if (project != null) {
      _originalProject = project;
      notifyListeners();
    }

    return project;
  }

  /// 更新项目
  ///
  /// [project] 要更新的项目对象
  /// 返回更新后的项目对象（包含ID），失败时返回 null
  Future<ProjectModel?> updateProject(ProjectModel project) async {
    // 执行更新操作
    final updatedProject = await executeAsync(
      () => _updateProjectUseCase.execute(project),
      errorPrefix: '更新项目失败',
    );

    return updatedProject;
  }

  /// 验证项目数据
  ///
  /// [project] 要验证的项目对象
  /// 返回验证结果，如果有错误则返回错误信息
  String? validateProject(ProjectModel project) {
    try {
      // 基本字段验证
      if (project.name.trim().isEmpty) {
        return '项目名称不能为空';
      }

      if (project.name.trim().length > 100) {
        return '项目名称不能超过100个字符';
      }

      if (project.description.trim().isEmpty) {
        return '项目描述不能为空';
      }

      if (project.description.trim().length > 500) {
        return '项目描述不能超过500个字符';
      }

      return null; // 验证通过
    } catch (e) {
      return '数据验证失败: $e';
    }
  }

  /// 检查数据是否有变化
  bool hasChanges(ProjectModel currentProject) {
    if (_originalProject == null) return true;

    return _originalProject!.name != currentProject.name ||
        _originalProject!.description != currentProject.description;
  }

  /// 检查项目名称是否重复（排除当前项目）
  ///
  /// [name] 项目名称
  /// [currentProjectId] 当前项目ID
  /// 返回是否重复
  Future<bool> isProjectNameDuplicate(String name, int currentProjectId) async {
    // 实现项目名称重复检查
    // 这里可以调用相应的UseCase来检查项目名称是否已存在（排除当前项目）
    return false;
  }
}
