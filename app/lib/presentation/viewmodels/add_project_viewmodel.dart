import '../../domain/models/project/project.dart';
import '../../domain/usecases/project/add_project_usecase.dart';
import '../../core/di/service_locator.dart';
import 'base_viewmodel.dart';

/// 添加项目 ViewModel
class AddProjectViewModel extends BaseViewModel {
  final AddProjectUseCase _addProjectUseCase = sl<AddProjectUseCase>();

  /// 添加项目
  ///
  /// [project] 要添加的项目对象
  /// 返回添加后的项目对象（包含生成的ID），失败时返回 null
  Future<ProjectModel?> addProject(ProjectModel project) async {
    // 执行添加操作
    final addedProject = await executeAsync(
      () => _addProjectUseCase.execute(project),
      errorPrefix: '添加项目失败',
    );

    return addedProject;
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

  /// 检查项目名称是否重复
  ///
  /// [name] 项目名称
  /// 返回是否重复
  Future<bool> isProjectNameDuplicate(String name) async {
    // 实现项目名称重复检查
    // 这里可以调用相应的UseCase来检查项目名称是否已存在
    return false;
  }
}
