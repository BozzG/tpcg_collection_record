import 'package:flutter/foundation.dart';

/// 基础 ViewModel 类
/// 提供通用的状态管理功能
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 错误消息
  String? get errorMessage => _errorMessage;

  /// 是否有错误
  bool get hasError => _errorMessage != null;

  /// 设置加载状态
  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置错误消息
  void setError(String? error) {
    if (_isDisposed) return;
    _errorMessage = error;
    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    if (_isDisposed) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// 执行异步操作的通用方法
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
    String? errorPrefix,
  }) async {
    try {
      if (showLoading) setLoading(true);
      clearError();
      
      final result = await operation();
      return result;
    } catch (e) {
      final errorMsg = errorPrefix != null ? '$errorPrefix: $e' : e.toString();
      setError(errorMsg);
      return null;
    } finally {
      if (showLoading) setLoading(false);
    }
  }

  /// 执行无返回值的异步操作
  Future<bool> executeAsyncVoid(
    Future<void> Function() operation, {
    bool showLoading = true,
    String? errorPrefix,
  }) async {
    try {
      if (showLoading) setLoading(true);
      clearError();
      
      await operation();
      return true;
    } catch (e) {
      final errorMsg = errorPrefix != null ? '$errorPrefix: $e' : e.toString();
      setError(errorMsg);
      return false;
    } finally {
      if (showLoading) setLoading(false);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}