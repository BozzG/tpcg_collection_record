import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../../../domain/models/project/project.dart';
import '../../../core/di/service_locator.dart';
import '../../viewmodels/edit_project_viewmodel.dart';

class EditProjectPage extends StatefulWidget {
  final int projectId;

  const EditProjectPage({super.key, required this.projectId});

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    developer.log('EditProjectPage initialized for project ID: ${widget.projectId}', name: 'EditProjectPage');
    _loadProjectData();
  }

  @override
  void dispose() {
    developer.log('EditProjectPage disposing', name: 'EditProjectPage');
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadProjectData() async {
    final viewModel = sl<EditProjectViewModel>();
    final project = await viewModel.loadProject(widget.projectId);
    
    if (project != null && mounted) {
      setState(() {
        _nameController.text = project.name;
        _descriptionController.text = project.description;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('加载项目数据失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<EditProjectViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('编辑项目'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Consumer<EditProjectViewModel>(
              builder: (context, viewModel, child) {
                return TextButton(
                  onPressed: viewModel.isLoading ? null : () => _saveProject(viewModel),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('保存'),
                );
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 项目信息卡片
                      _buildProjectInfoSection(),
                      const SizedBox(height: 32),
                      
                      // 保存按钮
                      Consumer<EditProjectViewModel>(
                        builder: (context, viewModel, child) {
                          return _buildSaveButton(viewModel);
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProjectInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '项目信息',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 项目名称
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '项目名称 *',
                hintText: '请输入项目名称',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
                helperText: '项目名称将用于识别和组织您的卡片收藏',
              ),
              maxLength: 100,
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入项目名称';
                }
                if (value.trim().length > 100) {
                  return '项目名称不能超过100个字符';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 项目描述
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '项目描述 *',
                hintText: '请输入项目描述',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                helperText: '详细描述这个项目的主题、目标或特色',
              ),
              maxLines: 4,
              maxLength: 500,
              inputFormatters: [
                LengthLimitingTextInputFormatter(500),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入项目描述';
                }
                if (value.trim().length > 500) {
                  return '项目描述不能超过500个字符';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(EditProjectViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : () => _saveProject(viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: viewModel.isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('保存中...'),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text(
                    '保存更改',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _saveProject(EditProjectViewModel viewModel) async {
    developer.log('Save project changes button pressed', name: 'EditProjectPage');
    
    if (!_formKey.currentState!.validate()) {
      developer.log('Form validation failed', name: 'EditProjectPage');
      return;
    }

    try {
      // 创建更新的项目对象
      final updatedProject = ProjectModel(
        id: widget.projectId, // 保持原有ID
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        cards: viewModel.originalProject?.cards ?? [], // 保持原有卡片
      );

      developer.log('Updating project: ${updatedProject.name} (ID: ${updatedProject.id})', name: 'EditProjectPage');

      // 使用 ViewModel 验证数据
      final validationError = viewModel.validateProject(updatedProject);
      if (validationError != null) {
        developer.log('Project validation failed: $validationError', name: 'EditProjectPage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError)),
        );
        return;
      }

      // 检查是否有变化
      if (!viewModel.hasChanges(updatedProject)) {
        developer.log('No changes detected in project', name: 'EditProjectPage');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有检测到任何更改')),
        );
        return;
      }

      // 检查项目名称是否重复（排除当前项目）
      developer.log('Checking for duplicate project name: ${updatedProject.name}', name: 'EditProjectPage');
      final isDuplicate = await viewModel.isProjectNameDuplicate(
        updatedProject.name,
        widget.projectId,
      );
      if (isDuplicate && mounted) {
        developer.log('Project name is duplicate: ${updatedProject.name}', name: 'EditProjectPage');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('项目名称已存在，请使用其他名称')),
        );
        return;
      }

      // 调用 ViewModel 更新项目
      developer.log('Saving project changes to database', name: 'EditProjectPage');
      final savedProject = await viewModel.updateProject(updatedProject);

      if (savedProject != null && mounted) {
        developer.log('Project updated successfully: ${savedProject.name} (ID: ${savedProject.id})', name: 'EditProjectPage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('项目 "${savedProject.name}" 更新成功！'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, savedProject);
      } else if (mounted) {
        developer.log('Project update failed - no project returned', name: 'EditProjectPage');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新失败，请重试')),
        );
      }
    } catch (e) {
      developer.log('Error updating project: $e', name: 'EditProjectPage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e')),
        );
      }
    }
  }
}