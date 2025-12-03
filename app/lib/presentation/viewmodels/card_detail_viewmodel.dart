import '../../domain/models/card/card.dart';
import '../../domain/usecases/card/get_card_by_id_usecase.dart';
import '../../domain/usecases/card/add_card_usecase.dart';
import '../../domain/usecases/card/update_card_usecase.dart';
import '../../domain/usecases/card/delete_card_usecase.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/data_sync_service.dart';
import 'base_viewmodel.dart';

/// 卡片详情 ViewModel
class CardDetailViewModel extends BaseViewModel {
  final GetCardByIdUseCase _getCardByIdUseCase = sl<GetCardByIdUseCase>();
  final AddCardUseCase _addCardUseCase = sl<AddCardUseCase>();
  final UpdateCardUseCase _updateCardUseCase = sl<UpdateCardUseCase>();
  final DeleteCardUseCase _deleteCardUseCase = sl<DeleteCardUseCase>();

  CardModel? _card;
  bool _isEditing = false;
  bool _isNewCard = false;

  /// 当前卡片
  CardModel? get card => _card;

  /// 是否正在编辑
  bool get isEditing => _isEditing;

  /// 是否是新卡片
  bool get isNewCard => _isNewCard;

  /// 是否可以编辑
  bool get canEdit => _card != null;

  /// 是否可以删除
  bool get canDelete => _card != null && _card!.id != null;

  /// 初始化新卡片
  void initializeNewCardModel() {
    _isNewCard = true;
    _isEditing = true;
    _card = CardModel(
      name: '',
      issueNumber: '',
      issueDate: '',
      grade: '',
      acquiredDate: '',
      acquiredPrice: 0.0,
      frontImage: '',
      backImage: '',
      gradeImage: '',
    );
    notifyListeners();
  }

  /// 加载卡片详情
  Future<void> loadCardModel(int cardId) async {
    _isNewCard = false;
    _isEditing = false;
    
    final card = await executeAsync(
      () => _getCardByIdUseCase.execute(cardId),
      errorPrefix: '加载卡片详情失败',
    );

    if (card != null) {
      _card = card;
    } else if (!hasError) {
      setError('卡片不存在');
    }
  }

  /// 开始编辑
  void startEditing() {
    if (_card != null) {
      _isEditing = true;
      notifyListeners();
    }
  }

  /// 取消编辑
  void cancelEditing() {
    if (_isNewCard) {
      _card = null;
      _isNewCard = false;
    }
    _isEditing = false;
    notifyListeners();
  }

  /// 更新卡片字段
  void updateCardModel({
    String? name,
    String? issueNumber,
    String? issueDate,
    String? grade,
    String? acquiredDate,
    double? acquiredPrice,
    String? frontImage,
    String? backImage,
    String? gradeImage,
  }) {
    if (_card == null) return;

    _card = _card!.copyWith(
      name: name ?? _card!.name,
      issueNumber: issueNumber ?? _card!.issueNumber,
      issueDate: issueDate ?? _card!.issueDate,
      grade: grade ?? _card!.grade,
      acquiredDate: acquiredDate ?? _card!.acquiredDate,
      acquiredPrice: acquiredPrice ?? _card!.acquiredPrice,
      frontImage: frontImage ?? _card!.frontImage,
      backImage: backImage ?? _card!.backImage,
      gradeImage: gradeImage ?? _card!.gradeImage,
    );
    notifyListeners();
  }

  /// 保存卡片
  Future<bool> saveCardModel() async {
    if (_card == null) return false;

    CardModel? savedCard;
    
    if (_isNewCard) {
      savedCard = await executeAsync(
        () => _addCardUseCase.execute(_card!),
        errorPrefix: '添加卡片失败',
      );
    } else {
      savedCard = await executeAsync(
        () => _updateCardUseCase.execute(_card!),
        errorPrefix: '更新卡片失败',
      );
      
      if (savedCard != null) {
        // 通知所有监听器刷新数据
        DataSyncService().notifyListeners(DataSyncEvents.cardUpdated);
        DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
      }
    }

    if (savedCard != null) {
      _card = savedCard;
      _isEditing = false;
      _isNewCard = false;
      notifyListeners();
      return true;
    }

    return false;
  }

  /// 删除卡片
  Future<bool> deleteCardModel() async {
    if (_card?.id == null) return false;

    final success = await executeAsyncVoid(
      () => _deleteCardUseCase.execute(_card!.id!),
      errorPrefix: '删除卡片失败',
    );

    if (success) {
      _card = null;
      _isEditing = false;
      _isNewCard = false;
      notifyListeners();
      
      // 通知所有监听器刷新数据
      DataSyncService().notifyListeners(DataSyncEvents.cardDeleted);
      DataSyncService().notifyListeners(DataSyncEvents.refreshDashboard);
    }

    return success;
  }

  /// 验证卡片数据
  Map<String, String?> validateCardModel() {
    final errors = <String, String?>{};
    
    if (_card == null) {
      errors['general'] = '卡片数据不能为空';
      return errors;
    }

    if (_card!.name.trim().isEmpty) {
      errors['name'] = '卡片名称不能为空';
    }

    if (_card!.issueNumber.trim().isEmpty) {
      errors['issueNumber'] = '发行编号不能为空';
    }

    if (_card!.issueDate.trim().isEmpty) {
      errors['issueDate'] = '发行时间不能为空';
    }

    if (_card!.grade.trim().isEmpty) {
      errors['grade'] = '评级不能为空';
    }

    if (_card!.acquiredDate.trim().isEmpty) {
      errors['acquiredDate'] = '入手时间不能为空';
    }

    if (_card!.acquiredPrice < 0) {
      errors['acquiredPrice'] = '入手价格不能为负数';
    }

    if (_card!.frontImage.trim().isEmpty) {
      errors['frontImage'] = '正面图不能为空';
    }

    // 验证日期格式
    try {
      DateTime.parse(_card!.issueDate);
    } catch (e) {
      errors['issueDate'] = '发行时间格式无效';
    }

    try {
      DateTime.parse(_card!.acquiredDate);
    } catch (e) {
      errors['acquiredDate'] = '入手时间格式无效';
    }

    return errors;
  }

  /// 检查是否有未保存的更改
  bool hasUnsavedChanges() {
    return _isEditing;
  }

  /// 重置卡片数据
  void resetCardModel() {
    if (_isNewCard) {
      initializeNewCardModel();
    } else if (_card?.id != null) {
      loadCardModel(_card!.id!);
    }
  }
}