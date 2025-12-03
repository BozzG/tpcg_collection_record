import '../../models/project/project.dart';
import '../../repositories/project_repository.dart';

/// 添加项目用例
class AddProjectUseCase {
  final ProjectRepository _repository;

  AddProjectUseCase(this._repository);

  /// 执行添加项目操作
  /// 
  /// [project] 要添加的项目对象
  /// 返回添加后的项目对象（包含生成的ID）
  Future<ProjectModel> execute(ProjectModel project) async {
    // 业务规则验证
    _validateProjectModel(project);
    
    return await _repository.addProjectModel(project);
  }

  /// 验证项目数据
  void _validateProjectModel(ProjectModel project) {
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