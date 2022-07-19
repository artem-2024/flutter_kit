import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppRouterInformationParser extends RouteInformationParser<RouteSettings> {
  /// 浏览器中输入一个新URL，或者在代码设置初始化路由
  /// 转发给RouterDelegate 中  setNewRoutePath() 方法的的参数 configuration
  /// 这里解析路由的时候只是转发了路由信息
  @override
  Future<RouteSettings> parseRouteInformation(
      RouteInformation routeInformation) {
    return SynchronousFuture(RouteSettings(name: routeInformation.location));
  }

  /// 恢复路由信息（也就是上层的configuration）
  /// 参数值 从 RouterDelegate.currentConfiguration 获得
  @override
  RouteInformation restoreRouteInformation(RouteSettings configuration) {
    return RouteInformation(location: configuration.name);
  }
}
