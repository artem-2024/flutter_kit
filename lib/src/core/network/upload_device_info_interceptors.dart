import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_kit/src/utils/devices_info.dart';
import 'package:flutter_kit/src/utils/package_info.dart';

/// 上传设备信息的拦截器
class UploadDeviceInfoInterceptors extends InterceptorsWrapper {
  /// 平台名称
  final platform = defaultTargetPlatform.name;

  /// 版本号code
  String? versionCode;

  /// 版本号名称
  String? versionName;

  /// 设备全部信息
  dynamic extraDeviceInfo;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 获取版本名称
    versionName ??= await PackageInfoUtils.instance.getVersionName();
    // 获取版本号
    versionCode ??= await PackageInfoUtils.instance.getVersionCode();
    // 设备全部信息
    extraDeviceInfo ??= (await DevicesInfoUtils.instance.deviceAllInfo);

    // 公共参数
    final params = {
      'platform': platform,
      'versionName': versionName,
      'versionCode': versionCode,
      'extraDeviceInfo': extraDeviceInfo,
    };

    // 设置公共请求头
    options.headers.addAll(params);

    handler.next(options);
  }
}
