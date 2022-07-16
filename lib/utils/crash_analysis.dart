import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:lms_app/utils/logger.dart';

///
/// 异常数据捕获
///
class CrashAnalysisUtils {
  CrashAnalysisUtils._internal();

  /// 初始化异常上报
  /// CrashAnalysisUtils.init(androidAppId: 'fc9d937d1f',channel: EnvironmentConfig.lmsAppName),
  static Future<void> init({
    String? androidAppId,
    String? iOSAppId,
    String? channel,
  }) async {
    final result = await FlutterBugly.init(
      androidAppId: androidAppId,
      iOSAppId: iOSAppId,
      channel: channel,
      // 不自动检查，手动在首页手动检查一次
      autoCheckUpgrade: false,
    );
    LogUtils.instance.d('初始化异常上报result=$result');
  }

  /// 注册异常
  static void postCatchException(VoidCallback fn) =>
      FlutterBugly.postCatchedException(
        fn,
        onException: (e) {
          LogUtils.instance.e('捕获到异常：$e');
        },
      );

  ///自定义渠道标识 android专用
  static Future<void> setAppChannel(String channel) async {
    await FlutterBugly.setAppChannel(channel);
  }

  /// 设置用户id
  static Future<void> setUserId(String userId) async {
    await FlutterBugly.setUserId(userId);
  }

  /// 设置用户标签,标签ID，可在网站生成
  static Future<void> setUserTag(int tag) async {
    await FlutterBugly.setUserTag(tag);
  }

  /// 设置关键数据，随崩溃信息上报
  static Future<void> putUserData(String key, String value) async {
    await FlutterBugly.putUserData(key: key, value: value);
  }

  /// 销毁
  static void destroy() {
    FlutterBugly.dispose();
  }
}
