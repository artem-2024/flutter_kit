import 'package:flutter/material.dart';

import '../../../flutter_kit.dart';
import 'nested_scroll_view_refresh_indicator_null_safety.dart';

/// 默认的下拉刷新头部
class RefreshListIndicator extends StatelessWidget {
  const RefreshListIndicator({
    this.refreshKey,
    Key? key,
    required this.onRefresh,
    required this.child,
    this.isNes = false,
  }) : super(key: key);

  final Key? refreshKey;

  /// 刷新回调
  final RefreshCallback onRefresh;

  /// 子部件 （eg: [ListView]）
  final Widget child;

  /// 是否用于NestedScrollView default=false
  final bool isNes;

  @override
  Widget build(BuildContext context) {
    if (isNes == true) {
      return NestedScrollViewRefreshIndicator(
        key: refreshKey,
        color: ColorHelper.colorTheme,
        backgroundColor: Colors.white,
        onRefresh: onRefresh,
        child: child,
      );
    }
    return RefreshIndicator(
      key: refreshKey,
      color: ColorHelper.colorTheme,
      backgroundColor: Colors.white,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
