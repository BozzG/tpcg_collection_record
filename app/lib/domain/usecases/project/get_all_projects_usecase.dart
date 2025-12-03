import '../../models/project/project.dart';
import '../../repositories/project_repository.dart';

/// 获取所有项目用例
class GetAllProjectsUseCase {
  final ProjectRepository _repository;

  GetAllProjectsUseCase(this._repository);

  /// 执行获取所有项目操作
  Future<List<ProjectModel>> execute() async {
    return await _repository.getAllProjects();
  }
}