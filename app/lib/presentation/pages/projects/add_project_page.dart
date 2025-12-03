import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../../../domain/models/project/project.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/data_sync_service.dart';
import '../../viewmodels/add_project_viewmodel.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    developer.log('AddProjectPage initialized', name: 'AddProjectPage');
  }

  @override
  void dispose() {
    developer.log('AddProjectPage disposing', name: 'AddProjectPage');
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<AddProjectViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('创建项目'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Consumer<AddProjectViewModel>(
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
        body: Form(
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
                Consumer<AddProjectViewModel>(
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
                  Icons.folder,
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

  Widget _buildSaveButton(AddProjectViewModel viewModel) {
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
                  Text('创建中...'),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text(
                    '创建项目',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _saveProject(AddProjectViewModel viewModel) async {
    developer.log('Save project button pressed', name: 'AddProjectPage');
    
    if (!_formKey.currentState!.validate()) {
      developer.log('Form validation failed', name: 'AddProjectPage');
      return;
    }

    try {
      // 创建项目对象
      final project = ProjectModel(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        cards: [], // 新项目开始时没有卡片
      );

      developer.log('Creating project: ${project.name}', name: 'AddProjectPage');

      // 使用 ViewModel 验证数据
      final validationError = viewModel.validateProject(project);
      if (validationError != null) {
        developer.log('Project validation failed: $validationError', name: 'AddProjectPage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError)),
        );
        return;
      }

      // 检查项目名称是否重复
      developer.log('Checking for duplicate project name: ${project.name}', name: 'AddProjectPage');
      final isDuplicate = await viewModel.isProjectNameDuplicate(project.name);
      if (isDuplicate && mounted) {
        developer.log('Project name is duplicate: ${project.name}', name: 'AddProjectPage');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('项目名称已存在，请使用其他名称')),
        );
        return;
      }

      // 调用 ViewModel 保存项目
      developer.log('Saving project to database: ${project.name}', name: 'AddProjectPage');
      final addedProject = await viewModel.addProject(project);

      if (addedProject != null && mounted) {
        developer.log('Project created successfully: ${addedProject.name} (ID: ${addedProject.id})', name: 'AddProjectPage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('项目 "${addedProject.name}" 创建成功！'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 通知所有监听器刷新数据
        DataSyncService().notifyListeners(DataSyncEvents.projectCreated);
        DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
        
        Navigator.pop(context, addedProject);
      } else if (mounted) {
        developer.log('Project creation failed - no project returned', name: 'AddProjectPage');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('创建失败，请重试')),
        );
      }
    } catch (e) {
      developer.log('Error creating project: $e', name: 'AddProjectPage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    }
  }
}