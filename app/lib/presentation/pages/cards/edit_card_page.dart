import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/card/card.dart';
import '../../../core/di/service_locator.dart';
import '../../viewmodels/edit_card_viewmodel.dart';
import '../../widgets/image_picker_widget.dart';

class EditCardPage extends StatefulWidget {
  final int cardId;

  const EditCardPage({super.key, required this.cardId});

  @override
  State<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
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
  
  bool _isLoading = true;

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
  void initState() {
    super.initState();
    _loadCardData();
  }

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

  Future<void> _loadCardData() async {
    final viewModel = sl<EditCardViewModel>();
    final card = await viewModel.loadCard(widget.cardId);
    
    if (card != null && mounted) {
      setState(() {
        _nameController.text = card.name;
        _issueNumberController.text = card.issueNumber;
        _issueDateController.text = card.issueDate;
        _gradeController.text = card.grade;
        _acquiredDateController.text = card.acquiredDate;
        _acquiredPriceController.text = card.acquiredPrice.toString();
        _frontImagePath = card.frontImage.isNotEmpty ? card.frontImage : null;
        _backImagePath = card.backImage.isNotEmpty ? card.backImage : null;
        _gradeImagePath = card.gradeImage.isNotEmpty ? card.gradeImage : null;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('加载卡片数据失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<EditCardViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('编辑卡片'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Consumer<EditCardViewModel>(
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
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
                      Consumer<EditCardViewModel>(
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
              '更新卡片的正面、背面和评级证书图片',
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

  Widget _buildSaveButton(EditCardViewModel viewModel) {
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
                '保存更改',
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

  Future<void> _saveCard(EditCardViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 检查必需的图片
    if (_frontImagePath == null || _frontImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请上传卡片正面图片')),
      );
      return;
    }

    try {
      // 创建更新的卡片对象
      final updatedCard = CardModel(
        id: widget.cardId, // 保持原有ID
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
      final validationError = viewModel.validateCard(updatedCard);
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError)),
        );
        return;
      }

      // 检查是否有变化
      if (!viewModel.hasChanges(updatedCard)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有检测到任何更改')),
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
      final finalCard = updatedCard.copyWith(
        frontImage: processedImages['frontImage']!,
        backImage: processedImages['backImage']!,
        gradeImage: processedImages['gradeImage']!,
      );

      // 调用 ViewModel 更新卡片
      final savedCard = await viewModel.updateCard(finalCard);

      if (savedCard != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('卡片更新成功！'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, savedCard);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新失败，请重试')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e')),
        );
      }
    }
  }
}