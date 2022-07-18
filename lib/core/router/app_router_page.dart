import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/flutter_kit.dart';
import '../../widget/animation/circle_reaval.dart';

enum RouteStyle {
  /// 安卓风格的跳转页面
  android,

  /// iOS风格的跳转页面
  iOS,

  /// 自定义跳转
  custom,
}

/// 获取路由组
Page<dynamic> getPage(
  String name, {
  Map<String, dynamic>? params,
  RouteStyle routeStyle = kIsWeb ? RouteStyle.custom : RouteStyle.iOS,
  RouteTransitionsBuilder? customTransitionsBuilder,
}) {
  final child = FlutterKit.flutterKitConfig.getPageChild?.call(name, params);

  if (child == null) {
    throw Exception('You need set flutterKitConfig.getPageChild');
  }

  /// 确认一下是否自定义风格还是对应的平台对应的动画
  switch (routeStyle) {

    /// 安卓风格
    case RouteStyle.android:
      return MaterialPage(name: name, child: child, arguments: params);

    /// iOS风格
    case RouteStyle.iOS:
      return CupertinoPage(name: name, child: child, arguments: params);

    /// 自定动画路由
    case RouteStyle.custom:
    default:
      return CustomPage(
        child: child,
        name: name,
        arguments: params,
        transitionsBuilder: customTransitionsBuilder!,
      );
  }
}

/// 自定义Page类
class CustomPage<T> extends Page<T> {
  /// 自定义页面构造器
  const CustomPage({
    required this.child,
    this.transitionsBuilder,
    this.maintainState = true,
    this.fullscreenDialog = false,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  /// Page的内容
  final Widget child;

  /// 动画构建 当style=RouteStyle.custom的情况下时需要传递
  final RouteTransitionsBuilder? transitionsBuilder;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      pageBuilder: (BuildContext _, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          child,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        return transitionsBuilder?.call(
                context, animation, secondaryAnimation, child) ??
            child;
      },
    );
  }
}

/// 类似GooglePlay的转场
get transitionsBuilderGooglePlay => (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return CircleReveal(
        position: Offset(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
        ),
        revealPercent: animation.value,
        child: child,
      );
    };

/// 透明转场 可用于Hero动画
get transitionsBuilderTransparent => (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      );
    };
