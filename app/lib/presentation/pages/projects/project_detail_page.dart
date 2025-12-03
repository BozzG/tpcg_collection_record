import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../../viewmodels/project_detail_viewmodel.dart';
import '../../viewmodels/card_list_viewmodel.dart';
import '../../../domain/models/project/project.dart';
import '../../../domain/models/card/card.dart';
import '../../../routing/app_router.dart';
import '../../../core/di/service_locator.dart';
import '../cards/card_detail_page.dart';

class ProjectDetailPage extends StatelessWidget {
  final int projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ProjectDetailViewModel()..loadProjectModel(projectId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('项目详情'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Consumer<ProjectDetailViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.project == null) return const SizedBox.shrink();

                return PopupMenuButton<String>(
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        // 导航到编辑页面
                        final result = await Navigator.pushNamed(
                          context,
                          AppRouter.editProject,
                          arguments: {'projectId': projectId.toString()},
                        );
                        // 如果编辑成功，刷新页面数据
                        if (result != null) {
                          viewModel.loadProjectModel(projectId);
                        }
                        break;
                      case 'manage_cards':
                        developer.log(
                          'Manage cards menu selected',
                          name: 'ProjectDetailPage',
                        );
                        _showManageCardsDialog(context, viewModel);
                        break;
                      case 'delete':
                        _showDeleteDialog(context, viewModel);
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
                          Text('编辑项目'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'manage_cards',
                      child: Row(
                        children: [
                          Icon(Icons.credit_card),
                          SizedBox(width: 8),
                          Text('管理卡片'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除项目', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Consumer<ProjectDetailViewModel>(
          builder: (context, viewModel, child) {
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
                      onPressed: () => viewModel.loadProjectModel(projectId),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.project == null) {
              return const Center(child: Text('项目不存在'));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 项目基本信息
                  _buildProjectInfoSection(context, viewModel.project!),

                  // 项目统计
                  _buildProjectStatsSection(context, viewModel.project!),

                  // 卡片列表
                  _buildCardsSection(context, viewModel),
                ],
              ),
            );
          },
        ),
        floatingActionButton: Consumer<ProjectDetailViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.project == null) return const SizedBox.shrink();

            return FloatingActionButton(
              onPressed: () {
                developer.log(
                  'Manage cards button pressed',
                  name: 'ProjectDetailPage',
                );
                _showManageCardsDialog(context, viewModel);
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProjectInfoSection(BuildContext context, ProjectModel project) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getProjectColor(
                        project.name,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.folder,
                      color: _getProjectColor(project.name),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectStatsSection(BuildContext context, ProjectModel project) {
    final totalValue = project.cards.fold<double>(
      0.0,
      (sum, card) => sum + card.acquiredPrice,
    );
    final averageValue = project.cards.isNotEmpty
        ? totalValue / project.cards.length
        : 0.0;

    // 按评级统计
    final gradeStats = <String, int>{};
    for (final card in project.cards) {
      gradeStats[card.grade] = (gradeStats[card.grade] ?? 0) + 1;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '项目统计',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 基础统计
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '卡片数量',
                      '${project.cards.length}',
                      Icons.credit_card,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '总价值',
                      '¥${totalValue.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '平均价值',
                      '¥${averageValue.toStringAsFixed(2)}',
                      Icons.trending_up,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '评级种类',
                      '${gradeStats.length}',
                      Icons.star,
                      Colors.purple,
                    ),
                  ),
                ],
              ),

              // 评级分布
              if (gradeStats.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '评级分布',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: gradeStats.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getGradeColor(entry.key).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getGradeColor(entry.key),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getGradeColor(entry.key),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardsSection(
    BuildContext context,
    ProjectDetailViewModel viewModel,
  ) {
    final project = viewModel.project!;

    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '包含卡片',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      developer.log(
                        'Manage cards button pressed',
                        name: 'ProjectDetailPage',
                      );
                      _showManageCardsDialog(context, viewModel);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('管理'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (project.cards.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.credit_card_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无卡片',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击管理按钮添加卡片到此项目',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: project.cards.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final card = project.cards[index];
                    return _buildCardItem(context, card, viewModel);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    CardModel card,
    ProjectDetailViewModel viewModel,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: card.frontImage.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  card.frontImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.credit_card,
                      color: Colors.grey[400],
                      size: 20,
                    );
                  },
                ),
              )
            : Icon(Icons.credit_card, color: Colors.grey[400], size: 20),
      ),
      title: Text(
        card.name,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('编号: ${card.issueNumber}'),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getGradeColor(card.grade).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getGradeColor(card.grade),
                    width: 1,
                  ),
                ),
                child: Text(
                  card.grade,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getGradeColor(card.grade),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '¥${card.acquiredPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          developer.log(
            'Card menu action selected: $value for card: ${card.name}',
            name: 'ProjectDetailPage',
          );
          switch (value) {
            case 'view':
              developer.log(
                'Navigating to card detail: ${card.name} (ID: ${card.id})',
                name: 'ProjectDetailPage',
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailPage(cardId: card.id!),
                ),
              );
              break;
            case 'remove':
              developer.log(
                'Showing remove card dialog for: ${card.name}',
                name: 'ProjectDetailPage',
              );
              _showRemoveCardDialog(context, card, viewModel);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'view',
            child: Row(
              children: [
                Icon(Icons.visibility),
                SizedBox(width: 8),
                Text('查看详情'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.remove_circle, color: Colors.orange),
                SizedBox(width: 8),
                Text('从项目移除', style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        developer.log(
          'Card tapped: ${card.name} (ID: ${card.id})',
          name: 'ProjectDetailPage',
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardDetailPage(cardId: card.id!),
          ),
        );
      },
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

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'PSA 10':
      case 'BGS 10':
        return Colors.purple;
      case 'PSA 9':
      case 'BGS 9':
        return Colors.blue;
      case 'PSA 8':
      case 'BGS 8':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  void _showManageCardsDialog(
    BuildContext context,
    ProjectDetailViewModel viewModel,
  ) {
    developer.log('Showing manage cards dialog', name: 'ProjectDetailPage');
    showDialog(
      context: context,
      builder: (context) => _ManageCardsDialog(
        projectId: viewModel.project!.id!,
        onCardsChanged: () => viewModel.loadProjectModel(projectId),
      ),
    );
  }

  void _showRemoveCardDialog(
    BuildContext context,
    CardModel card,
    ProjectDetailViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认移除'),
        content: Text(
          '确定要从项目中移除卡片 "${card.name}" 吗？\n\n注意：这不会删除卡片本身，只是从当前项目中移除。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.removeCardFromProjectModel(card.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('移除'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProjectDetailViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确定要删除项目 "${viewModel.project!.name}" 吗？'),
            const SizedBox(height: 8),
            if (viewModel.project!.cards.isNotEmpty)
              Text(
                '注意：该项目包含 ${viewModel.project!.cards.length} 张卡片，删除项目不会删除卡片本身。',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.orange[700]),
              ),
            const SizedBox(height: 8),
            const Text(
              '此操作无法撤销。',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              viewModel.deleteProjectModel().then((_) {
                if (context.mounted) {
                  Navigator.pop(context); // 返回上一页
                }
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 管理卡片对话框
class _ManageCardsDialog extends StatefulWidget {
  final int projectId;
  final VoidCallback onCardsChanged;

  const _ManageCardsDialog({
    required this.projectId,
    required this.onCardsChanged,
  });

  @override
  State<_ManageCardsDialog> createState() => _ManageCardsDialogState();
}

class _ManageCardsDialogState extends State<_ManageCardsDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ProjectDetailViewModel _projectViewModel;
  late CardListViewModel _cardListViewModel;
  final Set<int> _selectedCardIds = <int>{};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _projectViewModel = sl<ProjectDetailViewModel>();
    _cardListViewModel = sl<CardListViewModel>();

    // 加载项目和所有卡片数据
    _projectViewModel.loadProjectModel(widget.projectId);
    _cardListViewModel.loadCards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    developer.log(
      'Building ProjectDetailPage for project ID: ${widget.projectId}',
      name: 'ProjectDetailPage',
    );
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '管理项目卡片',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // 搜索栏
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '搜索卡片名称或编号...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // 标签栏
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '添加卡片'),
                Tab(text: '项目卡片'),
              ],
            ),

            // 内容区域
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildAddCardsTab(), _buildProjectCardsTab()],
              ),
            ),

            // 底部按钮
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_selectedCardIds.isNotEmpty) ...[
                    Text(
                      '已选择 ${_selectedCardIds.length} 张卡片',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _addSelectedCards,
                      child: const Text('添加到项目'),
                    ),
                  ] else ...[
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('关闭'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCardsTab() {
    return Consumer<CardListViewModel>(
      builder: (context, cardViewModel, child) {
        if (cardViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cardViewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(cardViewModel.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => cardViewModel.loadCards(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return Consumer<ProjectDetailViewModel>(
          builder: (context, projectViewModel, child) {
            final projectCardIds =
                projectViewModel.project?.cards.map((c) => c.id!).toSet() ??
                <int>{};
            final availableCards = cardViewModel.cards
                .where((card) => !projectCardIds.contains(card.id))
                .where(
                  (card) =>
                      _searchQuery.isEmpty ||
                      card.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      card.issueNumber.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                )
                .toList();

            if (availableCards.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card_off,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty ? '没有可添加的卡片' : '没有找到匹配的卡片',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isEmpty ? '所有卡片都已在此项目中' : '尝试其他搜索关键词',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: availableCards.length,
              itemBuilder: (context, index) {
                final card = availableCards[index];
                final isSelected = _selectedCardIds.contains(card.id);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedCardIds.add(card.id!);
                        } else {
                          _selectedCardIds.remove(card.id!);
                        }
                      });
                    },
                    secondary: Container(
                      width: 40,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: card.frontImage.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                card.frontImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.credit_card,
                                    color: Colors.grey[400],
                                    size: 20,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.credit_card,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                    ),
                    title: Text(
                      card.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('编号: ${card.issueNumber}'),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getGradeColor(
                                  card.grade,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getGradeColor(card.grade),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                card.grade,
                                style: TextStyle(
                                  color: _getGradeColor(card.grade),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '¥${card.acquiredPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProjectCardsTab() {
    return Consumer<ProjectDetailViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.project == null) {
          return const Center(child: Text('项目不存在'));
        }

        final projectCards = viewModel.project!.cards
            .where(
              (card) =>
                  _searchQuery.isEmpty ||
                  card.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  card.issueNumber.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();

        if (projectCards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.credit_card_off, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? '项目中暂无卡片' : '没有找到匹配的卡片',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isEmpty ? '在"添加卡片"标签中添加卡片到此项目' : '尝试其他搜索关键词',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: projectCards.length,
          itemBuilder: (context, index) {
            final card = projectCards[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: card.frontImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            card.frontImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.credit_card,
                                color: Colors.grey[400],
                                size: 20,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.credit_card,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                ),
                title: Text(
                  card.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('编号: ${card.issueNumber}'),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getGradeColor(
                              card.grade,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getGradeColor(card.grade),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            card.grade,
                            style: TextStyle(
                              color: _getGradeColor(card.grade),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '¥${card.acquiredPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CardDetailPage(cardId: card.id!),
                          ),
                        );
                        break;
                      case 'remove':
                        _showRemoveCardConfirmDialog(card);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('查看详情'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.remove_circle, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('从项目移除', style: TextStyle(color: Colors.orange)),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardDetailPage(cardId: card.id!),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'PSA 10':
      case 'BGS 10':
        return Colors.purple;
      case 'PSA 9':
      case 'BGS 9':
        return Colors.blue;
      case 'PSA 8':
      case 'BGS 8':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  void _addSelectedCards() async {
    if (_selectedCardIds.isEmpty) return;

    // 缓存context以避免异步操作后的使用问题
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 获取选中的卡片
    final selectedCards = _cardListViewModel.cards
        .where((card) => _selectedCardIds.contains(card.id))
        .toList();

    // 添加到项目
    final success = await _projectViewModel.addCardsToProjectModel(
      selectedCards,
    );

    if (success) {
      setState(() {
        _selectedCardIds.clear();
      });
      widget.onCardsChanged();

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('成功添加 ${selectedCards.length} 张卡片到项目'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(_projectViewModel.errorMessage ?? '添加卡片失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRemoveCardConfirmDialog(CardModel card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认移除'),
        content: Text(
          '确定要从项目中移除卡片 "${card.name}" 吗？\n\n注意：这不会删除卡片本身，只是从当前项目中移除。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 缓存context相关对象以避免异步操作后的使用问题
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              navigator.pop();
              final success = await _projectViewModel
                  .removeCardFromProjectModel(card.id!);
              if (success) {
                widget.onCardsChanged();
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('卡片已从项目中移除'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(_projectViewModel.errorMessage ?? '移除卡片失败'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('移除'),
          ),
        ],
      ),
    );
  }
}
