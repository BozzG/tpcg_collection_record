import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

/// 图片处理服务
/// 负责图片的选择、压缩、本地存储和读取
class ImageService {
  static const String _imageDirectory = 'card_images';
  static const int _maxImageSize = 1024; // 最大图片尺寸
  static const int _imageQuality = 85; // 图片质量
  
  /// 初始化图片服务
  static Future<void> initialize() async {
    developer.log('初始化 ImageService', name: 'ImageService');
    
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      try {
        // 预热 FilePicker，解决首次调用可能不生效的问题
        await FilePicker.platform.clearTemporaryFiles();
        developer.log('FilePicker 初始化完成', name: 'ImageService');
      } catch (e) {
        developer.log('FilePicker 初始化失败: $e', name: 'ImageService', level: 1000);
      }
    }
  }

  /// 从相册选择图片
  Future<String?> pickImageFromGallery() async {
    developer.log('开始选择图片', name: 'ImageService');
    try {
      developer.log('平台: $defaultTargetPlatform', name: 'ImageService');
      // 在 macOS 上使用访达选择文件
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        developer.log('macOS平台，使用访达选择文件', name: 'ImageService');
        return await pickImageFromFinder();
      }

      developer.log('移动平台，使用相册选择图片', name: 'ImageService');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxImageSize.toDouble(),
        maxHeight: _maxImageSize.toDouble(),
        imageQuality: _imageQuality,
      );

      if (image != null) {
        developer.log('成功选择图片: ${image.path}', name: 'ImageService');
        final savedPath = await _saveImageToLocal(image.path);
        developer.log('图片已保存到本地: $savedPath', name: 'ImageService');
        return savedPath;
      }
      developer.log('用户取消了图片选择', name: 'ImageService');
      return null;
    } catch (e) {
      developer.log('选择图片失败: $e', name: 'ImageService', level: 1000);
      throw Exception('选择图片失败: $e');
    }
  }

  /// 在 macOS 上从访达选择图片文件
  Future<String?> pickImageFromFinder() async {
    developer.log('打开访达文件选择器', name: 'ImageService');
    try {
      // 尝试使用更详细的配置调用文件选择器
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
        allowMultiple: false,
        dialogTitle: '选择图片文件',
        lockParentWindow: true,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        developer.log('用户选择了文件: $filePath', name: 'ImageService');
        developer.log('文件大小: ${result.files.single.size} 字节', name: 'ImageService');

        // 检查文件是否为图片类型
        if (_isImageFile(filePath)) {
          developer.log('文件格式验证通过，开始保存', name: 'ImageService');
          final savedPath = await _saveImageToLocal(filePath);
          developer.log('图片已保存到本地: $savedPath', name: 'ImageService');
          return savedPath;
        } else {
          developer.log(
            '文件格式验证失败: $filePath',
            name: 'ImageService',
            level: 900,
          );
          throw Exception('选择的文件不是有效的图片格式');
        }
      } else {
        developer.log('用户取消了文件选择或没有选择任何文件', name: 'ImageService');
        developer.log('结果对象: $result', name: 'ImageService');
        return null;
      }
    } catch (e) {
      developer.log('从访达选择图片失败: $e', name: 'ImageService', level: 1000);
      
      // 添加更详细的错误信息
      String errorMessage = e.toString();
      if (errorMessage.contains('permission')) {
        errorMessage = '应用缺少文件访问权限，请在系统设置中授予应用文件访问权限';
      } else if (errorMessage.contains('canceled')) {
        errorMessage = '用户取消了文件选择';
      }
      
      throw Exception('从访达选择图片失败: $errorMessage');
    }
  }

  /// 检查文件是否为图片类型
  bool _isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    const validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return validExtensions.contains(extension);
  }

  /// 从相机拍照
  Future<String?> pickImageFromCamera() async {
    developer.log('启动相机拍照', name: 'ImageService');
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: _maxImageSize.toDouble(),
        maxHeight: _maxImageSize.toDouble(),
        imageQuality: _imageQuality,
      );

      if (image != null) {
        developer.log('拍照成功: ${image.path}', name: 'ImageService');
        final savedPath = await _saveImageToLocal(image.path);
        developer.log('照片已保存到本地: $savedPath', name: 'ImageService');
        return savedPath;
      }
      developer.log('用户取消了拍照', name: 'ImageService');
      return null;
    } catch (e) {
      developer.log('拍照失败: $e', name: 'ImageService', level: 1000);
      throw Exception('拍照失败: $e');
    }
  }

  /// 显示图片选择对话框
  Future<String?> showImagePickerDialog(BuildContext context) async {
    developer.log('显示图片选择对话框', name: 'ImageService');
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择图片'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(
                  defaultTargetPlatform == TargetPlatform.macOS
                      ? '从访达选择'
                      : '从相册选择',
                ),
                onTap: () async {
                  developer.log(
                    '用户选择${defaultTargetPlatform == TargetPlatform.macOS ? '从访达' : '从相册'}选择图片',
                    name: 'ImageService',
                  );
                  Navigator.pop(context);
                  final imagePath = await pickImageFromGallery();
                  if (context.mounted) {
                    Navigator.pop(context, imagePath);
                  }
                },
              ),
              // 在非移动平台上隐藏相机选项
              if (defaultTargetPlatform != TargetPlatform.macOS)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('拍照'),
                  onTap: () async {
                    developer.log('用户选择拍照', name: 'ImageService');
                    Navigator.pop(context);
                    final imagePath = await pickImageFromCamera();
                    if (context.mounted) {
                      Navigator.pop(context, imagePath);
                    }
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                developer.log('用户取消图片选择', name: 'ImageService');
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  /// 将图片保存到应用本地目录
  Future<String> saveImageToLocal(String sourcePath) async {
    developer.log('开始保存图片到本地: $sourcePath', name: 'ImageService');
    return await _saveImageToLocal(sourcePath);
  }

  /// 将图片保存到应用本地目录（内部方法）
  Future<String> _saveImageToLocal(String sourcePath) async {
    try {
      // 获取应用文档目录
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory(
        path.join(appDocDir.path, _imageDirectory),
      );

      developer.log('图片目录路径: ${imageDir.path}', name: 'ImageService');

      // 创建图片目录（如果不存在）
      if (!await imageDir.exists()) {
        developer.log('图片目录不存在，创建新目录', name: 'ImageService');
        await imageDir.create(recursive: true);
        developer.log('图片目录创建成功', name: 'ImageService');
      }

      // 生成唯一的文件名
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(sourcePath)}';
      final String targetPath = path.join(imageDir.path, fileName);

      developer.log('生成目标文件名: $fileName', name: 'ImageService');

      // 复制文件到目标位置
      final File sourceFile = File(sourcePath);
      final File targetFile = await sourceFile.copy(targetPath);

      developer.log('图片保存成功: ${targetFile.path}', name: 'ImageService');
      return targetFile.path;
    } catch (e) {
      developer.log('保存图片失败: $e', name: 'ImageService', level: 1000);
      throw Exception('保存图片失败: $e');
    }
  }

  /// 从本地路径读取图片
  Future<File?> getImageFromPath(String imagePath) async {
    developer.log('尝试读取图片: $imagePath', name: 'ImageService');
    try {
      if (imagePath.isEmpty) {
        developer.log('图片路径为空', name: 'ImageService', level: 900);
        return null;
      }

      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        developer.log('图片读取成功: $imagePath', name: 'ImageService');
        return imageFile;
      }
      developer.log('图片文件不存在: $imagePath', name: 'ImageService', level: 900);
      return null;
    } catch (e) {
      developer.log('读取图片失败: $e', name: 'ImageService', level: 1000);
      throw Exception('读取图片失败: $e');
    }
  }

  /// 删除本地图片文件
  Future<bool> deleteImage(String imagePath) async {
    developer.log('尝试删除图片: $imagePath', name: 'ImageService');
    try {
      if (imagePath.isEmpty) {
        developer.log('图片路径为空，无需删除', name: 'ImageService');
        return true;
      }

      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        developer.log('图片删除成功: $imagePath', name: 'ImageService');
        return true;
      }
      developer.log('图片文件不存在: $imagePath', name: 'ImageService');
      return true; // 文件不存在也算删除成功
    } catch (e) {
      developer.log('删除图片失败: $e', name: 'ImageService', level: 1000);
      return false;
    }
  }

  /// 获取图片文件大小（字节）
  Future<int> getImageSize(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        return await imageFile.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// 检查图片文件是否存在
  Future<bool> imageExists(String imagePath) async {
    try {
      if (imagePath.isEmpty) return false;
      final File imageFile = File(imagePath);
      return await imageFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// 获取图片的缩略图路径（如果需要的话）
  Future<String?> getThumbnailPath(String originalPath) async {
    try {
      if (originalPath.isEmpty) return null;

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory thumbDir = Directory(
        path.join(appDocDir.path, _imageDirectory, 'thumbnails'),
      );

      if (!await thumbDir.exists()) {
        await thumbDir.create(recursive: true);
      }

      final String fileName = path.basenameWithoutExtension(originalPath);
      final String extension = path.extension(originalPath);
      final String thumbPath = path.join(
        thumbDir.path,
        '${fileName}_thumb$extension',
      );

      return thumbPath;
    } catch (e) {
      return null;
    }
  }

  /// 清理所有图片缓存
  Future<bool> clearImageCache() async {
    developer.log('开始清理图片缓存', name: 'ImageService');
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory(
        path.join(appDocDir.path, _imageDirectory),
      );

      if (await imageDir.exists()) {
        developer.log('删除图片目录: ${imageDir.path}', name: 'ImageService');
        await imageDir.delete(recursive: true);
        developer.log('图片缓存清理成功', name: 'ImageService');
        return true;
      }
      developer.log('图片目录不存在，无需清理', name: 'ImageService');
      return true;
    } catch (e) {
      developer.log('清理图片缓存失败: $e', name: 'ImageService', level: 1000);
      return false;
    }
  }

  /// 获取图片目录的总大小
  Future<int> getImageDirectorySize() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory(
        path.join(appDocDir.path, _imageDirectory),
      );

      if (!await imageDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final FileSystemEntity entity in imageDir.list(
        recursive: true,
      )) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// 格式化文件大小显示
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
