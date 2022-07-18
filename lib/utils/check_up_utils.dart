import 'dart:async';

import 'package:app_installer/app_installer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../flutter_kit.dart';
import '../widget/image/default_image.dart';
import '../widget/theme_button.dart';
import 'file_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'logger.dart';
import 'storage.dart';
import 'toast_utils.dart';

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
    ValueChanged<bool>? onShowLoading,
    bool showToastMsg = true,
    bool? isManualCall,
    required bool mustUpgrade,
    required String releaseUrl,
    required int releaseCode,
    String releaseDesc = '体验优化',
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
      mustUpgrade: mustUpgrade,
    );
  }

  /// 跳转到iOS appStore并打开此App
  static void goIOSAppleStore() async {
    AppInstaller.goStore('', iOSAppleID);
  }

  /// 升级弹窗是否显示完成
  static Completer? _showDialogCompleter;

  /// 显示升级弹窗（有升级数据的情况下）
  static void showCheckUpDialog({
    required BuildContext context,
    bool? isManualCall,
    required bool mustUpgrade,
    required String releaseUrl,
    required int releaseCode,
    String releaseDesc = '体验优化',
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
            return Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(0),
              child: _CheckUpDialogChild(
                isManualCall: isManualCall,
                releaseUrl: releaseUrl,
                releaseDesc: releaseDesc,
                releaseCode: releaseCode,
                mustUpgrade: mustUpgrade,
              ),
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

/// 版本升级弹窗内容
class _CheckUpDialogChild extends StatefulWidget {
  const _CheckUpDialogChild({
    Key? key,
    this.isManualCall,
    required this.mustUpgrade,
    required this.releaseUrl,
    required this.releaseCode,
    this.releaseDesc,
  }) : super(key: key);
  final bool? isManualCall;
  final bool mustUpgrade;
  final String releaseUrl;
  final int releaseCode;
  final String? releaseDesc;

  @override
  _CheckUpDialogChildState createState() => _CheckUpDialogChildState();
}

class _CheckUpDialogChildState extends State<_CheckUpDialogChild> {
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
      CheckUpUtils.goIOSAppleStore();
      if (!widget.mustUpgrade) {
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
          widget.releaseUrl,
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
    return path.join(saveDir.path, 'app_v${widget.releaseCode}.apk');
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !widget.mustUpgrade;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: 301,
                    height: 357,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 173 - 72),
                          Text(
                            '发现新版本，${widget.releaseCode}来啦',
                            style: const TextStyle(
                              fontSize: 16,
                              color: ColorHelper.colorTextBlack1,
                              fontWeight: fontWeight,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 更新内容
                          Expanded(
                            child: CupertinoScrollbar(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 12,
                                ),
                                physics: const BouncingScrollPhysics(),
                                child: HtmlWidget(
                                  widget.releaseDesc ?? '',
                                ),
                                /*child: Text(
                                  widget.versionEntity.releaseDesc ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: ColorHelper.colorTextBlack1,
                                  ),
                                ),*/
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ValueListenableBuilder<String>(
                              valueListenable: _confirmTextStr,
                              builder: (_, str, __) {
                                return ThemeButton(
                                  str,
                                  width: double.infinity,
                                  textFontSize: 14,
                                  onTap: _checkUpNow,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 6),
                          Offstage(
                            offstage: widget.mustUpgrade ||
                                widget.isManualCall == true,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ThemeButton(
                                '不再提示',
                                width: double.infinity,
                                decoration: const BoxDecoration(),
                                textColor: ColorHelper.colorTextBlack2,
                                textFontSize: 14,
                                onTap: () {
                                  StorageUtils.setBool(_noTipAgainKey, true);
                                  _closeSelf();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: -72,
                    // left: 0,
                    // right: 0,
                    child: SizedBox(
                      width: 301,
                      height: 173,
                      child: DefaultAssetImage(
                        'assets/images/icon_check_up_bg.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Offstage(
                      offstage: widget.mustUpgrade,
                      child: IconButton(
                        onPressed: _closeSelf,
                        icon: const DefaultAssetImage(
                          'assets/images/icon_clean_gray.png',
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
