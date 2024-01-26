import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widget/dialog/default_tips_dialog.dart';

export 'package:permission_handler/permission_handler.dart'
    show Permission, PermissionStatus;

///
/// App权限工具类
///
class PermissionUtils {
  /// 可以当做有权限
  static bool checkStatusCanWork(PermissionStatus? result) {
    return [PermissionStatus.granted, PermissionStatus.limited]
        .contains(result);
  }

  /// 需要跳转到系统设置页面
  static bool checkStatusNeedJumpToSetting(PermissionStatus? result) {
    return [PermissionStatus.restricted, PermissionStatus.permanentlyDenied]
        .contains(result);
  }

  /// 权限描叙映射
  final Map<Permission, String> _permissionDescribe = <Permission, String>{
    Permission.calendar: "开启日历记录日期，用于查看日历记录日期和日历记录日期",
    Permission.camera: "使用本机相机权限",
    Permission.contacts: "获取联系人信息",
    Permission.location: "开启定位权限，用于查看筛选地区内容",
    Permission.locationAlways: "始终允许定位权限",
    Permission.locationWhenInUse: "当正在使用的时候才允许用定位权限",
    Permission.mediaLibrary: "安卓不支持这个权限,对应ios MPMediaLibrary",
    Permission.microphone: "您可在开启麦克风权限后使用上麦功能",
    Permission.phone: "电话权限",
    Permission.photos: "ios访问你的相册权限",
    Permission.photosAddOnly: "ios访问你的相册权限",
    Permission.reminders: "ios提醒事项权限",
    Permission.sensors: "传感器权限",
    Permission.sms: "获取短信信息",
    Permission.speech: "安卓的麦克风权限。ios的语音识别",
    Permission.storage: "读写文件或更换头像需要访问您的存储权限。",
    Permission.manageExternalStorage: "读写文件或更换头像需要访问您的外置存储权限。",
    Permission.ignoreBatteryOptimizations: "安卓关闭省电策略",
    Permission.notification: "通知权限",
    Permission.accessMediaLocation: "安卓10的新权限,一些照片在其数据中会包含位置信息，允许用户查看拍摄照片的位置",
    Permission.activityRecognition: "安卓10的新权限,Activity后台活动限制",
    Permission.bluetooth: "蓝牙权限",
    Permission.systemAlertWindow: "弹窗权限",
    Permission.requestInstallPackages: "安卓请求安装应用权限",
    Permission.appTrackingTransparency: "ios14请求跟踪",
    Permission.criticalAlerts: "ios当app处于静音或者开启勿扰模式后可以收到紧急的通知提醒",
    Permission.accessNotificationPolicy: "安卓设置手机为禁音",
  };

  /// 工厂模式
  factory PermissionUtils() => _getInstance();

  /// 单例
  static PermissionUtils get instance => _getInstance();
  static PermissionUtils? _instance;

  PermissionUtils._internal();

  static PermissionUtils _getInstance() =>
      _instance ??= PermissionUtils._internal();

  /// 打开app系统设置
  Future<bool> get forwardAppSettings => openAppSettings();

  /// 统一集合request
  Future<Map<Permission, PermissionStatus?>?> request(
      BuildContext context, List<Permission> permissionList,
      {bool noTipDialog = false}) async {
    if (permissionList.isEmpty) return null;

    final Map<Permission, PermissionStatus?> permissionResult = {};

    await Future.forEach<Permission>(
      permissionList,
      (e) async {
        permissionResult[e] = await requestOne(e, context,
            noTipDialog: noTipDialog);
      },
    );

    return permissionResult;
  }

  /// 请求单个权限
  Future<PermissionStatus?> requestOne(
      Permission permission, BuildContext context,
      {bool noTipDialog = false}) async {
    final PermissionStatus permissionStatus = await permission.status;
    debugPrint(
        'permission_utils call requestOne permission=$permission permissionStatus=$permissionStatus');
    /*
    允许：granted
    ios严格模式，可能是家长控制：isRestricted
    永久拒绝权限：isPermanentlyDenied
    限制权限：isLimited
     */
    if (!permissionStatus.isDenied) {
      return permissionStatus;
    }

    // 我们还没有请求许可，或者许可以前被拒绝过，但不是永久性的。
    else {
      bool? result = true;
      // android弹窗权限友好提示
      if (Platform.isAndroid && noTipDialog == false) {
        result = await _showPermissionDialog(context, permission);
      }
      // 去申请权限
      if (result == true) {
        final PermissionStatus requestStatus = await permission.request();
        debugPrint(
            'permission_utils call requestOne permission=$permission result = requestStatus=$requestStatus');
        return requestStatus;
      }
      // 取消申请权限
      return null;
    }
  }

  /// 获取权限弹窗
  Future<bool?> _showPermissionDialog(context, Permission permission) async {
    return await showDefaultTipsDialog(
      context,
      barrierDismissible: false,
      title: '权限申请',
      contentText: _permissionDescribe[permission]!,
      confirmText: '允许',
      cancelText: '拒绝',
    );
  }

  /// 没办法调起系统的权限,需要用户手动开启的dialog提示
  Future<bool?> showOpenSettingsDialog(context) async {
    return await showDefaultTipsDialog(
      context,
      barrierDismissible: false,
      contentText: '应用无法获取该权限，如您需要使用请前往应用设置中开启相应权限',
      confirmText: '去设置',
      confirm: () => forwardAppSettings,
    );
  }
}
