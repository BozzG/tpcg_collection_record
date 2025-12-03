import 'dart:developer' as developer;
import 'package:flutter/material.dart';

/// 数据同步服务
/// 用于在不同页面之间同步数据状态
class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  final Map<String, List<VoidCallback>> _listeners = {};

  /// 注册监听器
  void addListener(String eventType, VoidCallback callback) {
    if (_listeners[eventType] == null) {
      _listeners[eventType] = [];
    }
    _listeners[eventType]!.add(callback);
    developer.log('Added listener for event: $eventType', name: 'DataSyncService');
  }

  /// 移除监听器
  void removeListener(String eventType, VoidCallback callback) {
    if (_listeners[eventType] != null) {
      _listeners[eventType]!.remove(callback);
      if (_listeners[eventType]!.isEmpty) {
        _listeners.remove(eventType);
      }
      developer.log('Removed listener for event: $eventType', name: 'DataSyncService');
    }
  }

  /// 通知所有监听器
  void notifyListeners(String eventType) {
    if (_listeners[eventType] != null) {
      developer.log('Notifying ${_listeners[eventType]!.length} listeners for event: $eventType', name: 'DataSyncService');
      for (final callback in _listeners[eventType]!) {
        try {
          callback();
        } catch (e) {
          developer.log('Error notifying listener: $e', name: 'DataSyncService', level: 1000);
        }
      }
    }
  }

  /// 清除所有监听器
  void clearAllListeners() {
    _listeners.clear();
    developer.log('Cleared all listeners', name: 'DataSyncService');
  }
}

/// 数据同步事件类型
class DataSyncEvents {
  static const String projectCreated = 'projectCreated';
  static const String projectUpdated = 'projectUpdated';
  static const String projectDeleted = 'projectDeleted';
  static const String cardCreated = 'cardCreated';
  static const String cardUpdated = 'cardUpdated';
  static const String cardDeleted = 'cardDeleted';
  static const String cardAddedToProject = 'cardAddedToProject';
  static const String cardRemovedFromProject = 'cardRemovedFromProject';
  static const String refreshDashboard = 'refreshDashboard';
}