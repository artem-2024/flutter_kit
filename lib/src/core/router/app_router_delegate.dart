import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../flutter_kit.dart';
import 'app_router_page.dart';

class AppRouterDelegate extends RouterDelegate<RouteSettings>
    with PopNavigatorRouterDelegateMixin, ChangeNotifier {
  /// 路由的唯一key
  static final GlobalKey<NavigatorState> _stackRouteKey =
      GlobalKey<NavigatorState>();

  /// 获取路由的Context
  static BuildContext? get getRouterContext =>
      _stackRouteKey.currentState?.context;

  /// 路由栈
  final List<Page<dynamic>> _stack = [];

  /// 控件监听对应的路由跳转行为
  final RouteObserver<ModalRoute<void>> _routeObserver =
      RouteObserver<ModalRoute<void>>();

  /// 监听栈的监听者
  late final List<NavigatorObserver> _navigatorObserver = [
    _routeObserver,
  ];

  /// 长度
  int get length => _stack.length;

  /// 判空
  bool isEmpty() => _stack.isEmpty;

  /// 获取路由栈的地址集合
  List<String>? get allPageName =>
      _stack.map<String>((e) => e.name as String).toList();

  /// 直接引用对应的路由代理
  static AppRouterDelegate of() {
    return Router.of(_stackRouteKey.currentContext!).routerDelegate
        as AppRouterDelegate;
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _stackRouteKey;

  @override
  Page<dynamic>? get currentConfiguration =>
      _stack.isNotEmpty ? _stack.last : null;

  /// app设置根会触发
  @override
  Future<void> setNewRoutePath(configuration) async {
    _stack
      ..clear()
      ..add(
        getPage(
          configuration.name!,
          params: configuration.arguments as Map<String, dynamic>?,
        ),
      );
    notifyListeners();
    return SynchronousFuture<void>(null);
  }

  /// 最近一次点击返回键事件，用于安卓点击2次退出app
  // DateTime? _lastPressTime;
  @override
  Future<bool> popRoute() {
    // if (_stack.length > 1) {
    //   return super.popRoute();
    // }
    // if (Platform.isAndroid && _stack.first.name != splashPath) {
    //   if (_lastPressTime == null ||
    //       DateTime.now().difference(_lastPressTime!) >
    //           const Duration(seconds: 1)) {
    //     _lastPressTime = DateTime.now();
    //     // ToastUtils.showText(text: "再按一次退出程序");
    //     return SynchronousFuture<bool>(true);
    //   }
    // }
    return super.popRoute();
  }

  /// 控件监听路由跳转等行为注册方式
  void subscribe(RouteAware routeAware, BuildContext context) =>
      _routeObserver.subscribe(routeAware, ModalRoute.of(context)!);

  /// 控件释放监听路由跳转等行为注册方式
  void unSubscribe(RouteAware routeAware) =>
      _routeObserver.unsubscribe(routeAware);

  /// 跳转页面
  Future<void> push(
    String pageName, {
    Map<String, dynamic>? params,
    RouteStyle routeStyle = RouteStyle.iOS,
    RouteTransitionsBuilder? customTransitionsBuilder,
  }) async {
    if (_stack.isNotEmpty) {
      _stack.add(
        getPage(
          pageName,
          params: params,
          routeStyle: routeStyle,
          customTransitionsBuilder: customTransitionsBuilder,
        ),
      );
      notifyListeners();
    }
    return SynchronousFuture<void>(null);
  }

  /// 后退页面
  Future<bool> pop<T>([T? result]) async {
    return navigatorKey.currentState!.maybePop<T>(result);
  }

  /// 替换当前页面
  Future<void> replace(String pageName, {Map<String, dynamic>? params}) async {
    if (_stack.isNotEmpty) {
      _stack.replaceRange(_stack.length - 1, _stack.length, [
        getPage(pageName, params: params),
      ]);
      notifyListeners();
    }
    return SynchronousFuture<void>(null);
  }

  /// 根据条件关闭页面
  Future<void> popWhere(bool Function(Page<dynamic> element) test) async {
    if (_stack.isNotEmpty) {
      _stack.removeWhere(test);
      notifyListeners();
    }
    return SynchronousFuture<void>(null);
  }

  /// 设置根页面
  Future<void> setRoot(
    String name, {
    Map<String, dynamic>? params,
  }) async {
    setNewRoutePath(RouteSettings(name: name, arguments: params));
    return SynchronousFuture<void>(null);
  }

  /// 后退路由回掉
  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }
    if (_stack.isNotEmpty) {
      _stack.removeLast();
      notifyListeners();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: _navigatorObserver,
      pages: List.of(_stack),
      onPopPage: _onPopPage,
      reportsRouteUpdateToEngine: kIsWeb,
    );
  }

  /// 只留其他首页，其他页面关闭
  Future<void> showRootPageOnly() =>
      popWhere((element) => element.name != rootPath);

}
