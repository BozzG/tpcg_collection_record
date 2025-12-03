import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/services/image_service.dart';
import '../../core/di/service_locator.dart';

/// 图片选择器组件
/// 支持显示图片、选择图片、删除图片等功能
class ImagePickerWidget extends StatefulWidget {
  final String? imagePath;
  final String placeholder;
  final double width;
  final double height;
  final Function(String?) onImageChanged;
  final bool isRequired;
  final String label;

  const ImagePickerWidget({
    super.key,
    this.imagePath,
    this.placeholder = '点击选择图片',
    this.width = 120,
    this.height = 160,
    required this.onImageChanged,
    this.isRequired = false,
    this.label = '图片',
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImageService _imageService = sl<ImageService>();
  String? _currentImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
  }

  @override
  void didUpdateWidget(ImagePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imagePath != oldWidget.imagePath) {
      setState(() {
        _currentImagePath = widget.imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        Row(
          children: [
            Text(
              widget.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        // 图片容器
        GestureDetector(
          onTap: _isLoading ? null : _showImagePickerDialog,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: _buildImageContent(),
          ),
        ),
        
        // 操作按钮
        if (_currentImagePath != null && _currentImagePath!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: _isLoading ? null : _showImagePickerDialog,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('更换'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _isLoading ? null : _removeImage,
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text('删除', style: TextStyle(color: Colors.red)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_currentImagePath != null && _currentImagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(_currentImagePath!),
          fit: BoxFit.cover,
          width: widget.width,
          height: widget.height,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(
              icon: Icons.broken_image,
              text: '图片加载失败',
              color: Colors.red[300],
            );
          },
        ),
      );
    }

    return _buildPlaceholder(
      icon: Icons.add_photo_alternate,
      text: widget.placeholder,
      color: Colors.grey[400],
    );
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 32,
          color: color ?? Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color ?? Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('选择${widget.label}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  void _pickImageFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imagePath = await _imageService.pickImageFromGallery();
      if (imagePath != null) {
        setState(() {
          _currentImagePath = imagePath;
        });
        widget.onImageChanged(imagePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _pickImageFromCamera() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imagePath = await _imageService.pickImageFromCamera();
      if (imagePath != null) {
        setState(() {
          _currentImagePath = imagePath;
        });
        widget.onImageChanged(imagePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拍照失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除${widget.label}吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentImagePath = null;
                });
                widget.onImageChanged(null);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
}

/// 图片预览组件
/// 用于显示已选择的图片，支持点击放大查看
class ImagePreviewWidget extends StatelessWidget {
  final String? imagePath;
  final double width;
  final double height;
  final String placeholder;

  const ImagePreviewWidget({
    super.key,
    this.imagePath,
    this.width = 80,
    this.height = 100,
    this.placeholder = '暂无图片',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: imagePath != null && imagePath!.isNotEmpty
          ? () => _showFullScreenImage(context)
          : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
          color: Colors.grey[50],
        ),
        child: _buildImageContent(context),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(imagePath!),
          fit: BoxFit.cover,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(
              context,
              icon: Icons.broken_image,
              text: '加载失败',
              color: Colors.red[300],
            );
          },
        ),
      );
    }

    return _buildPlaceholder(
      context,
      icon: Icons.image,
      text: placeholder,
      color: Colors.grey[400],
    );
  }

  Widget _buildPlaceholder(
    BuildContext context, {
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: color ?? Colors.grey[400],
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color ?? Colors.grey[600],
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}