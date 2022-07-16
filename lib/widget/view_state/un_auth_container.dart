import 'package:flutter/material.dart';
import 'package:lms_app/config/build_config.dart';
import 'package:lms_app/core/router/app_router_delegate.dart';

import '../default_appbar.dart';
import 'view_state_btn.dart';
import 'view_state_title.dart';

///
/// 登录失效状态
///
class UnAuthContainer extends StatelessWidget {
  // 标题
  final String title;

  /// assets bundle图片ur;
  final String assetBundleUrl;

  final bool showHeader;

  final bool showTitle;

  final Size iconSize;
  const UnAuthContainer({
    Key? key,
    this.title = unAuthMessage,
    this.assetBundleUrl = emptyAssetBundleUrl,
    this.showHeader = false,
    this.showTitle = true,
    this.iconSize = const Size(165,165),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showHeader ? DefaultAppBar() : null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              assetBundleUrl,
              width: iconSize.width,
              height: iconSize.height,
            ),
            showTitle ? ViewStateTitle(title) : const SizedBox(),
            const SizedBox(height: 24),
            ViewStateBtn(
              label: '戳我登录',
              onTap: () => AppRouterDelegate.of().jumpLoginPage(),
            ),
          ],
        ),
      ),
    );
  }
}
