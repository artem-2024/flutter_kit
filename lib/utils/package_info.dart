import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import 'logger.dart';

///
/// APP包信息工具类
///
class PackageInfoUtils {
  /// app包信息
  PackageInfo? _appPackageInfo;


  /// 单例
  static PackageInfoUtils get instance => _getInstance();
  static PackageInfoUtils? _instance;

  PackageInfoUtils._internal();

  static PackageInfoUtils _getInstance() =>
      _instance ??= PackageInfoUtils._internal();

  /// 获取app buildConfig信息
  Future<PackageInfo> get getPackageInfo async =>
      _appPackageInfo ??= await PackageInfo.fromPlatform();

  /// 获取版本号Code
  Future<String> getVersionCode() async {
    try {
      var packageInfo = await instance.getPackageInfo;
      String versionCode = packageInfo.buildNumber;
      if (Platform.isIOS) {
        versionCode = versionCode.replaceAll('.', '');
      }
      return versionCode;
    } catch (e, s) {
      LogUtils.instance.e('获取版本号失败', e, s);
      return '';
    }
  }
  /// 获取版本号名称
  Future<String> getVersionName() async {
    try {
      var packageInfo = await instance.getPackageInfo;
      return packageInfo.version;
    } catch (e, s) {
      LogUtils.instance.e('获取版本号名称失败', e, s);
      return '';
    }
  }
}
