import 'dart:io';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../flutter_kit_utils.dart';
import 'logger.dart';
import 'permission_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 文件下载进度回调，[ratioStr] 百分比
typedef OnFileDownloadProgress = void Function(
    int count, int total, String ratioStr);

///
/// 文件处理工具类
///
class FileUtils {

  /// 单例
  static FileUtils get instance => _getInstance();
  static FileUtils? _instance;

  FileUtils._internal();

  static FileUtils _getInstance() => _instance ??= FileUtils._internal();

  /// 基于[Dio]实现下载某个文件，会先判断文件是否存在，如果已经存在的话则直接返回文件的绝对路径
  /// [saveFilePath] 文件存放位置，必须是完整的绝对路径（包含文件名），非必传
  /// [cancelToken] 可控制取消下载
  /// [deleteIfExists] 如果存在是否删除？即每次都是重新下载
  Future<String?> download(
    String? url, {
    required BuildContext context,
    required Dio dio,
    String? saveFilePath,
    OnFileDownloadProgress? onProgress,
    ValueChanged<dynamic>? onErr,
    CancelToken? cancelToken,
    VoidCallback? onWillDownloading,
    bool deleteIfExists = false,
  }) async {
    if (url?.isNotEmpty != true) {
      onErr?.call(Exception('下载地址为空，无法下载'));
      return null;
    }
    try {
      // 检查权限
      bool isGrand = await checkStoragePermission(context,showMsg: true);
      if (isGrand != true) {
        onErr?.call(Exception('未授予下载的相关权限，请重试',));
        if (defaultTargetPlatform == TargetPlatform.android) {
          openAppSettings();
        }
        return null;
      }

      // 如果调用方没传文件保存路径过来就获取个临时的路径
      if (saveFilePath?.isNotEmpty != true) {
        // 获取临时的文件完整路径
        final suffix = getSuffix(url) ?? '';
        final fileName = keyToMd5(url!) + suffix;
        saveFilePath = await getTempSavePath(fileName);
      }

      // 如果发生此错误，建议调用方手动传递文件保存地址过来
      if (saveFilePath?.isNotEmpty != true) {
        onErr?.call(Exception('获取文件保存地址失败'));
        return null;
      }

      // 判断文件是否存在，存在则直接返回
      final file = File(saveFilePath!);
      var isExits = await file.exists();
      if (isExits == true) {
        LogUtils.instance.d(
            'FileUtils download fuck the file is exists, path=$saveFilePath  deleteIfExists=$deleteIfExists');
        if (deleteIfExists) {
          await file.delete();
        } else {
          return saveFilePath;
        }
      }

      // 文件不存在 这就开始去下载
      LogUtils.instance
          .d('FileUtils download fuck will downloading file to：$saveFilePath');

      cancelToken ??= CancelToken();

      onWillDownloading?.call();

      // 开始下载
      var response = await dio.downloadUri(
        Uri.parse(url!),
        saveFilePath,
        cancelToken: cancelToken,
        onReceiveProgress: (int received, int total) {
          if (total != -1 && cancelToken?.isCancelled != true) {
            onProgress?.call(
              received,
              total,
              (received / total * 100).toStringAsFixed(0),
            );
          }
        },
      );
      // 如果下载已取消 就退出方法
      if (cancelToken.isCancelled == true) return null;

      // 判断是否下载成功,成功就返回文件的保存地址，否则返回null
      return response.statusCode == 200 ? saveFilePath : null;
    } catch (e, s) {
      bool isCancelErr = e is DioError && CancelToken.isCancel(e);
      if (isCancelErr == true) {
        LogUtils.instance.e("FileUtils download 主动取消下载文件");
        return null;
      }
      LogUtils.instance.e('FileUtils download fuck $e------$s');
      deleteFile(saveFilePath!);
      onErr?.call(e);
      return null;
    }
  }

  /// 取消下载
  void cancelDownload(CancelToken? cancelToken) {
    if (cancelToken?.isCancelled != true) {
      cancelToken?.cancel();
    }
  }

  /// 获取后缀名 [path]可以是网址也可以是文件路径
  String? getSuffix(String? path) {
    if (path?.isNotEmpty != true) return null;
    try {
      return path!.substring(path.lastIndexOf('.'), path.length);
    } catch (e, s) {
      LogUtils.instance.e('FileUtils getSuffix $e  ---  $s');
      return null;
    }
  }

  /// 删除文件
  void deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      bool? isExists = await file.exists();
      if (isExists == true) {
        file.delete();
      }
    } catch (e, s) {
      LogUtils.instance.e('FileUtils deleteFile $e  ---  $s');
    }
  }

  /// 获取临时的文件保存路径
  Future<String> getTempSavePath(String fileName) async {
    var saveDir = await getTemporaryDirectory();
    return path.join(
      saveDir.path,
      fileName.isNotEmpty == true
          ? fileName
          : DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// 检查读写权限
  Future<bool> checkStoragePermission(BuildContext context,{bool showMsg = false}) async {
    // 请求相关权限
    final needPermission = [
      Permission.storage,
    ];

    if(defaultTargetPlatform ==  TargetPlatform.android){
      // 判断是否需要android特殊权限
      final androidDeviceAndroidInfo =
      await DevicesInfoUtils.instance.deviceAndroidInfo;
      bool isAndroid11Up = (androidDeviceAndroidInfo?.version.sdkInt ?? 0) >= 30;
      if (isAndroid11Up) {
        needPermission.add(Permission.manageExternalStorage);
      }
    }

    final permissionResult = await PermissionUtils.instance
        .request(context, needPermission,);

    String? noPermissionStr;
    if (permissionResult != null) {
      permissionResult.forEach((key, value) {
        if (!PermissionUtils.checkStatusCanWork(value)) {
          noPermissionStr = '未允许相关权限，请重试(${key.toString()})';
        }
      });
    }
    if (noPermissionStr?.isNotEmpty == true) {
      if (showMsg) {
        ToastUtils.showText(noPermissionStr);
      }
      return false;
    }
    return true;
  }
}
