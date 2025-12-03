import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/card_list_viewmodel.dart';
import '../../../domain/models/card/card.dart';
import '../../../routing/app_router.dart';
import 'card_detail_page.dart';
import 'add_card_page.dart';

class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGrade = '';
  String _sortBy = 'name';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardListViewModel()..loadCards(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('卡片收藏'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () => _showSortDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
          ],
        ),
        body: Consumer<CardListViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // 搜索栏
                _buildSearchBar(context, viewModel),
                
                // 筛选标签
                if (_selectedGrade.isNotEmpty || _searchController.text.isNotEmpty)
                  _buildFilterChips(context, viewModel),
                
                // 卡片列表
                Expanded(
                  child: _buildCardList(context, viewModel),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCardPage()),
            );
            // 如果添加了新卡片，刷新列表
            if (result != null && mounted) {
              // 使用 State.context 而不是参数中的 context
              this.context.read<CardListViewModel>().loadCards();
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, CardListViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索卡片名称或编号...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    viewModel.searchCards('');
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
          viewModel.searchCards(value);
        },
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, CardListViewModel viewModel) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_searchController.text.isNotEmpty)
            Chip(
              label: Text('搜索: ${_searchController.text}'),
              onDeleted: () {
                _searchController.clear();
                viewModel.searchCards('');
              },
            ),
          if (_selectedGrade.isNotEmpty) ...[
            const SizedBox(width: 8),
            Chip(
              label: Text('评级: $_selectedGrade'),
              onDeleted: () {
                setState(() {
                  _selectedGrade = '';
                });
                viewModel.filterByGrade('');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardList(BuildContext context, CardListViewModel viewModel) {
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
              onPressed: () => viewModel.loadCards(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (viewModel.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无卡片',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角的 + 按钮添加第一张卡片',
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
        await viewModel.loadCards();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: viewModel.cards.length,
        itemBuilder: (context, index) {
          final card = viewModel.cards[index];
          return _buildCardItem(context, card, viewModel);
        },
      ),
    );
  }

  Widget _buildCardItem(BuildContext context, CardModel card, CardListViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardDetailPage(cardId: card.id!),
          ),
        ),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 卡片图片占位符
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: card.frontImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          card.frontImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.credit_card,
                              color: Colors.grey[400],
                              size: 32,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.credit_card,
                        color: Colors.grey[400],
                        size: 32,
                      ),
              ),
              const SizedBox(width: 16),
              
              // 卡片信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '编号: ${card.issueNumber}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getGradeColor(card.grade).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
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
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '入手时间: ${card.acquiredDate}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 操作按钮
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      // 导航到编辑页面
                      final result = await Navigator.pushNamed(
                        context,
                        AppRouter.editCard,
                        arguments: {'cardId': card.id.toString()},
                      );
                      // 如果编辑成功，刷新列表
                      if (result != null && mounted) {
                        this.context.read<CardListViewModel>().loadCards();
                      }
                      break;
                    case 'delete':
                      _showDeleteDialog(context, card, viewModel);
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
        ),
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

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('排序方式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('按名称'),
              leading: Icon(
                _sortBy == 'name' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _sortBy == 'name' ? Theme.of(context).primaryColor : Colors.grey,
              ),
              onTap: () {
                setState(() {
                  _sortBy = 'name';
                });
                Navigator.pop(context);
                context.read<CardListViewModel>().setSortType(_getSortType(_sortBy));
              },
            ),
            ListTile(
              title: const Text('按价格'),
              leading: Icon(
                _sortBy == 'price' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _sortBy == 'price' ? Theme.of(context).primaryColor : Colors.grey,
              ),
              onTap: () {
                setState(() {
                  _sortBy = 'price';
                });
                Navigator.pop(context);
                context.read<CardListViewModel>().setSortType(_getSortType(_sortBy));
              },
            ),
            ListTile(
              title: const Text('按入手时间'),
              leading: Icon(
                _sortBy == 'date' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _sortBy == 'date' ? Theme.of(context).primaryColor : Colors.grey,
              ),
              onTap: () {
                setState(() {
                  _sortBy = 'date';
                });
                Navigator.pop(context);
                context.read<CardListViewModel>().setSortType(_getSortType(_sortBy));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选评级'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('全部'),
              onTap: () {
                setState(() {
                  _selectedGrade = '';
                });
                Navigator.pop(context);
                context.read<CardListViewModel>().filterByGrade('');
              },
            ),
            ListTile(
              title: const Text('PSA 10'),
              onTap: () {
                setState(() {
                  _selectedGrade = 'PSA 10';
                });
                Navigator.pop(context);
                context.read<CardListViewModel>().filterByGrade('PSA 10');
              },
            ),
            ListTile(
              title: const Text('PSA 9'),
              onTap: () {
                setState(() {
                  _selectedGrade = 'PSA 9';
                });
                Navigator.pop(context);
                context.read<CardListViewModel>().filterByGrade('PSA 9');
              },
            ),
            ListTile(
              title: const Text('BGS 10'),
              onTap: () {
                setState(() {
                  _selectedGrade = 'BGS 10';
                });
                Navigator.pop(context);
                context.read<CardListViewModel>().filterByGrade('BGS 10');
              },
            ),
            ListTile(
              title: const Text('BGS 9'),
              onTap: () {
                setState(() {
                  _selectedGrade = 'BGS 9';
                });
                Navigator.pop(context);
                context.read<CardListViewModel>().filterByGrade('BGS 9');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CardModel card, CardListViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除卡片 "${card.name}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteCardModel(card.id!);
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

  CardSortType _getSortType(String sortBy) {
    switch (sortBy) {
      case 'name':
        return CardSortType.nameAsc;
      case 'price':
        return CardSortType.priceAsc;
      case 'date':
        return CardSortType.dateAsc;
      default:
        return CardSortType.nameAsc;
    }
  }
}