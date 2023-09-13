import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'logger.dart';

///
/// 设备信息工具类
///
class DevicesInfoUtils {

  /// 单例
  static DevicesInfoUtils get instance => _getInstance();
  static DevicesInfoUtils? _instance;

  DevicesInfoUtils._internal();

  static DevicesInfoUtils _getInstance() =>
      _instance ??= DevicesInfoUtils._internal();

  late final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// 一般一次启动只获取一次
  String? _lastGetDeviceName;
  String? _lastGetSystemVersionStr;

  Future<Map?> get deviceAllInfo async {
    return (await DeviceInfoPlugin().deviceInfo).toMap();
  }
  Future<AndroidDeviceInfo?> get deviceAndroidInfo async {
    return await DeviceInfoPlugin().androidInfo;
  }

  /// 获取系统版本名称，暂只支持android iOS
  Future<String?> get getSystemVersionStr async {
    if (_lastGetSystemVersionStr == null) {
      String? systemVersionStr;
      try{
        if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await _deviceInfoPlugin.androidInfo;
          // eg：androidInfo.version.sdkInt = 27;
          // eg：androidInfo.version.release = '8.1.0'
          systemVersionStr = androidInfo.version.release;
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iOSInfo = await _deviceInfoPlugin.iosInfo;
          // eg：iOSInfo.systemVersion = '15.1'

          systemVersionStr = iOSInfo.systemVersion;
        }
      }catch(e,s){
        LogUtils.instance.e('获取系统版本名称异常', e, s);
      }

      _lastGetSystemVersionStr = systemVersionStr;
    }

    return _lastGetSystemVersionStr;
  }

  /// 获取设备名称，暂只支持android iOS
  Future<String> getDeviceName() async {
    if (_lastGetDeviceName == null) {
      String? deviceName;

      try {
        if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await _deviceInfoPlugin.androidInfo;
          deviceName = androidInfo.model ?? 'android';
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iOSInfo = await _deviceInfoPlugin.iosInfo;
          deviceName = getIPhoneNameByMachine(iOSInfo.utsname.machine) ?? 'iOS';
        }
      } catch (e, s) {
        LogUtils.instance.e('获取设备名称异常', e, s);
      }

      deviceName ??= '未知设备';

      // 拼上系统版本名称
      String? systemVersionStr = await getSystemVersionStr;
      if (systemVersionStr?.isNotEmpty == true) {
        deviceName = '$deviceName($systemVersionStr)';
      }

      _lastGetDeviceName = deviceName;
    }
    return _lastGetDeviceName!;
  }

  /// 获取已知的Iphone名称，未知的会原路返回[machine]工程代号 see https://www.theiphonewiki.com/wiki/Models
  String? getIPhoneNameByMachine(String? machine) {
    if (machine?.isNotEmpty != true) return machine;
    String iPhoneName = machine!;
    if (machine == "iPhone1,1") {
      iPhoneName = "iPhone 2G";
    } else if (machine == "iPhone1,1") {
      iPhoneName = "iPhone 2G";
    } else if (machine == "iPhone1,2") {
      iPhoneName = "iPhone 3G";
    } else if (machine == "iPhone2,1") {
      iPhoneName = "iPhone 3GS";
    } else if (machine == "iPhone3,1") {
      iPhoneName = "iPhone 4";
    } else if (machine == "iPhone3,2") {
      iPhoneName = "iPhone 4";
    } else if (machine == "iPhone3,3") {
      iPhoneName = "iPhone 4";
    } else if (machine == "iPhone4,1") {
      iPhoneName = "iPhone 4s";
    } else if (machine == "iPhone5,1") {
      iPhoneName = "iPhone 5";
    } else if (machine == "iPhone5,2") {
      iPhoneName = "iPhone 5";
    } else if (machine == "iPhone5,3") {
      iPhoneName = "iPhone 5c";
    } else if (machine == "iPhone5,4") {
      iPhoneName = "iPhone 5c";
    } else if (machine == "iPhone6,1") {
      iPhoneName = "iPhone 5s";
    } else if (machine == "iPhone6,2") {
      iPhoneName = "iPhone 5s";
    } else if (machine == "iPhone7,1") {
      iPhoneName = "iPhone 6 Plus";
    } else if (machine == "iPhone7,2") {
      iPhoneName = "iPhone 6";
    } else if (machine == "iPhone8,1") {
      iPhoneName = "iPhone 6s";
    } else if (machine == "iPhone8,2") {
      iPhoneName = "iPhone 6s Plus";
    } else if (machine == "iPhone8,4") {
      iPhoneName = "iPhone SE";
    } else if (machine == "iPhone9,1") {
      iPhoneName = "iPhone 7";
    } else if (machine == "iPhone9,2") {
      iPhoneName = "iPhone 7 Plus";
    } else if (machine == "iPhone10,1") {
      iPhoneName = "iPhone 8";
    } else if (machine == "iPhone10,4") {
      iPhoneName = "iPhone 8";
    } else if (machine == "iPhone10,2") {
      iPhoneName = "iPhone 8 Plus";
    } else if (machine == "iPhone10,5") {
      iPhoneName = "iPhone 8 Plus";
    } else if (machine == "iPhone10,3") {
      iPhoneName = "iPhone X";
    } else if (machine == "iPhone10,6") {
      iPhoneName = "iPhone X";
    } else if (machine == "iPhone11,8") {
      iPhoneName = "iPhone XR";
    } else if (machine == "iPhone11,2") {
      iPhoneName = "iPhone XS";
    } else if (machine == "iPhone11,4") {
      iPhoneName = "iPhone XS Max";
    } else if (machine == "iPhone11,6") {
      iPhoneName = "iPhone XS Max";
    } else if (machine == "iPhone12,1") {
      iPhoneName = "iPhone XS Max";
    } else if (machine == "iPhone12,1") {
      iPhoneName = "iPhone 11";
    } else if (machine == "iPhone12,3") {
      iPhoneName = "iPhone 11 Pro";
    } else if (machine == "iPhone12,5") {
      iPhoneName = "iPhone 11 Pro Max";
    } else if (machine == "iPhone12,8") {
      // iPhoneName = "iPhone SE (2nd generation)";
      iPhoneName = "iPhone SE(2nd)";
    } else if (machine == "iPhone13,1") {
      iPhoneName = "iPhone 12 mini";
    } else if (machine == "iPhone13,2") {
      iPhoneName = "iPhone 12";
    } else if (machine == "iPhone13,3") {
      iPhoneName = "iPhone 12 Pro";
    } else if (machine == "iPhone13,4") {
      iPhoneName = "iPhone 12 Pro Max";
    } else if (machine == "iPhone14,4") {
      iPhoneName = "iPhone 13 mini";
    } else if (machine == "iPhone14,5") {
      iPhoneName = "iPhone 13";
    } else if (machine == "iPhone14,2") {
      iPhoneName = "iPhone 13 Pro";
    } else if (machine == "iPhone14,3") {
      iPhoneName = "iPhone 13 Pro Max";
    } else if (machine == "iPhone14,6") {
      iPhoneName = "iPhone SE(3rd)";
    }
    // 待更新

    else if (machine == "iPad1,1") {
      iPhoneName = "iPad";
    } else if (machine == "iPad2,1") {
      iPhoneName = "iPad 2";
    } else if (machine == "iPad2,2") {
      iPhoneName = "iPad 2";
    } else if (machine == "iPad2,3") {
      iPhoneName = "iPad 2";
    } else if (machine == "iPad2,4") {
      iPhoneName = "iPad 2";
    } else if (machine == "iPad3,1") {
      iPhoneName = "iPad(3rd)";
    } else if (machine == "iPad3,2") {
      iPhoneName = "iPad(3rd)";
    } else if (machine == "iPad3,3") {
      iPhoneName = "iPad(3rd)";
    } else if (machine == "iPad3,4") {
      iPhoneName = "iPad(4th)";
    } else if (machine == "iPad3,5") {
      iPhoneName = "iPad(4th)";
    } else if (machine == "iPad3,6") {
      iPhoneName = "iPad(4th)";
    } else if (machine == "iPad6,11") {
      iPhoneName = "iPad(5th)";
    } else if (machine == "iPad6,12") {
      iPhoneName = "iPad(5th)";
    } else if (machine == "iPad7,5") {
      iPhoneName = "iPad(6th)";
    } else if (machine == "iPad7,6") {
      iPhoneName = "iPad(6th)";
    } else if (machine == "iPad7,11") {
      iPhoneName = "iPad(7th)";
    } else if (machine == "iPad7,12") {
      iPhoneName = "iPad(7th)";
    } else if (machine == "iPad11,6") {
      iPhoneName = "iPad(8th)";
    } else if (machine == "iPad11,7") {
      iPhoneName = "iPad(8th)";
    } else if (machine == "iPa12,1") {
      iPhoneName = "iPad(9th)";
    } else if (machine == "iPad12,2") {
      iPhoneName = "iPad(9th)";
    } else if (machine == "iPad4,1") {
      iPhoneName = "iPad Air";
    } else if (machine == "iPad4,2") {
      iPhoneName = "iPad Air";
    } else if (machine == "iPad4,3") {
      iPhoneName = "iPad Air";
    } else if (machine == "iPad5,3") {
      iPhoneName = "iPad Air 2";
    } else if (machine == "iPad5,4") {
      iPhoneName = "iPad Air 2";
    } else if (machine == "iPad11,3") {
      iPhoneName = "Pad Air(3rd)";
    } else if (machine == "iPad11,4") {
      iPhoneName = "Pad Air(3rd)";
    } else if (machine == "iPad13,1") {
      iPhoneName = "iPad Air(4th)";
    } else if (machine == "iPad13,2") {
      iPhoneName = "iPad Air(4th)";
    } else if (machine == "iPad6,7") {
      iPhoneName = "iPad Pro(12.9-inch)";
    } else if (machine == "iPad6,8") {
      iPhoneName = "iPad Pro(12.9-inch)";
    } else if (machine == "iPad6,3") {
      iPhoneName = "iPad Pro(9.7-inch)";
    } else if (machine == "iPad6,4") {
      iPhoneName = "iPad Pro(9.7-inch)";
    } else if (machine == "iPad7,1") {
      iPhoneName = "iPad Pro(12.9-inch)(2nd)";
    } else if (machine == "iPad7,2") {
      iPhoneName = "iPad Pro(12.9-inch)(2nd)";
    } else if (machine == "iPad7,3") {
      iPhoneName = "iPad Pro(10.5-inch)";
    } else if (machine == "iPad7,4") {
      iPhoneName = "iPad Pro(10.5-inch)";
    } else if (machine == "iPad7,3") {
      iPhoneName = "iPad Pro(10.5-inch)";
    } else if (machine == "iPad7,4") {
      iPhoneName = "iPad Pro(10.5-inch)";
    } else if (machine == "iPad8,1") {
      iPhoneName = "iPad Pro(11-inch)";
    } else if (machine == "iPad8,2") {
      iPhoneName = "iPad Pro(11-inch)";
    } else if (machine == "iPad8,3") {
      iPhoneName = "iPad Pro(11-inch)";
    } else if (machine == "iPad8,4") {
      iPhoneName = "iPad Pro(11-inch)";
    } else if (machine == "iPad8,5") {
      iPhoneName = "iPad Pro(12.9-inch)(3rd)";
    } else if (machine == "iPad8,6") {
      iPhoneName = "iPad Pro(12.9-inch)(3rd)";
    } else if (machine == "iPad8,7") {
      iPhoneName = "iPad Pro(12.9-inch)(3rd)";
    } else if (machine == "iPad8,8") {
      iPhoneName = "iPad Pro(12.9-inch)(3rd)";
    } else if (machine == "iPad8,9") {
      iPhoneName = "iPad Pro(11-inch)(2nd)";
    } else if (machine == "iPad8,10") {
      iPhoneName = "iPad Pro(11-inch)(2nd)";
    } else if (machine == "iPad8,11") {
      // iPhoneName = "iPad Pro (12.9-inch) (4th generation)";
      iPhoneName = "iPad Pro(12.9-inch)(4th)";
    } else if (machine == "iPad8,12") {
      iPhoneName = "iPad Pro(12.9-inch)(4th)";
    } else if (machine == "iPad13,4") {
      iPhoneName = "iPad Pro(11-inch)(3rd)";
    } else if (machine == "iPad13,5") {
      iPhoneName = "iPad Pro(11-inch)(3rd)";
    } else if (machine == "iPad13,6") {
      iPhoneName = "iPad Pro(11-inch)(3rd)";
    } else if (machine == "iPad13,7") {
      // iPhoneName = "iPad Pro (11-inch) (3rd generation)";
      iPhoneName = "iPad Pro(11-inch)(3rd)";
    } else if (machine == "iPad13,8") {
      // iPhoneName = "iPad Pro (11-inch) (3rd generation)";
      iPhoneName = "iPad Pro(11-inch)(3rd)";
    } else if (machine == "iPad13,9") {
      // iPhoneName = "iPad Pro (11-inch) (3rd generation)";
      iPhoneName = "iPad Pro(11-inch)(3rd)";
    } else if (machine == "iPad13,10") {
      iPhoneName = "iPad Pro(11-inch)(3rd)";
    } else if (machine == "iPad13,11") {
      iPhoneName = "iPad Pro(3rd)";
    } else if (machine == "iPad2,5") {
      iPhoneName = "iPad mini";
    } else if (machine == "iPad2,6") {
      iPhoneName = "iPad mini";
    } else if (machine == "iPad2,7") {
      iPhoneName = "iPad mini";
    } else if (machine == "iPad4,4") {
      iPhoneName = "iPad mini 2";
    } else if (machine == "iPad4,5") {
      iPhoneName = "iPad mini 2";
    } else if (machine == "iPad4,6") {
      iPhoneName = "iPad mini 2";
    } else if (machine == "iPad4,7") {
      iPhoneName = "iPad mini 3";
    } else if (machine == "iPad4,8") {
      iPhoneName = "iPad mini 3";
    } else if (machine == "iPad4,9") {
      iPhoneName = "iPad mini 3";
    } else if (machine == "iPad5,1") {
      iPhoneName = "iPad mini 4";
    } else if (machine == "iPad5,2") {
      iPhoneName = "iPad mini 4";
    } else if (machine == "iPad11,1") {
      iPhoneName = "iPad mini(5th)";
    } else if (machine == "iPad11,2") {
      iPhoneName = "iPad mini(5th)";
    } else if (machine == "iPad14,1") {
      iPhoneName = "iPad mini(6th)";
    } else if (machine == "iPod1,1") {
      iPhoneName = "iPod touch";
    } else if (machine == "iPod2,1") {
      iPhoneName = "iPod touch(2nd)";
    } else if (machine == "iPod3,1") {
      iPhoneName = "iPod touch(3rd)";
    } else if (machine == "iPod4,1") {
      iPhoneName = "iPod touch(4th)";
    } else if (machine == "iPod5,1") {
      iPhoneName = "iPod touch(5th)";
    } else if (machine == "iPod7,1") {
      iPhoneName = "iPod touch(6th)";
    } else if (machine == "iPod9,1") {
      iPhoneName = "iPod touch(7th)";
    }
    return iPhoneName;
  }
}
