import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// 格式化工具类
class FormatUtils {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'zh_CN',
    symbol: '¥',
    decimalDigits: AppConstants.priceDecimalPlaces,
  );
  
  static final NumberFormat _numberFormatter = NumberFormat('#,##0.00');
  
  /// 格式化价格为货币格式
  static String formatPrice(double price) {
    return _currencyFormatter.format(price);
  }
  
  /// 格式化数字（带千分位分隔符）
  static String formatNumber(double number) {
    return _numberFormatter.format(number);
  }
  
  /// 格式化整数（带千分位分隔符）
  static String formatInteger(int number) {
    return NumberFormat('#,##0').format(number);
  }
  
  /// 格式化百分比
  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    return '${(value * 100).toStringAsFixed(decimalPlaces)}%';
  }
  
  /// 格式化文件大小
  static String formatFileSize(int bytes) {
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
  
  /// 格式化卡片数量
  static String formatCardCount(int count) {
    if (count == 0) {
      return '暂无卡片';
    } else if (count == 1) {
      return '1张卡片';
    } else {
      return '${formatInteger(count)}张卡片';
    }
  }
  
  /// 格式化项目数量
  static String formatProjectCount(int count) {
    if (count == 0) {
      return '暂无项目';
    } else if (count == 1) {
      return '1个项目';
    } else {
      return '${formatInteger(count)}个项目';
    }
  }
  
  /// 截断文本并添加省略号
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
  
  /// 格式化评级显示
  static String formatGrade(String grade) {
    if (grade.isEmpty) {
      return AppConstants.defaultGrade;
    }
    return grade.toUpperCase();
  }
  
  /// 格式化发行编号显示
  static String formatIssueNumber(String issueNumber) {
    if (issueNumber.isEmpty) {
      return '未知编号';
    }
    return issueNumber.toUpperCase();
  }
  
  /// 格式化搜索结果数量
  static String formatSearchResultCount(int count) {
    if (count == 0) {
      return '未找到结果';
    } else if (count == 1) {
      return '找到1个结果';
    } else {
      return '找到${formatInteger(count)}个结果';
    }
  }
  
  /// 格式化价格范围
  static String formatPriceRange(double minPrice, double maxPrice) {
    return '${formatPrice(minPrice)} - ${formatPrice(maxPrice)}';
  }
  
  /// 格式化统计信息
  static String formatStatistic(String label, dynamic value) {
    if (value is int) {
      return '$label: ${formatInteger(value)}';
    } else if (value is double) {
      return '$label: ${formatNumber(value)}';
    } else {
      return '$label: $value';
    }
  }
  
  /// 首字母大写
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// 移除多余空格
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// 格式化为URL友好的字符串
  static String toSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[-\s]+'), '-')
        .trim();
  }
}