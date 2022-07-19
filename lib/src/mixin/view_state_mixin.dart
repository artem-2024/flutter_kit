import 'package:flutter/material.dart';
import '../../flutter_kit.dart';
import '../widget/default_loading.dart';

import 'app_overlay_mixin.dart';

///
/// 显示页面状态的另一种方式,通过Overlay实现
/// 提供了loading框
///
///
mixin ViewStateMixin<T extends StatefulWidget> on State<T>, AppOverlayMixin {
  /// 可重写get
  @override
  Widget get popWidget => DefaultLoading(title: loadingMsg);

  /// 加载提示的文字
  String loadingMsg = defaultLoadingMessage;

  /// 显示loading
  void showLoading(bool isShow, {String? loadingMsg, Color? backgroundColor}) {
    if (loadingMsg?.isNotEmpty == true) {
      this.loadingMsg = loadingMsg!;
    }
    showOverlay(isShow, backgroundColor: backgroundColor);
  }
}
