import '../../repositories/project_repository.dart';

/// 删除项目用例
class DeleteProjectUseCase {
  final ProjectRepository _repository;

  DeleteProjectUseCase(this._repository);

  /// 执行删除项目操作
  /// 
  /// [id] 要删除的项目ID
  /// [forceDelete] 是否强制删除（即使项目中有卡片）
  Future<void> execute(int id, {bool forceDelete = false}) async {
    if (id <= 0) {
      throw ArgumentError('项目ID必须大于0');
    }
    
    // 检查项目是否存在
    final existingProject = await _repository.getProjectById(id);
    if (existingProject == null) {
      throw ArgumentError('要删除的项目不存在');
    }
    
    // 如果项目中有卡片且不是强制删除，则抛出异常
    if (existingProject.cards.isNotEmpty && !forceDelete) {
      throw ArgumentError('项目中还有卡片，无法删除。请先移除所有卡片或使用强制删除');
    }
    
    await _repository.deleteProjectModel(id);
  }
}