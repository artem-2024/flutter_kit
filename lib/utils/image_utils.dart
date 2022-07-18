import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit/utils/permission_utils.dart';
import 'package:image_picker/image_picker.dart';

import '../flutter_kit.dart';

///
/// 图片工具类
///
class ImageUtils {
  /// 单例
  static ImageUtils get instance => _getInstance();
  static ImageUtils? _instance;

  ImageUtils._internal();

  static ImageUtils _getInstance() {
    _instance ??= ImageUtils._internal();
    return _instance!;
  }

  /// 获取一张用户选择的图片
  Future<XFile?> getUserChoosePhoto(BuildContext context) async {
    late final ImagePicker picker = ImagePicker();
    final int? chooseIndex = await showModalBottomSheet(
      enableDrag: false,
      context: context,
      barrierColor: const Color.fromRGBO(52, 52, 52, 0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          bottom: true,
          child: SizedBox(
            height: 151,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(1);
                  },
                  child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text(
                      "拍照",
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorHelper.colorTextBlack1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Container(color: ColorHelper.colorLine, height: 0.5),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(2);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: Colors.white,
                    child: const Text(
                      "从相册选择",
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorHelper.colorTextBlack1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Container(color: ColorHelper.colorLine, height: 0.5),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: Colors.white,
                    child: const Text(
                      "取消",
                      style: TextStyle(
                          fontSize: 14,
                          color: ColorHelper.colorTextBlack2,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    XFile? photo;
    switch (chooseIndex) {
      case 1:
        {
          var permissionResult = await PermissionUtils.instance
              .request(context, [Permission.camera]);
          if (permissionResult == null) {
            return null;
          }
          switch (permissionResult[Permission.camera]) {

            /// 同意了、受限
            case PermissionStatus.granted:
            case PermissionStatus.limited:
              {
                try {
                  photo = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 80);
                } on PlatformException catch (e) {
                  if (e.code == "camera_access_denied") {
                    PermissionUtils.instance.showOpenSettingsDialog(context);
                  }
                }
              }
              break;

            /// 用户永久拒绝，系统拒绝,需要手动开启
            case PermissionStatus.restricted:
            case PermissionStatus.permanentlyDenied:
              await PermissionUtils.instance.showOpenSettingsDialog(context);
              break;
            default:
              return null;
          }
        }
        break;

      case 2:
        {
          List<Permission> permission = [
            defaultTargetPlatform == TargetPlatform.android
                ? Permission.storage
                : Permission.photos,
          ];
          var permissionResult =
              await PermissionUtils.instance.request(context, permission);
          if (permissionResult == null) {
            return null;
          }
          switch (permissionResult[permission.first]) {

            /// 同意了、受限
            case PermissionStatus.granted:
            case PermissionStatus.limited:
              {
                try {
                  photo = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 80);
                } on PlatformException catch (e) {
                  if (e.code == "photo_access_denied") {
                    PermissionUtils.instance.showOpenSettingsDialog(context);
                  }
                }
              }
              break;

            /// 用户永久拒绝，系统拒绝,需要手动开启
            case PermissionStatus.restricted:
            case PermissionStatus.permanentlyDenied:
              await PermissionUtils.instance.showOpenSettingsDialog(context);
              break;
            default:
              return null;
          }
        }
        break;

      default:
        return null;
    }
    return photo;
  }
}
