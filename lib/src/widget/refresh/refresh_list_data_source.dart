import 'package:flutter/widgets.dart';
import 'package:loading_more_list/loading_more_list.dart';

typedef LoadDataCallBack<C> = Future<C> Function(int offset);

typedef OnDataChangeListener<C> = void Function(List<C> data);

///
/// 上下拉刷新的数据源
///
class RefreshListDataSource<T> extends LoadingMoreBase<T> {
  RefreshListDataSource(this.pageSize,{
    required this.loadDataCallBack,
    this.onDataChangeListener,
  });

  /// 加载数据的回调方法
  LoadDataCallBack<List<T>?> loadDataCallBack;

  /// 数据变化的回调
  OnDataChangeListener? onDataChangeListener;

  /// 默认第一页
  int _offset = 1;

  /// 是否还有更多数据
  bool _hasMore = true;

  /// 每页多少条数据 default=20
  int pageSize;

  @override
  bool get hasMore => _hasMore;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    debugPrint('RefreshListDataSource notifyStateChanged=$notifyStateChanged');
    _offset = 0;
    _hasMore = true;
    return await super.refresh(notifyStateChanged);
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    debugPrint('RefreshListDataSource isLoadMoreAction=$isloadMoreAction');
    bool isSuccess = false;
    bool hasError = false;
    var newOffset = _offset + 1;
    try {
      var listData = await loadDataCallBack(newOffset);
      if (newOffset == 1) {
        clear();
      }
      //操作集合数据
      listData?.forEach((element) {
        add(element);
      });
      _offset = newOffset;
      _hasMore = (listData?.length??0) >= pageSize;

      isSuccess = true;
    } catch (exception, stack) {
      hasError = true;
      debugPrint(exception.toString());
      debugPrint(stack.toString());
    }
    onDataChangeListener?.call(this);
    return isloadMoreAction ? isSuccess : !hasError;
  }
}
