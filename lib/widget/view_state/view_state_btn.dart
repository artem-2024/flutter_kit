import 'package:flutter/material.dart';

import '../theme_button.dart';

///
/// 状态按钮 （eg，点击刷新、点击登录等）
///
class ViewStateBtn extends StatelessWidget {
  const ViewStateBtn({
    Key? key,
    required this.label,
    this.onTap,
  }) : super(key: key);
  final String label;

  /// 点击事件
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ThemeButton(
      label,
      textFontSize: 14,
      width: 100,
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 7),
      onTap: onTap,
    );
  }
}
