import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/card_detail_viewmodel.dart';
import '../../../domain/models/card/card.dart';
import '../../../routing/app_router.dart';

class CardDetailPage extends StatelessWidget {
  final int cardId;

  const CardDetailPage({super.key, required this.cardId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardDetailViewModel()..loadCardModel(cardId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('卡片详情'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Consumer<CardDetailViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.card == null) return const SizedBox.shrink();

                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        // 导航到编辑页面
                        Navigator.pushNamed(
                          context,
                          AppRouter.editCard,
                          arguments: {'cardId': cardId.toString()},
                        ).then((result) {
                          // 如果编辑成功，刷新页面数据
                          if (result != null) {
                            viewModel.loadCardModel(cardId);
                          }
                        });
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
                );
              },
            ),
          ],
        ),
        body: Consumer<CardDetailViewModel>(
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
                      onPressed: () => viewModel.loadCardModel(cardId),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.card == null) {
              return const Center(child: Text('卡片不存在'));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 卡片图片区域
                  _buildImageSection(context, viewModel.card!),

                  // 卡片基本信息
                  _buildBasicInfoSection(context, viewModel.card!),

                  // 卡片详细信息
                  _buildDetailInfoSection(context, viewModel.card!),

                  // 价值信息
                  _buildValueInfoSection(context, viewModel.card!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, CardModel card) {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[100],
      child: PageView(
        children: [
          // 正面图片
          _buildImageView(context, card.frontImage, '正面', Icons.credit_card),
          // 背面图片
          _buildImageView(context, card.backImage, '背面', Icons.credit_card),
          // 评级图片
          if (card.gradeImage.isNotEmpty)
            _buildImageView(context, card.gradeImage, '评级证书', Icons.verified),
        ],
      ),
    );
  }

  Widget _buildImageView(
    BuildContext context,
    String imageUrl,
    String label,
    IconData fallbackIcon,
  ) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder(fallbackIcon, label);
                  },
                )
              : _buildImagePlaceholder(fallbackIcon, label),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(IconData icon, String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            '暂无$label图片',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context, CardModel card) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getGradeColor(card.grade).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getGradeColor(card.grade),
                    width: 1,
                  ),
                ),
                child: Text(
                  card.grade,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getGradeColor(card.grade),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '¥${card.acquiredPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInfoSection(BuildContext context, CardModel card) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '详细信息',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(context, '发行编号', card.issueNumber),
              _buildInfoRow(context, '发行时间', card.issueDate),
              _buildInfoRow(context, '评级', card.grade),
              _buildInfoRow(context, '入手时间', card.acquiredDate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueInfoSection(BuildContext context, CardModel card) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '价值信息',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildValueCardModel(
                      context,
                      '入手价格',
                      '¥${card.acquiredPrice.toStringAsFixed(2)}',
                      Icons.shopping_cart,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildValueCardModel(
                      context,
                      '当前估值',
                      '¥${(card.acquiredPrice * 1.2).toStringAsFixed(2)}', // 示例估值
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildValueCardModel(
                      context,
                      '涨幅',
                      '+20%', // 示例涨幅
                      Icons.arrow_upward,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildValueCardModel(
                      context,
                      '持有天数',
                      _calculateHoldingDays(card.acquiredDate).toString(),
                      Icons.calendar_today,
                      Colors.orange,
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCardModel(
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

  int _calculateHoldingDays(String acquiredDate) {
    try {
      final acquired = DateTime.parse(acquiredDate);
      final now = DateTime.now();
      return now.difference(acquired).inDays;
    } catch (e) {
      return 0;
    }
  }

  void _showDeleteDialog(BuildContext context, CardDetailViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除卡片 "${viewModel.card!.name}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              viewModel.deleteCardModel().then((_) {
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
