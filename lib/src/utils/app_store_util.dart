import 'package:app_installer/app_installer.dart';

/// 应用商店工具类
class AppStoreUtil {
  /// 去应用商店
  static void goStore({
    String? androidAppId,
    String? iOSAppId,
    bool review = false,
  }) async {
    AppInstaller.goStore(
      androidAppId ?? '',
      iOSAppId ?? '',
      review: review,
    );
  }
}
