import '../../domain/models/card/card.dart';
import '../../domain/usecases/card/add_card_usecase.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/image_service.dart';
import '../../core/services/data_sync_service.dart';
import 'base_viewmodel.dart';

/// 添加卡片 ViewModel
class AddCardViewModel extends BaseViewModel {
  final AddCardUseCase _addCardUseCase = sl<AddCardUseCase>();
  final ImageService _imageService = sl<ImageService>();

  /// 添加卡片
  /// 
  /// [card] 要添加的卡片对象
  /// 返回添加后的卡片对象（包含生成的ID），失败时返回 null
  Future<CardModel?> addCard(CardModel card) async {
    // 执行添加操作
    final addedCard = await executeAsync(
      () => _addCardUseCase.execute(card),
      errorPrefix: '添加卡片失败',
    );

    if (addedCard != null) {
      // 通知所有监听器刷新数据
      DataSyncService().notifyListeners(DataSyncEvents.cardCreated);
      DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
    }

    return addedCard;
  }

  /// 验证卡片数据
  /// 
  /// [card] 要验证的卡片对象
  /// 返回验证结果，如果有错误则返回错误信息
  String? validateCard(CardModel card) {
    try {
      // 基本字段验证
      if (card.name.trim().isEmpty) {
        return '卡片名称不能为空';
      }
      
      if (card.issueNumber.trim().isEmpty) {
        return '发行编号不能为空';
      }
      
      if (card.issueDate.trim().isEmpty) {
        return '发行时间不能为空';
      }
      
      if (card.grade.trim().isEmpty) {
        return '评级不能为空';
      }
      
      if (card.acquiredDate.trim().isEmpty) {
        return '入手时间不能为空';
      }
      
      if (card.acquiredPrice < 0) {
        return '入手价格不能为负数';
      }
      
      if (card.frontImage.trim().isEmpty) {
        return '请上传卡片正面图片';
      }
      
      // 日期格式验证
      if (!_isValidDateFormat(card.issueDate)) {
        return '发行时间格式无效，请使用 YYYY-MM-DD 格式';
      }
      
      if (!_isValidDateFormat(card.acquiredDate)) {
        return '入手时间格式无效，请使用 YYYY-MM-DD 格式';
      }
      
      // 日期逻辑验证
      final issueDate = DateTime.tryParse(card.issueDate);
      final acquiredDate = DateTime.tryParse(card.acquiredDate);
      
      if (issueDate != null && acquiredDate != null) {
        if (acquiredDate.isBefore(issueDate)) {
          return '入手时间不能早于发行时间';
        }
        
        if (acquiredDate.isAfter(DateTime.now())) {
          return '入手时间不能晚于当前时间';
        }
      }
      
      // 价格范围验证
      if (card.acquiredPrice > 1000000) {
        return '入手价格不能超过100万元';
      }
      
      return null; // 验证通过
    } catch (e) {
      return '数据验证失败: $e';
    }
  }

  /// 验证日期格式 (YYYY-MM-DD)
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

  /// 预处理图片路径
  /// 
  /// 将临时图片保存到应用本地目录
  Future<String> processImagePath(String localPath) async {
    try {
      if (localPath.isEmpty) return '';
      
      // 使用ImageService将图片保存到应用目录
      return await _imageService.saveImageToLocal(localPath);
    } catch (e) {
      throw Exception('图片处理失败: $e');
    }
  }

  /// 从相册选择图片
  Future<String?> pickImageFromGallery() async {
    try {
      return await _imageService.pickImageFromGallery();
    } catch (e) {
      setError('选择图片失败: $e');
      return null;
    }
  }

  /// 从相机拍照
  Future<String?> pickImageFromCamera() async {
    try {
      return await _imageService.pickImageFromCamera();
    } catch (e) {
      setError('拍照失败: $e');
      return null;
    }
  }

  /// 删除图片文件
  Future<bool> deleteImage(String imagePath) async {
    try {
      return await _imageService.deleteImage(imagePath);
    } catch (e) {
      return false;
    }
  }

  /// 检查图片是否存在
  Future<bool> imageExists(String imagePath) async {
    try {
      return await _imageService.imageExists(imagePath);
    } catch (e) {
      return false;
    }
  }

  /// 批量处理图片
  Future<Map<String, String>> processImages({
    required String frontImage,
    String? backImage,
    String? gradeImage,
  }) async {
    final Map<String, String> processedImages = {};
    
    try {
      // 处理正面图片（必需）
      processedImages['frontImage'] = await processImagePath(frontImage);
      
      // 处理背面图片（可选）
      if (backImage != null && backImage.isNotEmpty) {
        processedImages['backImage'] = await processImagePath(backImage);
      } else {
        processedImages['backImage'] = '';
      }
      
      // 处理评级图片（可选）
      if (gradeImage != null && gradeImage.isNotEmpty) {
        processedImages['gradeImage'] = await processImagePath(gradeImage);
      } else {
        processedImages['gradeImage'] = '';
      }
      
      return processedImages;
    } catch (e) {
      throw Exception('图片处理失败: $e');
    }
  }
}