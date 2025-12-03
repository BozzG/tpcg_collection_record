import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// 日期工具类
class DateUtils {
  static final DateFormat _dateFormatter = DateFormat(AppConstants.dateFormat);
  static final DateFormat _dateTimeFormatter = DateFormat(AppConstants.dateTimeFormat);
  
  /// 将日期格式化为字符串 (yyyy-MM-dd)
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }
  
  /// 将日期时间格式化为字符串 (yyyy-MM-dd HH:mm:ss)
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime);
  }
  
  /// 解析日期字符串
  static DateTime? parseDate(String dateString) {
    try {
      return _dateFormatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// 解析日期时间字符串
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return _dateTimeFormatter.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }
  
  /// 验证日期字符串格式
  static bool isValidDateFormat(String dateString) {
    return parseDate(dateString) != null;
  }
  
  /// 验证日期时间字符串格式
  static bool isValidDateTimeFormat(String dateTimeString) {
    return parseDateTime(dateTimeString) != null;
  }
  
  /// 获取当前日期字符串
  static String getCurrentDate() {
    return formatDate(DateTime.now());
  }
  
  /// 获取当前日期时间字符串
  static String getCurrentDateTime() {
    return formatDateTime(DateTime.now());
  }
  
  /// 计算两个日期之间的天数差
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }
  
  /// 检查日期是否在指定范围内
  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
           date.isBefore(end.add(const Duration(days: 1)));
  }
  
  /// 获取月份的第一天
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// 获取月份的最后一天
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
  
  /// 获取年份的第一天
  static DateTime getFirstDayOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }
  
  /// 获取年份的最后一天
  static DateTime getLastDayOfYear(DateTime date) {
    return DateTime(date.year, 12, 31);
  }
  
  /// 格式化相对时间（如：2天前、1小时前）
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}