import '../../models/project/project.dart';
import '../../repositories/project_repository.dart';

/// 更新项目用例
class UpdateProjectUseCase {
  final ProjectRepository _repository;

  UpdateProjectUseCase(this._repository);

  /// 执行更新项目操作
  /// 
  /// [project] 要更新的项目对象（必须包含ID）
  /// 返回更新后的项目对象
  Future<ProjectModel> execute(ProjectModel project) async {
    // 业务规则验证
    _validateProjectModel(project);
    
    // 检查项目是否存在
    final existingProject = await _repository.getProjectById(project.id!);
    if (existingProject == null) {
      throw ArgumentError('要更新的项目不存在');
    }
    
    return await _repository.updateProjectModel(project);
  }

  /// 验证项目数据
  void _validateProjectModel(ProjectModel project) {
    if (project.id == null || project.id! <= 0) {
      throw ArgumentError('更新项目时ID不能为空且必须大于0');
    }
    
    if (project.name.trim().isEmpty) {
      throw ArgumentError('项目名称不能为空');
    }
    
    if (project.name.trim().length > 100) {
      throw ArgumentError('项目名称不能超过100个字符');
    }
    
    if (project.description.trim().isEmpty) {
      throw ArgumentError('项目描述不能为空');
    }
    
    if (project.description.trim().length > 500) {
      throw ArgumentError('项目描述不能超过500个字符');
    }
  }
}