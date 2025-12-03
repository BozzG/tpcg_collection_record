# 图片处理功能使用指南

本项目实现了完整的本地图片存储和处理功能，包括图片选择、压缩、本地存储和读取。

## 功能特性

### 🖼️ ImageService - 图片处理服务
- **图片选择**: 支持从相册选择或相机拍照
- **自动压缩**: 自动将图片压缩到合适的尺寸和质量
- **本地存储**: 将图片保存到应用的本地目录
- **文件管理**: 支持删除、检查存在性、获取文件大小等操作

### 🎨 ImagePickerWidget - 图片选择器组件
- **统一界面**: 提供一致的图片选择用户界面
- **预览功能**: 支持图片预览和全屏查看
- **操作按钮**: 内置更换和删除按钮
- **状态管理**: 自动处理加载状态和错误状态

### 📱 ImagePreviewWidget - 图片预览组件
- **轻量级预览**: 用于显示已选择的图片
- **点击放大**: 支持点击查看全屏图片
- **错误处理**: 优雅处理图片加载失败的情况

## 使用方法

### 1. 在ViewModel中使用图片处理

```dart
class MyViewModel extends BaseViewModel {
  final ImageService _imageService = sl<ImageService>();

  // 从相册选择图片
  Future<String?> pickImageFromGallery() async {
    try {
      return await _imageService.pickImageFromGallery();
    } catch (e) {
      setError('选择图片失败: $e');
      return null;
    }
  }

  // 从相机拍照
  Future<String?> pickImageFromCamera() async {
    try {
      return await _imageService.pickImageFromCamera();
    } catch (e) {
      setError('拍照失败: $e');
      return null;
    }
  }

  // 处理图片路径（保存到本地）
  Future<String> processImagePath(String localPath) async {
    try {
      if (localPath.isEmpty) return '';
      return await _imageService.saveImageToLocal(localPath);
    } catch (e) {
      throw Exception('图片处理失败: $e');
    }
  }
}
```

### 2. 在UI中使用ImagePickerWidget

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 使用图片选择器组件
          ImagePickerWidget(
            imagePath: _imagePath,
            label: '卡片图片',
            placeholder: '点击选择图片',
            isRequired: true,
            width: 200,
            height: 160,
            onImageChanged: (imagePath) {
              setState(() {
                _imagePath = imagePath;
              });
            },
          ),
          
          // 使用图片预览组件
          ImagePreviewWidget(
            imagePath: _imagePath,
            width: 80,
            height: 100,
            placeholder: '暂无图片',
          ),
        ],
      ),
    );
  }
}
```

### 3. 图片处理流程

```dart
// 完整的图片处理流程示例
Future<void> handleImageProcessing() async {
  final imageService = sl<ImageService>();
  
  // 1. 选择图片
  final imagePath = await imageService.pickImageFromGallery();
  if (imagePath == null) return;
  
  // 2. 图片已自动压缩和保存到本地
  print('图片保存路径: $imagePath');
  
  // 3. 检查图片是否存在
  final exists = await imageService.imageExists(imagePath);
  print('图片存在: $exists');
  
  // 4. 获取图片大小
  final size = await imageService.getImageSize(imagePath);
  print('图片大小: ${imageService.formatFileSize(size)}');
  
  // 5. 读取图片文件
  final imageFile = await imageService.getImageFromPath(imagePath);
  if (imageFile != null) {
    // 使用图片文件
    print('图片文件: ${imageFile.path}');
  }
  
  // 6. 删除图片（如果需要）
  // await imageService.deleteImage(imagePath);
}
```

## 技术实现

### 图片存储结构
```
应用文档目录/
├── card_images/           # 主图片目录
│   ├── 1638360000000_image1.jpg
│   ├── 1638360001000_image2.png
│   └── thumbnails/        # 缩略图目录（预留）
│       ├── image1_thumb.jpg
│       └── image2_thumb.png
```

### 图片处理参数
- **最大尺寸**: 1024x1024 像素
- **压缩质量**: 85%
- **支持格式**: JPG, PNG
- **文件命名**: 时间戳 + 原文件名

### 依赖项
```yaml
dependencies:
  image_picker: ^1.0.7      # 图片选择
  path_provider: ^2.1.4     # 获取应用目录
  path: ^1.9.0              # 路径处理
```

## 最佳实践

### 1. 错误处理
```dart
try {
  final imagePath = await imageService.pickImageFromGallery();
  // 处理成功情况
} catch (e) {
  // 显示用户友好的错误信息
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('选择图片失败: $e')),
  );
}
```

### 2. 内存管理
```dart
// 定期清理不再使用的图片
await imageService.clearImageCache();

// 获取图片目录总大小
final totalSize = await imageService.getImageDirectorySize();
print('图片缓存大小: ${imageService.formatFileSize(totalSize)}');
```

### 3. 用户体验
- 使用加载指示器显示图片处理进度
- 提供图片预览功能
- 支持图片的更换和删除操作
- 优雅处理图片加载失败的情况

## 注意事项

1. **权限**: 确保应用具有相机和存储权限
2. **性能**: 大量图片可能影响应用性能，建议实现懒加载
3. **存储**: 定期清理不再使用的图片文件
4. **网络**: 如需同步到服务器，可在ImageService基础上扩展上传功能

## 扩展功能

### 未来可以添加的功能
- [ ] 图片编辑（裁剪、旋转、滤镜）
- [ ] 云存储同步
- [ ] 图片缓存优化
- [ ] 批量图片处理
- [ ] 图片水印添加
- [ ] EXIF信息处理

---

通过这套图片处理系统，应用可以完全离线工作，所有图片都存储在本地，提供了良好的用户体验和数据安全性。