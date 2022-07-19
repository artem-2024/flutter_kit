import 'package:flutter/material.dart';

import '../../flutter_kit.dart';
import '../utils/gesture.dart';
import 'image/default_image.dart';

///
/// 默认的单项item
/// 左侧图标 左侧文本、右侧widget、右侧文本、右侧箭头
///
class DefaultListTile extends StatelessWidget {
  const DefaultListTile({
    Key? key,
    required this.label,
    this.rightWidget,
    this.rightText,
    this.icon,
    this.onTap,
    this.padding,
    this.margin,
    this.showArrowRightIcon = true,
    this.showBottomLine = false,
    this.arrowRightIconColor,
  }) : super(key: key);

  /// 点击事件
  final Function? onTap;

  /// 左侧文本
  final String label;

  /// 左侧图标
  final String? icon;

  /// 右侧widget
  final Widget? rightWidget;

  /// 右侧文本
  final String? rightText;

  /// 是否显示右侧小箭头
  final bool showArrowRightIcon;

  /// 右侧小箭头颜色 （默认黑灰色）
  final Color? arrowRightIconColor;

  /// 是否显示底部线条
  final bool showBottomLine;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: GestureUtils.throttle(() => onTap?.call()),
      child: Container(
        padding: padding,
        margin: margin,
        decoration: showBottomLine
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: ColorHelper.colorLine),
                ),
              )
            : null,
        height: 60,
        child: Row(
          children: [
            icon?.isNotEmpty == true
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DefaultAssetImage(
                      icon!,
                      width: 22,
                      height: 22,
                    ),
                  )
                : const SizedBox.shrink(),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: ColorHelper.colorTextBlack1,
              ),
            ),
            const Spacer(),
            rightText?.isNotEmpty == true || rightWidget != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: rightText?.isNotEmpty == true
                        ? Text(
                            rightText!,
                            style: TextStyle(
                              fontSize: 12,
                              color: arrowRightIconColor ??
                                  ColorHelper.colorTextBlack2,
                            ),
                          )
                        : rightWidget,
                  )
                : const SizedBox.shrink(),
            showArrowRightIcon
                ? DefaultAssetImage(
                    'assets/images/common/icon_arrow_right.png',
                    width: 5,
                    height: 8,
                    color: arrowRightIconColor,
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
