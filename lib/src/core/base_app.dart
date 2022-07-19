import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../flutter_kit.dart';
import '../utils/default_event_bus.dart';
import '../widget/image/default_image.dart';
import 'router/app_router_delegate.dart';
import 'router/app_router_information_parser.dart';

/// Base App
abstract class BassApp extends StatefulWidget {
  final AppRouterDelegate routerDelegate = AppRouterDelegate();
  final AppRouterInformationParser informationParser =
      AppRouterInformationParser();
  late final PlatformRouteInformationProvider platformRouteInformationProvider =
      PlatformRouteInformationProvider(
    initialRouteInformation: const RouteInformation(location: rootPath),
  );

  BassApp({Key? key}) : super(key: key);
}

/// App's Sate
mixin AppStateMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  ///App内存告警回调
  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    //清理所有网络图片的缓存
    evictAllNetworkImages();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DefaultEventBus.instance.destroy();
    super.dispose();
  }
}

/// 退出app
void exitApp() async {
  exit(0);

  // if (Platform.isAndroid) {
  //  // FIXME 现在会导致确认退出app后第二次启动会闪退，（暂时先放弃退出动画，待之后修复）
  //   await SystemNavigator.pop(animated: true);
  // } else {
  //   exit(0);
  // }
}
