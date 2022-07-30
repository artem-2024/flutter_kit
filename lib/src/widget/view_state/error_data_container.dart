import 'package:flutter/material.dart';

import '../../../flutter_kit.dart';
import '../../utils/gesture.dart';
import '../default_appbar.dart';
import 'component_empty_container.dart';

class ErrorDataContainer extends StatelessWidget {
  /// 标题
  final String? title;


  /// 按钮文字
  final String btnText;

  final VoidCallback? onRefresh;

  final bool showHeader;

  const ErrorDataContainer({
    Key? key,
    this.title,
    this.onRefresh,
    this.showHeader = false,
    this.btnText = '刷新一下',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child = ComponentEmptyContainer(
      title: title ?? errorMessage,
      btnText: btnText,
      showBtn: true,
    );
    if (onRefresh != null) {
      child = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: GestureUtils.throttle(() => onRefresh?.call()),
        child: child,
      );
    }
    return Scaffold(
      appBar: showHeader ? DefaultAppBar() : null,
      body: Center(
        child: child,
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Image.asset(
        //       assetBundleUrl,
        //       width: 165,
        //       height: 100,
        //     ),
        //     const SizedBox(height: 20),
        //     ViewStateTitle(title),
        //     const SizedBox(height: 24),
        //     ViewStateBtn(
        //         label: btnText,
        //         onTap: onRefresh,
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
