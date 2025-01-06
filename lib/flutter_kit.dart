import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_kit/src/core/router/app_router_delegate.dart';

import 'flutter_kit_platform_interface.dart';

class FlutterKit {
  FlutterKit._();

  static Future<String?> getPlatformVersion() {
    return FlutterKitPlatform.instance.getPlatformVersion();
  }

  static FlutterKitConfig flutterKitConfig = FlutterKitConfig();
}

typedef GetPageChild = Widget Function(
    String name, Map<String, dynamic>? params);

/// 插件配置
class FlutterKitConfig {
  FlutterKitConfig({
    this.getPageChild,
    this.exitByDoubleTapBackOnAndroid = true,
    this.iOSAppId,
    this.networkErrChild,
    this.imageHeaders,
  });

  final GetPageChild? getPageChild;
  /// iOS AppStore App id
  final String? iOSAppId;

  /// 在Android平台是否通过按两次返回键退出程序， default = true
  final bool exitByDoubleTapBackOnAndroid;

  /// 无网络child
  final Widget? networkErrChild;
  /// 访问图片资源时的请求头
  final Map<String, String>? imageHeaders;

}

ColorScheme getColorScheme([BuildContext? context]) {
  return Theme.of(context ?? AppRouterDelegate.getRouterContext!).colorScheme;
}
Color getColorTheme([BuildContext? context]){
  return getColorScheme(context).primary;
}

const String rootPath = "/";


const defaultTabBarHeight = 40.0;
const defaultLoadingMessage = '加载中';
const FontWeight fontWeight = FontWeight.w500;

/// appBar 高度
const double defaultAppBarHeight = 44;

/// appBar 阴影
const double defaultAppBarElevation = 0.5;

// /// appBar 投影颜色
// const Color defaultAppBarShadowColor = ColorHelper.colorLine;

/// 默认的错误提示
const String errorMessage = '操作异常';

/// 空数据提示
const String emptyDataMessage = '暂无相关数据';

/// 登录失效提示
const String unAuthMessage = '登录已失效,请重新登录';

/// http请求代理，例如localhost:8888
const String httpProxyClientHost = "";

// /// 常用颜色
// class ColorHelper {
//   ColorHelper._();
//
//   static const FontWeight fontWeight = FontWeight.w500;
//   static const Color colorTheme = Color(0xff3572E1);
//   static const Color colorTextTheme = Color(0xff3572E1);
//   static const Color colorTextBlack1 = Color(0xff00182D);
//
//   // 1.5
//   static const Color colorTextBlack1_5 = Color(0xff99A2AB);
//   static const Color colorTextBlack2 = Color(0xffBFC5CA);
//   static const Color colorWarn = Color(0xffF52821);
//   static const Color colorLine = Color(0xffF4F5F7);
//   static const Color colorTextPrice = Color(0xffFF9900);
// }
