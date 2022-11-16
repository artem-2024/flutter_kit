import 'dart:async';

import 'package:app_installer/app_installer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/flutter_kit_utils.dart';
import 'package:flutter_kit/src/utils/app_store_util.dart';

import '../../flutter_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 为true时表示不再主动提示更新
const _noTipAgainKey = 'checkUp_noTipAgainKey';

/// 为true时表示apk下载成功且完整，
const _downLoadApkSuccess = 'checkUp_downLoadApkSuccess';

/// 检查版本更新工具类
class CheckUpUtils {
  CheckUpUtils._();

  /// 检查升级，判断是否需要升级 [isManualCall]是否手动调用（eg：设置页面主动点击检查更新就传true）
  static Future<void> checkUp({
    required BuildContext context,
    bool showToastMsg = true,
    bool? isManualCall,
    bool? mustUpgrade,
    String? releaseUrl,
    String? releaseCode,
    required Dio dio,
    String? releaseDesc,
  }) async {
    // 不是手动调用 且 不是强制更新 就判断用户是否选择了不再提示更新
    if (isManualCall != true && mustUpgrade != true) {
      final isNoTipAgain = await StorageUtils.getBool(_noTipAgainKey);
      if (isNoTipAgain == true) {
        LogUtils.instance.i('CheckUpUtils : 用户选择了不再提示更新，退出弹窗提示');
        return;
      }
    }
    // 弹窗
    return showCheckUpDialog(
      context: context,
      isManualCall: isManualCall,
      releaseUrl: releaseUrl,
      releaseCode: releaseCode,
      releaseDesc: releaseDesc,
      mustUpgrade: mustUpgrade == true,
      dio: dio,
    );
  }

  /// 升级弹窗是否显示完成
  static Completer? _showDialogCompleter;

  /// 显示升级弹窗（有升级数据的情况下）
  static void showCheckUpDialog({
    required BuildContext context,
    bool? isManualCall,
    bool? mustUpgrade,
    String? releaseUrl,
    String? releaseCode,
    required Dio dio,
    String? releaseDesc,
  }) async {
    if (_showDialogCompleter == null ||
        _showDialogCompleter?.isCompleted == true) {
      LogUtils.instance.i('显示升级弹窗');
      _showDialogCompleter = Completer();
      try {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return _DefaultUpgradeUI(
              isManualCall: isManualCall,
              releaseUrl: releaseUrl,
              releaseDesc: releaseDesc,
              releaseCode: releaseCode,
              mustUpgrade: mustUpgrade == true,
              dio: dio,
            );
          },
        );
      } catch (e, s) {
        LogUtils.instance.e('显示升级弹窗错误', e, s);
      }
      _showDialogCompleter?.complete();
    }
  }
}

/// 封装了app版本更新逻辑
mixin UploadAppLogicMixin<T extends StatefulWidget> on State<T> {
  /// 可取消下载
  CancelToken? _cancelToken;

  /// 是否下载中
  bool _isDownloading = false;

  /// 当前下载进度
  late final ValueNotifier<int> _progressCountValue = ValueNotifier(0);

  /// 需要下载的总数数
  late final ValueNotifier<int> _progressTotalValue = ValueNotifier(0);

  /// ‘确定‘ 按钮的文字
  late final ValueNotifier<String> _confirmTextStr = ValueNotifier('立即更新');

  /// 是否强制更新
  bool get mustUpgrade;

  /// 更新地址 可能是安装包下载地址 也可能是软件商店地址
  String? get releaseUrl;

  /// 下载用的dio
  Dio get dio;

  /// 最新的版本号
  String? get releaseCode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _progressCountValue.dispose();
    _progressTotalValue.dispose();
    _confirmTextStr.dispose();
    FileUtils.instance.cancelDownload(_cancelToken);
    super.dispose();
  }

  /// 关闭自身
  void _closeSelf() {
    Navigator.pop(context);
  }

  /// 开始升级,ios,android 区分处理
  Future<void> _checkUpNow() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // 去AppStore
      AppStoreUtil.goStore(iOSAppId: FlutterKit.flutterKitConfig.iOSAppId);
      if (mustUpgrade) {
        _closeSelf();
      }
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      if (!_isDownloading) {
        _isDownloading = true;
        _cancelToken = CancelToken();
        final apkSavePath = await _getApkSavePath();
        final downLoadApkSuccess =
            await StorageUtils.getBool(_downLoadApkSuccess);
        final afterSavePath = await FileUtils.instance.download(
          releaseUrl,
          dio: dio,
          context: context,
          saveFilePath: apkSavePath,
          cancelToken: _cancelToken,
          onErr: (msg) {
            ToastUtils.showText(msg);
          },
          deleteIfExists: downLoadApkSuccess != true,
          onProgress: _onDownloadApkProgress,
        );
        _isDownloading = false;
        if (afterSavePath?.isNotEmpty == true) {
          StorageUtils.setBool(_downLoadApkSuccess, true);
          _confirmTextStr.value = '立即安装';
          _installApk(afterSavePath!);
        } else {
          StorageUtils.setBool(_downLoadApkSuccess, false);
        }
      }
    } else {
      ToastUtils.showText('不支持的平台');
    }
  }

  /// android 获取apk保存路径
  Future<String> _getApkSavePath() async {
    var saveDir = await getTemporaryDirectory();
    return path.join(saveDir.path, 'app_v$releaseCode.apk');
  }

  /// android 下载apk进度回调
  void _onDownloadApkProgress(int count, int total, String ratioStr) {
    if (_progressCountValue.value != count) {
      _progressCountValue.value = count;
    }
    if (_progressTotalValue.value != total) {
      _progressTotalValue.value = total;
    }
    _confirmTextStr.value = '当前已下载$ratioStr%';
  }

  /// android 安装apk
  void _installApk(String savePath) {
    LogUtils.instance.d("安装apk savePath = $savePath");
    AppInstaller.installApk(savePath);
  }
}

/// 默认的更新弹窗UI
class _DefaultUpgradeUI extends StatefulWidget {
  const _DefaultUpgradeUI({
    Key? key,
    this.isManualCall,
    required this.mustUpgrade,
    required this.releaseUrl,
    required this.releaseCode,
    this.releaseDesc,
    required this.dio,
  }) : super(key: key);
  final bool? isManualCall;
  final bool mustUpgrade;
  final String? releaseUrl;
  final String? releaseCode;
  final String? releaseDesc;
  final Dio dio;

  @override
  State<_DefaultUpgradeUI> createState() => _DefaultUpgradeUIState();
}

class _DefaultUpgradeUIState extends State<_DefaultUpgradeUI>
    with UploadAppLogicMixin {
  @override
  Dio get dio => widget.dio;

  @override
  bool get mustUpgrade => widget.mustUpgrade;

  @override
  String? get releaseCode => widget.releaseCode;

  @override
  String? get releaseUrl => widget.releaseUrl;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !mustUpgrade;
      },
      child: AlertDialog(
        title: Text('发现新版本，$releaseCode来啦'),
        content: Text(widget.releaseDesc?.trim().isNotEmpty == true
            ? widget.releaseDesc!
            : 'Fixed some bugs'),
        actions: [
          if (!mustUpgrade && widget.isManualCall != true)
            TextButton(
              onPressed: () {
                StorageUtils.setBool(_noTipAgainKey, true);
                _closeSelf();
              },
              child: const Text('不再提示'),
            ),
          if (!mustUpgrade)
            TextButton(
              onPressed: _closeSelf,
              child: const Text('取消'),
            ),
          TextButton(
            onPressed: _checkUpNow,
            child: ValueListenableBuilder<String>(
              valueListenable: _confirmTextStr,
              builder: (_, str, __) {
                return Text(str);
              },
            ),
          ),
        ],
      ),
    );
  }
}
