import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../../viewmodels/project_list_viewmodel.dart';
import '../../../domain/models/project/project.dart';
import '../../../routing/app_router.dart';
import '../../../core/services/data_sync_service.dart';
import 'project_detail_page.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  final TextEditingController _searchController = TextEditingController();
  final DataSyncService _dataSyncService = DataSyncService();

  @override
  void initState() {
    super.initState();
    developer.log('ProjectListPage initialized', name: 'ProjectListPage');
    
    // 注册数据同步监听器
    _dataSyncService.addListener(DataSyncEvents.projectCreated, _refreshProjectList);
    _dataSyncService.addListener(DataSyncEvents.projectUpdated, _refreshProjectList);
    _dataSyncService.addListener(DataSyncEvents.projectDeleted, _refreshProjectList);
  }

  @override
  void dispose() {
    developer.log('ProjectListPage disposing', name: 'ProjectListPage');
    
    // 移除数据同步监听器
    _dataSyncService.removeListener(DataSyncEvents.projectCreated, _refreshProjectList);
    _dataSyncService.removeListener(DataSyncEvents.projectUpdated, _refreshProjectList);
    _dataSyncService.removeListener(DataSyncEvents.projectDeleted, _refreshProjectList);
    
    _searchController.dispose();
    super.dispose();
  }

  void _refreshProjectList() {
    if (mounted) {
      context.read<ProjectListViewModel>().loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building ProjectListPage', name: 'ProjectListPage');
    return ChangeNotifierProvider(
      create: (context) {
        developer.log('Creating ProjectListViewModel and loading projects', name: 'ProjectListPage');
        return ProjectListViewModel()..loadProjects();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('收藏项目'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () {
                developer.log('Sort button pressed', name: 'ProjectListPage');
                _showSortDialog(context);
              },
            ),
          ],
        ),
        body: Consumer<ProjectListViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // 搜索栏
                _buildSearchBar(context, viewModel),
                
                // 项目列表
                Expanded(
                  child: _buildProjectList(context, viewModel),
                ),
              ],
            );
          },
        ),
        floatingActionButton: Consumer<ProjectListViewModel>(
          builder: (context, viewModel, child) {
            return FloatingActionButton(
              onPressed: () async {
                developer.log('Add project button pressed', name: 'ProjectListPage');
                // 导航到添加项目页面
                final result = await Navigator.pushNamed(
                  context,
                  AppRouter.addProject,
                );
                developer.log('Returned from add project page with result: $result', name: 'ProjectListPage');
                // 如果添加了新项目，刷新列表
                if (result != null && mounted) {
                  developer.log('Refreshing project list after adding new project', name: 'ProjectListPage');
                  viewModel.loadProjects();
                }
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ProjectListViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索项目名称或描述...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    developer.log('Search clear button pressed', name: 'ProjectListPage');
                    _searchController.clear();
                    viewModel.searchProjects('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (value) {
          developer.log('Search text changed: "$value"', name: 'ProjectListPage');
          viewModel.searchProjects(value);
        },
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, ProjectListViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                developer.log('Retry button pressed after error', name: 'ProjectListPage');
                viewModel.loadProjects();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (viewModel.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无项目',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角的 + 按钮创建第一个项目',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        developer.log('Pull to refresh triggered', name: 'ProjectListPage');
        await viewModel.loadProjects();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: viewModel.projects.length,
        itemBuilder: (context, index) {
          final project = viewModel.projects[index];
          return _buildProjectItem(context, project, viewModel);
        },
      ),
    );
  }

  Widget _buildProjectItem(
    BuildContext context,
    ProjectModel project,
    ProjectListViewModel viewModel,
  ) {
    final cardCount = project.cards.length;
    final totalValue = project.cards.fold<double>(
      0.0,
      (sum, card) => sum + card.acquiredPrice,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          developer.log('Project tapped: ${project.name} (ID: ${project.id})', name: 'ProjectListPage');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailPage(projectId: project.id!),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 项目图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getProjectColor(project.name).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.folder,
                      color: _getProjectColor(project.name),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // 项目信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // 操作按钮
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      developer.log('Project menu action selected: $value for project: ${project.name}', name: 'ProjectListPage');
                      switch (value) {
                        case 'edit':
                          // 导航到编辑页面
                          final result = await Navigator.pushNamed(
                            context,
                            AppRouter.editProject,
                            arguments: {'projectId': project.id.toString()},
                          );
                          developer.log('Returned from edit project page with result: $result', name: 'ProjectListPage');
                          // 如果编辑成功，刷新列表
                          if (result != null && mounted) {
                            developer.log('Refreshing project list after editing project', name: 'ProjectListPage');
                            viewModel.loadProjects();
                          }
                          break;
                        case 'delete':
                          developer.log('Showing delete dialog for project: ${project.name}', name: 'ProjectListPage');
                          _showDeleteDialog(context, project, viewModel);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('编辑'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('删除', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 项目统计信息
              Row(
                children: [
                  _buildStatChip(
                    context,
                    Icons.credit_card,
                    '$cardCount 张卡片',
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    context,
                    Icons.attach_money,
                    '¥${totalValue.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ],
              ),
              
              // 如果有卡片，显示预览
              if (project.cards.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildCardPreview(context, project),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview(BuildContext context, ProjectModel project) {
    final previewCards = project.cards.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '包含卡片',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...previewCards.map((card) => Container(
              margin: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  card.name,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.grey[100],
                side: BorderSide(color: Colors.grey[300]!),
              ),
            )),
            if (project.cards.length > 3)
              Chip(
                label: Text(
                  '+${project.cards.length - 3}',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.grey[200],
                side: BorderSide(color: Colors.grey[400]!),
              ),
          ],
        ),
      ],
    );
  }

  Color _getProjectColor(String projectName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    final index = projectName.hashCode % colors.length;
    return colors[index.abs()];
  }

  void _showSortDialog(BuildContext context) {
    developer.log('Showing sort dialog', name: 'ProjectListPage');
    final viewModel = context.read<ProjectListViewModel>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('排序方式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('按名称'),
              onTap: () {
                developer.log('Sort by name selected', name: 'ProjectListPage');
                Navigator.pop(dialogContext);
                viewModel.sortProjects('name');
              },
            ),
            ListTile(
              title: const Text('按卡片数量'),
              onTap: () {
                developer.log('Sort by card count selected', name: 'ProjectListPage');
                Navigator.pop(dialogContext);
                viewModel.sortProjects('cardCount');
              },
            ),
            ListTile(
              title: const Text('按总价值'),
              onTap: () {
                developer.log('Sort by total value selected', name: 'ProjectListPage');
                Navigator.pop(dialogContext);
                viewModel.sortProjects('totalValue');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProjectModel project,
    ProjectListViewModel viewModel,
  ) {
    developer.log('Showing delete confirmation dialog for project: ${project.name}', name: 'ProjectListPage');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确定要删除项目 "${project.name}" 吗？'),
            const SizedBox(height: 8),
            if (project.cards.isNotEmpty)
              Text(
                '注意：该项目包含 ${project.cards.length} 张卡片，删除项目不会删除卡片本身。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange[700],
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              '此操作无法撤销。',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              developer.log('Delete dialog cancelled for project: ${project.name}', name: 'ProjectListPage');
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              developer.log('Delete confirmed for project: ${project.name} (ID: ${project.id})', name: 'ProjectListPage');
              Navigator.pop(context);
              viewModel.deleteProjectModel(project.id!);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}