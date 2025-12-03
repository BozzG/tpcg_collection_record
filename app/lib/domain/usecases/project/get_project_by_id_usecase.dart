import '../../models/project/project.dart';
import '../../repositories/project_repository.dart';

/// 根据ID获取项目用例
class GetProjectByIdUseCase {
  final ProjectRepository _repository;

  GetProjectByIdUseCase(this._repository);

  /// 执行根据ID获取项目操作
  /// 
  /// [id] 项目ID
  /// 返回项目对象，如果不存在则返回null
  Future<ProjectModel?> execute(int id) async {
    if (id <= 0) {
      throw ArgumentError('项目ID必须大于0');
    }
    
    return await _repository.getProjectById(id);
  }
}