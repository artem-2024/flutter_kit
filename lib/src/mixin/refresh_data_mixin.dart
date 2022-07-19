import 'dart:async';

import 'package:flutter/widgets.dart';

import '../event/refresh_widget_data_event.dart';
import '../utils/default_event_bus.dart';

/// 封装刷新数据逻辑
mixin RefreshDataMixin<T extends StatefulWidget> on State<T> {
  /// 监听根事件
  StreamSubscription? _refreshEvent;

  /// 需要刷新数据
  void onShouldRefreshData();

  /// 判断是否需要刷新
  bool get checkShouldRefresh {
    return shouldRefreshWidgetNamesLast?.isNotEmpty != true ||
        shouldRefreshWidgetNamesLast!.contains(widget.runtimeType.toString());
  }

  @override
  void initState() {
    super.initState();
    _refreshEvent = DefaultEventBus.instance
        .on<RefreshWidgetDataEvent>()
        .listen(_onRefreshEvent);
  }

  @override
  void dispose() {
    _refreshEvent?.cancel();
    super.dispose();
  }

  /// 保留最近一次需要刷新的widget名称
  List<String>? shouldRefreshWidgetNamesLast;

  /// 监听刷新事件
  void _onRefreshEvent(RefreshWidgetDataEvent event) {
    shouldRefreshWidgetNamesLast = event.shouldRefreshWidgetNames;
    final shouldRefresh = checkShouldRefresh;
    if (shouldRefresh) {
      onShouldRefreshData();
    }
  }
}
