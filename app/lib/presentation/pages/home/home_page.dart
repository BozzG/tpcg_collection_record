import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../cards/card_list_page.dart';
import '../cards/add_card_page.dart';
import '../cards/card_detail_page.dart';
import '../projects/project_list_page.dart';
import '../../../core/services/data_sync_service.dart';
import '../../../core/di/viewmodel_locator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataSyncService _dataSyncService = DataSyncService();
  late HomeViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();

    // 获取全局的 HomeViewModel 实例
    _homeViewModel = ViewModelLocator().homeViewModel;

    // 注册数据同步监听器
    _dataSyncService.addListener(
      DataSyncEvents.refreshDashboard,
      _refreshDashboard,
    );
    _dataSyncService.addListener(DataSyncEvents.cardCreated, _refreshDashboard);
    _dataSyncService.addListener(DataSyncEvents.cardUpdated, _refreshDashboard);
    _dataSyncService.addListener(DataSyncEvents.cardDeleted, _refreshDashboard);

    // 加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeViewModel.loadDashboardData();
    });
  }

  @override
  void dispose() {
    // 移除数据同步监听器
    _dataSyncService.removeListener(
      DataSyncEvents.refreshDashboard,
      _refreshDashboard,
    );
    _dataSyncService.removeListener(
      DataSyncEvents.cardCreated,
      _refreshDashboard,
    );
    _dataSyncService.removeListener(
      DataSyncEvents.cardUpdated,
      _refreshDashboard,
    );
    _dataSyncService.removeListener(
      DataSyncEvents.cardDeleted,
      _refreshDashboard,
    );
    super.dispose();
  }

  void _refreshDashboard() {
    if (mounted) {
      _homeViewModel.loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _homeViewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TPCG 收藏记录'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          elevation: 0,
        ),
        body: Consumer<HomeViewModel>(
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
                      onPressed: () => viewModel.loadDashboardData(),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 统计卡片区域
                  _buildStatsSection(context, viewModel),
                  const SizedBox(height: 24),

                  // 最近添加的卡片
                  _buildRecentCardsSection(context, viewModel),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCardPage()),
            );
            // 如果添加了新卡片，刷新首页数据
            if (result != null && context.mounted) {
              context.read<HomeViewModel>().loadDashboardData();
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '收藏统计',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                '卡片数',
                '${viewModel.totalCards}',
                Icons.credit_card,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CardListPage()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                '项目数',
                '${viewModel.totalProjects}',
                Icons.folder,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProjectListPage()),
                ),
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
                '总价值',
                '¥${viewModel.totalValue.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.orange,
                null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                '平均价值',
                '¥${viewModel.averageValue.toStringAsFixed(2)}',
                Icons.trending_up,
                Colors.purple,
                null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildRecentCardsSection(
    BuildContext context,
    HomeViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近添加',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CardListPage()),
              ),
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (viewModel.recentCards.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.credit_card_off,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '还没有卡片',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击右下角的 + 按钮添加第一张卡片',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.recentCards.length,
            itemBuilder: (context, index) {
              final card = viewModel.recentCards[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.credit_card, color: Colors.blue[700]),
                  ),
                  title: Text(card.name),
                  subtitle: Text('¥${card.acquiredPrice.toStringAsFixed(2)}'),
                  trailing: Text(
                    card.acquiredDate,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardDetailPage(cardId: card.id!),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
