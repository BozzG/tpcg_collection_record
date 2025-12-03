import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:developer' as developer;
import '../../../core/services/image_service.dart';

/// 文件选择测试页面
/// 用于调试和测试 FilePicker 功能
class FilePickerTestPage extends StatefulWidget {
  const FilePickerTestPage({super.key});

  @override
  State<FilePickerTestPage> createState() => _FilePickerTestPageState();
}

class _FilePickerTestPageState extends State<FilePickerTestPage> {
  String _testResult = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件选择测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '平台: $defaultTargetPlatform',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testImagePicker,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('测试图片选择'),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testDirectFilePicker,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('测试直接文件选择'),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testFilePickerWithDifferentOptions,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('测试不同选项的文件选择'),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              '测试结果:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: SingleChildScrollView(
                  child: Text(_testResult),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testImagePicker() async {
    setState(() {
      _isLoading = true;
      _testResult = '测试图片选择...\n';
    });

    try {
      developer.log('开始测试图片选择', name: 'FilePickerTest');
      final imagePath = await ImageService().pickImageFromGallery();
      
      if (imagePath != null) {
        setState(() {
          _testResult += '\n成功选择图片: $imagePath';
        });
        developer.log('图片选择成功: $imagePath', name: 'FilePickerTest');
      } else {
        setState(() {
          _testResult += '\n用户取消了图片选择';
        });
        developer.log('用户取消了图片选择', name: 'FilePickerTest');
      }
    } catch (e) {
      setState(() {
        _testResult += '\n错误: $e';
      });
      developer.log('图片选择失败: $e', name: 'FilePickerTest', level: 1000);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDirectFilePicker() async {
    setState(() {
      _isLoading = true;
      _testResult = '测试直接文件选择...\n';
    });

    try {
      developer.log('开始测试直接文件选择', name: 'FilePickerTest');
      
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        // 直接使用 FilePicker 进行测试
        final result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
          dialogTitle: '测试文件选择',
        );
        
        if (result != null && result.files.single.path != null) {
          setState(() {
            _testResult += '\n成功选择文件: ${result.files.single.path}';
            _testResult += '\n文件名: ${result.files.single.name}';
            _testResult += '\n文件大小: ${result.files.single.size} 字节';
          });
          developer.log('文件选择成功: ${result.files.single.path}', name: 'FilePickerTest');
        } else {
          setState(() {
            _testResult += '\n用户取消了文件选择';
          });
          developer.log('用户取消了文件选择', name: 'FilePickerTest');
        }
      } else {
        setState(() {
          _testResult += '\n此测试仅在 macOS 上运行';
        });
      }
    } catch (e) {
      setState(() {
        _testResult += '\n错误: $e';
      });
      developer.log('文件选择失败: $e', name: 'FilePickerTest', level: 1000);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFilePickerWithDifferentOptions() async {
    setState(() {
      _isLoading = true;
      _testResult = '测试不同选项的文件选择...\n';
    });

    try {
      developer.log('开始测试不同选项的文件选择', name: 'FilePickerTest');
      
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        // 测试不同配置
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'png', 'gif'],
          allowMultiple: false,
          dialogTitle: '选择图片文件 (仅 jpg, png, gif)',
          lockParentWindow: true,
        );
        
        if (result != null && result.files.single.path != null) {
          setState(() {
            _testResult += '\n成功选择文件: ${result.files.single.path}';
            _testResult += '\n文件名: ${result.files.single.name}';
            _testResult += '\n文件大小: ${result.files.single.size} 字节';
          });
          developer.log('文件选择成功: ${result.files.single.path}', name: 'FilePickerTest');
        } else {
          setState(() {
            _testResult += '\n用户取消了文件选择';
          });
          developer.log('用户取消了文件选择', name: 'FilePickerTest');
        }
      } else {
        setState(() {
          _testResult += '\n此测试仅在 macOS 上运行';
        });
      }
    } catch (e) {
      setState(() {
        _testResult += '\n错误: $e';
      });
      developer.log('文件选择失败: $e', name: 'FilePickerTest', level: 1000);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}