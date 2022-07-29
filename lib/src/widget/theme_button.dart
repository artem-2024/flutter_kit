import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/gesture.dart';

///
/// 主题样式的按钮
///
class ThemeButton extends StatelessWidget {
  const ThemeButton(
    this.text, {
    Key? key,
    this.width,
    this.height,
    this.decoration,
    this.isDisableStatus = false,
    this.isUseDisableStyle = false,
    this.onTap,
    this.textColor,
    this.textFontSize = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 7, horizontal: 30),
  }) : super(key: key);

  /// 按钮文字
  final String text;

  /// 按钮宽度
  final double? width;

  /// 按钮高度
  final double? height;

  /// 最小限制
  final double _minWidth = 82;
  final double _minHeight = 44;

  /// 装饰
  final Decoration? decoration;

  /// 按钮是否是禁用状态
  final bool isDisableStatus;

  /// 按钮是否使用禁用样式且能点击
  final bool isUseDisableStyle;

  /// 点击事件
  final VoidCallback? onTap;

  /// 按钮文字颜色
  final Color? textColor;

  /// 按钮文字大小
  final double textFontSize;

  /// 内边距
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    var tmpMinHeight = max((height ?? 0), _minHeight);
    return GestureDetector(
      onTap: GestureUtils.throttle(
        () {
          if (isDisableStatus) return;
          onTap?.call();
        },
      ),
      child: AnimatedContainer(
        duration: kTabScrollDuration,
        width: width ?? _minWidth,
        height: height ?? _minHeight,
        alignment: Alignment.center,
        padding: padding,
        constraints: BoxConstraints(
          minWidth: max((width ?? 0), _minWidth),
          minHeight: tmpMinHeight,
        ),
        decoration: decoration ??
            BoxDecoration(
              color: isDisableStatus || isUseDisableStyle
                  ? const Color(0xffD8DCDF)
                  : Theme.of(context).primaryColor,
              borderRadius:
                  BorderRadius.all(Radius.circular(tmpMinHeight / 2.0)),
              boxShadow: isDisableStatus || isUseDisableStyle
                  ? null
                  : [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: textFontSize, color: textColor),
          ),
        ),
      ),
    );
  }
}
