import '../constants/app_constants.dart';
import 'date_utils.dart';

/// 验证工具类
class ValidationUtils {
  /// 验证项目名称
  static String? validateProjectName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '项目名称不能为空';
    }
    
    if (name.trim().length > AppConstants.maxProjectNameLength) {
      return '项目名称不能超过${AppConstants.maxProjectNameLength}个字符';
    }
    
    return null;
  }
  
  /// 验证项目描述
  static String? validateProjectDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return '项目描述不能为空';
    }
    
    if (description.trim().length > AppConstants.maxProjectDescriptionLength) {
      return '项目描述不能超过${AppConstants.maxProjectDescriptionLength}个字符';
    }
    
    return null;
  }
  
  /// 验证卡片名称
  static String? validateCardName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '卡片名称不能为空';
    }
    
    if (name.trim().length > AppConstants.maxCardNameLength) {
      return '卡片名称不能超过${AppConstants.maxCardNameLength}个字符';
    }
    
    return null;
  }
  
  /// 验证发行编号
  static String? validateIssueNumber(String? issueNumber) {
    if (issueNumber == null || issueNumber.trim().isEmpty) {
      return '发行编号不能为空';
    }
    
    if (issueNumber.trim().length > AppConstants.maxIssueNumberLength) {
      return '发行编号不能超过${AppConstants.maxIssueNumberLength}个字符';
    }
    
    return null;
  }
  
  /// 验证评级
  static String? validateGrade(String? grade) {
    if (grade == null || grade.trim().isEmpty) {
      return '评级不能为空';
    }
    
    if (grade.trim().length > AppConstants.maxGradeLength) {
      return '评级不能超过${AppConstants.maxGradeLength}个字符';
    }
    
    return null;
  }
  
  /// 验证日期
  static String? validateDate(String? date) {
    if (date == null || date.trim().isEmpty) {
      return '日期不能为空';
    }
    
    if (!DateUtils.isValidDateFormat(date.trim())) {
      return '日期格式无效，请使用 yyyy-MM-dd 格式';
    }
    
    return null;
  }
  
  /// 验证价格
  static String? validatePrice(String? priceString) {
    if (priceString == null || priceString.trim().isEmpty) {
      return '价格不能为空';
    }
    
    final price = double.tryParse(priceString.trim());
    if (price == null) {
      return '价格格式无效';
    }
    
    if (price < AppConstants.minPrice) {
      return '价格不能小于${AppConstants.minPrice}';
    }
    
    if (price > AppConstants.maxPrice) {
      return '价格不能大于${AppConstants.maxPrice}';
    }
    
    return null;
  }
  
  /// 验证价格（double 类型）
  static String? validatePriceDouble(double? price) {
    if (price == null) {
      return '价格不能为空';
    }
    
    if (price < AppConstants.minPrice) {
      return '价格不能小于${AppConstants.minPrice}';
    }
    
    if (price > AppConstants.maxPrice) {
      return '价格不能大于${AppConstants.maxPrice}';
    }
    
    return null;
  }
  
  /// 验证图片路径
  static String? validateImagePath(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return '图片路径不能为空';
    }
    
    return null;
  }
  
  /// 验证搜索关键词
  static String? validateSearchKeyword(String? keyword) {
    if (keyword == null || keyword.trim().isEmpty) {
      return '搜索关键词不能为空';
    }
    
    if (keyword.trim().length < AppConstants.minSearchLength) {
      return '搜索关键词至少需要${AppConstants.minSearchLength}个字符';
    }
    
    return null;
  }
  
  /// 验证ID
  static String? validateId(int? id) {
    if (id == null || id <= 0) {
      return 'ID必须大于0';
    }
    
    return null;
  }
  
  /// 验证价格范围
  static String? validatePriceRange(double? minPrice, double? maxPrice) {
    if (minPrice == null || maxPrice == null) {
      return '价格范围不能为空';
    }
    
    if (minPrice < AppConstants.minPrice) {
      return '最低价格不能小于${AppConstants.minPrice}';
    }
    
    if (maxPrice > AppConstants.maxPrice) {
      return '最高价格不能大于${AppConstants.maxPrice}';
    }
    
    if (minPrice > maxPrice) {
      return '最低价格不能大于最高价格';
    }
    
    return null;
  }
  
  /// 验证日期范围
  static String? validateDateRange(String? startDate, String? endDate) {
    if (startDate == null || startDate.trim().isEmpty ||
        endDate == null || endDate.trim().isEmpty) {
      return '日期范围不能为空';
    }
    
    final startDateError = validateDate(startDate);
    if (startDateError != null) {
      return '开始日期：$startDateError';
    }
    
    final endDateError = validateDate(endDate);
    if (endDateError != null) {
      return '结束日期：$endDateError';
    }
    
    if (startDate.trim().compareTo(endDate.trim()) > 0) {
      return '开始日期不能晚于结束日期';
    }
    
    return null;
  }
  
  /// 验证邮箱格式
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return '邮箱不能为空';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return '邮箱格式无效';
    }
    
    return null;
  }
  
  /// 验证手机号格式
  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return '手机号不能为空';
    }
    
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(phoneNumber.trim())) {
      return '手机号格式无效';
    }
    
    return null;
  }
}