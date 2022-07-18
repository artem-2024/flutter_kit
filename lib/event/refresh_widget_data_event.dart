
import '../utils/logger.dart';

/// 刷新控件数据的事件
/// 可参考 [RefreshDataMixin]
class RefreshWidgetDataEvent {
  RefreshWidgetDataEvent({this.shouldRefreshWidgetNames}){
    LogUtils.instance.i('RefreshWidgetDataEvent 这些Widget需要刷新数据（无则全刷）: $shouldRefreshWidgetNames');
  }

  /// 需要刷新哪些widget的数据？ 传null默认所有都刷新
  final List<String>? shouldRefreshWidgetNames;
}
