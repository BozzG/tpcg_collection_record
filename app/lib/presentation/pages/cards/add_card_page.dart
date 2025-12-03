import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/card/card.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/data_sync_service.dart';
import '../../viewmodels/add_card_viewmodel.dart';
import '../../widgets/image_picker_widget.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issueNumberController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _gradeController = TextEditingController();
  final _acquiredDateController = TextEditingController();
  final _acquiredPriceController = TextEditingController();

  String? _frontImagePath;
  String? _backImagePath;
  String? _gradeImagePath;

  // 预定义的评级选项
  final List<String> _gradeOptions = [
    'PSA 10',
    'PSA 9',
    'PSA 8',
    'PSA 7',
    'PSA 6',
    'BGS 10',
    'BGS 9.5',
    'BGS 9',
    'BGS 8.5',
    'BGS 8',
    '未评级',
    '其他',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _issueNumberController.dispose();
    _issueDateController.dispose();
    _gradeController.dispose();
    _acquiredDateController.dispose();
    _acquiredPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<AddCardViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('添加卡片'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Consumer<AddCardViewModel>(
              builder: (context, viewModel, child) {
                return TextButton(
                  onPressed: viewModel.isLoading ? null : () => _saveCard(viewModel),
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
                // 基本信息区域
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                
                // 评级信息区域
                _buildGradeSection(),
                const SizedBox(height: 24),
                
                // 入手信息区域
                _buildAcquisitionSection(),
                const SizedBox(height: 24),
                
                // 图片上传区域
                _buildImageSection(),
                const SizedBox(height: 32),
                
                // 保存按钮
                Consumer<AddCardViewModel>(
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

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 卡片名称
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '卡片名称 *',
                hintText: '请输入卡片名称',
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入卡片名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 发行编号
            TextFormField(
              controller: _issueNumberController,
              decoration: const InputDecoration(
                labelText: '发行编号 *',
                hintText: '请输入卡片发行编号',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入发行编号';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 发行时间
            TextFormField(
              controller: _issueDateController,
              decoration: const InputDecoration(
                labelText: '发行时间 *',
                hintText: '请输入发行时间 (YYYY-MM-DD)',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
                helperText: '格式：2023-12-01',
              ),
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入发行时间';
                }
                if (!_isValidDateFormat(value.trim())) {
                  return '请输入正确的日期格式 (YYYY-MM-DD)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '评级信息',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 评级选择
            DropdownButtonFormField<String>(
              initialValue: _gradeController.text.isEmpty
                  ? null
                  : _gradeController.text,
              decoration: const InputDecoration(
                labelText: '评级 *',
                prefixIcon: Icon(Icons.star),
                border: OutlineInputBorder(),
              ),
              items: _gradeOptions.map((grade) {
                return DropdownMenuItem(value: grade, child: Text(grade));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _gradeController.text = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请选择评级';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcquisitionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '入手信息',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 入手时间
            TextFormField(
              controller: _acquiredDateController,
              decoration: const InputDecoration(
                labelText: '入手时间 *',
                hintText: '请输入入手时间 (YYYY-MM-DD)',
                prefixIcon: Icon(Icons.event),
                border: OutlineInputBorder(),
                helperText: '格式：2023-12-01',
              ),
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入入手时间';
                }
                if (!_isValidDateFormat(value.trim())) {
                  return '请输入正确的日期格式 (YYYY-MM-DD)';
                }
                // 检查入手时间不能早于发行时间
                if (_issueDateController.text.isNotEmpty &&
                    _isValidDateFormat(_issueDateController.text.trim())) {
                  final issueDate = DateTime.tryParse(
                    _issueDateController.text.trim(),
                  );
                  final acquiredDate = DateTime.tryParse(value.trim());
                  if (issueDate != null &&
                      acquiredDate != null &&
                      acquiredDate.isBefore(issueDate)) {
                    return '入手时间不能早于发行时间';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 入手价格
            TextFormField(
              controller: _acquiredPriceController,
              decoration: const InputDecoration(
                labelText: '入手价格 *',
                hintText: '请输入入手价格',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
                suffixText: '元',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入入手价格';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return '请输入有效的价格';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '卡片图片',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '添加卡片的正面、背面和评级证书图片',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // 图片上传区域
            Row(
              children: [
                Expanded(
                  child: ImagePickerWidget(
                    imagePath: _frontImagePath,
                    label: '正面图片',
                    placeholder: '点击选择正面图片',
                    isRequired: true,
                    width: double.infinity,
                    height: 160,
                    onImageChanged: (imagePath) {
                      setState(() {
                        _frontImagePath = imagePath;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ImagePickerWidget(
                    imagePath: _backImagePath,
                    label: '背面图片',
                    placeholder: '点击选择背面图片',
                    width: double.infinity,
                    height: 160,
                    onImageChanged: (imagePath) {
                      setState(() {
                        _backImagePath = imagePath;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ImagePickerWidget(
                    imagePath: _gradeImagePath,
                    label: '评级证书',
                    placeholder: '点击选择评级证书',
                    width: double.infinity,
                    height: 160,
                    onImageChanged: (imagePath) {
                      setState(() {
                        _gradeImagePath = imagePath;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(AddCardViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : () => _saveCard(viewModel),
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
            : const Text(
                '保存卡片',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  // 验证日期格式 (YYYY-MM-DD)
  bool _isValidDateFormat(String dateString) {
    if (dateString.length != 10) return false;

    final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(dateString)) return false;

    try {
      final parts = dateString.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      // 基本范围检查
      if (year < 1900 || year > DateTime.now().year + 10) return false;
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;

      // 使用 DateTime 验证日期是否真实存在
      final date = DateTime(year, month, day);
      return date.year == year && date.month == month && date.day == day;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveCard(AddCardViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 检查必需的图片
    if (_frontImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请上传卡片正面图片')),
      );
      return;
    }

    try {
      // 创建卡片对象
      final card = CardModel(
        name: _nameController.text.trim(),
        issueNumber: _issueNumberController.text.trim(),
        issueDate: _issueDateController.text,
        grade: _gradeController.text,
        acquiredDate: _acquiredDateController.text,
        acquiredPrice: double.parse(_acquiredPriceController.text),
        frontImage: _frontImagePath ?? '',
        backImage: _backImagePath ?? '',
        gradeImage: _gradeImagePath ?? '',
      );

      // 使用 ViewModel 验证数据
      final validationError = viewModel.validateCard(card);
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError)),
        );
        return;
      }

      // 处理图片（在实际应用中可能需要上传到服务器）
      final processedImages = await viewModel.processImages(
        frontImage: _frontImagePath!,
        backImage: _backImagePath,
        gradeImage: _gradeImagePath,
      );

      // 创建最终的卡片对象（使用处理后的图片路径）
      final finalCard = card.copyWith(
        frontImage: processedImages['frontImage']!,
        backImage: processedImages['backImage']!,
        gradeImage: processedImages['gradeImage']!,
      );

      // 调用 ViewModel 保存卡片
      final addedCard = await viewModel.addCard(finalCard);

      if (addedCard != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('卡片保存成功！'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 通知所有监听器刷新数据
        DataSyncService().notifyListeners(DataSyncEvents.cardCreated);
        DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
        
        Navigator.pop(context, addedCard);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败，请重试')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }
}
