import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 屏幕工具
class ScreenUtils {
  ScreenUtils._();

  /// 是否是横屏状态
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// 获取软键盘高度，需要Scaffold.resizeToAvoidBottomInset为false,否则可能获取为0
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// 隐藏软键盘
  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  /// 返回状态栏高度
  static double getTopBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// 返回底部安全距离高度
  static double getBottomSafeAreaHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// 返回16：9的高度
  static double get16_9(BuildContext context) {
    double expandedHeight = 0;
    var media = MediaQuery.of(context);
    var screenWidth = media.size.width;
    expandedHeight = screenWidth * 9 / 16;
    return expandedHeight;
  }

  /// 旋转为竖屏
  static Future<void> toPortraitUp() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  /// 旋转为横屏
  static Future<void> toLandscape() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeRight]);
    } else {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
  }

  /// 计算文本显示的宽度高度
  static Size? getTextSize({
    required String text,
    required TextStyle style,
    required BuildContext context,
    int maxLines = 1,
  }) {
    TextPainter painter = TextPainter(
      /// AUTO：华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
      locale: Localizations.localeOf(context),
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: '...',
    );
    painter.layout();
    return painter.size;
  }
}
