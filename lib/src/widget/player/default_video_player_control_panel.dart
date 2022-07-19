import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock/wakelock.dart';
import '../../../flutter_kit.dart';
import '../../utils/logger.dart';
import '../../utils/screen_utils.dart';
import '../default_appbar.dart';
import '../default_icon_button.dart';
import '../default_loading.dart';
import '../dialog/default_tips_dialog.dart';
import '../image/default_image.dart';
import 'defalut_panel_progress_bar.dart';
import '../../flutter/progress_indicator.dart' as extend;

/// 控制面板手势类型
enum PanelHitBehavior {
  /// 默认，全手势，包括垂直拖动(亮度，音量)、水平拖动（快进快退），点击等，如果上层有拖动效果，将会冲突
  full,

  /// 全手势，但拖动只有垂直拖动， 无水平拖动（快进快退），这里暂时只是给水平拖动回调赋值空实现
  fullVertical,

  /// 只处理点击
  tap,

  /// 无手势，控制面板将会一直显示
  none,
}

/// 播放器操作面板
class DefaultVideoPlayerControlPanel extends StatefulWidget {
  const DefaultVideoPlayerControlPanel({
    Key? key,
    this.title,
    this.currentTime,
    this.duration,
    this.isLive,
    this.onPlayOrPause,
    this.onSeek,
    this.onSliderChanged,
    this.definition,
    this.supportedDefinitions,
    this.onChooseDefinition,
    this.showToggleOrientationBtn = true,
    this.currentRate,
    this.supportedRates,
    this.onChooseRate,
    this.isPlaying = false,
    this.isBuffering = false,
    this.autoWakelock = true,
    this.bottomBarChildWidget,
    this.bottomBarHeight,
    this.panelHitBehavior = PanelHitBehavior.full,
    this.divChildWidget,
  }) : super(key: key);

  /// 标题
  final String? title;

  /// 当前播放点
  final int? currentTime;

  /// 总时长
  final int? duration;

  /// 是否是直播
  final bool? isLive;

  /// 控制 当前如果在播放中就暂停，暂停中就播放
  final VoidCallback? onPlayOrPause;

  /// 控制 切换播放进度
  final ValueChanged<int>? onSeek;

  /// 控制 进度条被滑动
  final ValueChanged<int>? onSliderChanged;

  /// 当前使用的清晰度名称
  final String? definition;

  /// 支持的清晰度列表
  final List<String?>? supportedDefinitions;

  /// 选中某个清晰度 （回传下标）
  final ValueChanged<int>? onChooseDefinition;

  /// 是否显示旋转屏幕的按钮
  final bool showToggleOrientationBtn;

  /// 支持的倍数列表
  final List<String?>? supportedRates;

  /// 当前使用的倍数名称
  final String? currentRate;

  /// 选中某个倍数 （回传下标）
  final ValueChanged<int>? onChooseRate;

  /// 是否加载中
  final bool isBuffering;

  /// 是否播放中
  final bool isPlaying;

  /// 是否自动保存屏幕常亮 default = true
  final bool autoWakelock;

  /// 底部中间区域可自定义控件
  final Widget? bottomBarChildWidget;

  /// 底栏高度
  final double? bottomBarHeight;

  /// 控制面板手势类型
  final PanelHitBehavior panelHitBehavior;

  /// 可自定义Widget
  final Widget? divChildWidget;

  @override
  DefaultVideoPlayerControlPanelState createState() =>
      DefaultVideoPlayerControlPanelState();
}

class DefaultVideoPlayerControlPanelState extends State<DefaultVideoPlayerControlPanel>
    with TickerProviderStateMixin {
  /// 面板动画控制器
  AnimationController? _animationController;

  /// 动画插值
  Animation<double>? _topTween;

  /// 定时关闭蒙版
  Timer? _timer;

  /// 是否是全屏状态
  bool _isFullStatus = false;

  /// 是否显示清晰度选择器蒙层
  late final ValueNotifier<bool> _showDefinitionsOverlay = ValueNotifier(false);

  /// 是否显示倍数选择器蒙层
  late final ValueNotifier<bool> _showRatesOverlay = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    if (widget.autoWakelock) {
      Wakelock.enable();
    }
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    _topTween = Tween(begin: 1.0, end: 0.0).animate(_animationController!);
    _createNavigatorTimer();
  }

  @override
  void dispose() {
    if (widget.autoWakelock) {
      Wakelock.disable();
    }
    _resetBrightness();
    if (_animationController != null) {
      _animationController?.dispose();
      _animationController = null;
    }
    _showDefinitionsOverlay.dispose();
    _showRatesOverlay.dispose();
    _clearNavigatorTimer();
    _currentHorizontalDragPos.dispose();
    _currentVerticalDragValue.dispose();
    _isHorizontalDragNow.dispose();
    _isVerticalDragNow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Stack(
      alignment: Alignment.center,
      children: [
        // 自定义区
        widget.divChildWidget ?? const SizedBox(),

        // 控制区
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTop,
            const Spacer(),
            _buildBottom,
          ],
        ),
        // 加载中
        widget.isBuffering
            ? const SizedBox(
                width: 34,
                height: 34,
                child: DefaultCircularProgressIndicator(),
              )
            : const SizedBox(),
        // 菜单区
        // 播放倍数选择
        widget.isLive == true ? const SizedBox() : _buildRatesOverlay,
        // 清晰度选择
        widget.supportedDefinitions?.isNotEmpty != true
            ? const SizedBox()
            : _buildDefinitionsOverlay,
        // 水平滑动快进或快退
        _buildDragProgressTime,
        // 垂直滑动调节亮度或声音
        _buildDragVolumeAndBrightness,
      ],
    );

    if (widget.panelHitBehavior == PanelHitBehavior.full) {
      body = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        onTap: _panelTap,
        onDoubleTap: () {
          widget.onPlayOrPause?.call();
        },
        child: body,
      );
    } else if (widget.panelHitBehavior == PanelHitBehavior.fullVertical) {
      body = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        onHorizontalDragStart: (_) {},
        onHorizontalDragUpdate: (_) {},
        onHorizontalDragEnd: (_) {},
        onTap: _panelTap,
        onDoubleTap: () {
          widget.onPlayOrPause?.call();
        },
        child: body,
      );
    } else if (widget.panelHitBehavior == PanelHitBehavior.tap) {
      body = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _panelTap,
        child: body,
      );
    }

    // 直播时或其他平台需处理关闭页面时拦截
    if (shouldPopScope) {
      body = WillPopScope(
        onWillPop: () async {
          bool value = await _closePageCallBack(needReturn: true);
          return value;
        },
        child: body,
      );
    }
    return body;
  }

  /// 当面板被点击，执行设计师制定的交互：点击视频区域显示上层的操作功能，再次点击或者5秒后就隐藏掉
  void _panelTap() {
    if (_topTween?.value == 0) {
      showPanel();
    } else {
      hidePanel();
    }

    // _clearNavigatorTimer();
    // if (_topTween?.value == 0) {
    //   _animationController?.reverse();
    //   _createNavigatorTimer();
    // } else {
    //   _animationController?.forward();
    // }

    /*
    以前是这样的：
    // onTapDown: (_) {
        //   if (_topTween?.value == 0) {
        //     _clearNavigatorTimer();
        //     _animationController?.reverse();
        //   }
        // },
        // onTapUp: (_) {
        //   _createNavigatorTimer();
        // },
     */
  }

  /// 显示控制面板
  void showPanel() {
    _clearNavigatorTimer();
    if (_topTween?.value == 0) {
      _animationController?.reverse();
      _createNavigatorTimer();
    }
  }

  /// 隐藏控制面板
  void hidePanel() {
    _clearNavigatorTimer();
    _animationController?.forward();
  }

  /// 判断是否拦截页面关闭（eg：直播时或其他平台需处理关闭页面时拦截）
  bool get shouldPopScope =>
      //widget.showToggleOrientationBtn &&
      (widget.isLive == true || defaultTargetPlatform != TargetPlatform.iOS);

  /// 清晰度选择器
  Widget get _buildDefinitionsOverlay {
    // 关闭该蒙层的方法
    _close() {
      _showDefinitionsOverlay.value = false;
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _showDefinitionsOverlay,
      builder: (_, isShow, __) {
        return _buildOverlay(
          isShow,
          _buildOverlayChildList(
            widget.supportedDefinitions,
            widget.definition,
            onSelect: (chooseIndex) {
              _close();
              widget.onChooseDefinition?.call(chooseIndex);
            },
          ),
          _close,
        );
      },
    );
  }

  /// 倍数选择器
  Widget get _buildRatesOverlay {
    // 关闭该蒙层的方法
    _close() {
      _showRatesOverlay.value = false;
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _showRatesOverlay,
      builder: (_, isShow, __) {
        return _buildOverlay(
          isShow,
          _buildOverlayChildList(
            widget.supportedRates,
            widget.currentRate,
            onSelect: (chooseIndex) {
              _close();
              widget.onChooseRate?.call(chooseIndex);
            },
          ),
          _close,
        );
      },
    );
  }

  /// 蒙层子Widget列表
  Widget _buildOverlayChildList(List<String?>? titleList, String? selectTitle,
      {ValueChanged<int>? onSelect}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: List.generate(
          titleList?.length ?? 0,
          (index) {
            final currentTitle = titleList![index] ?? '';
            final isSelect = currentTitle == selectTitle;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect?.call(index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: isSelect
                    ? BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(22),
                      )
                    : null,
                child: Text(
                  currentTitle,
                  style: TextStyle(
                    fontSize: 18,
                    color: isSelect ? Colors.white : Colors.white60,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 蒙层
  Widget _buildOverlay(bool isShow, Widget? child, VoidCallback? onTap) {
    return isShow == true
        ? Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => onTap?.call(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                ),
                child: child != null
                    ? Center(
                        child: child,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          )
        : const SizedBox();
  }

  /// 底部
  Widget get _buildBottom {
    // 当前是否全屏
    _isFullStatus = ScreenUtils.isLandscape(context);

    // 进度栏
    final panelProgressBar = DefaultPanelProgressBar(
      currentTime: widget.currentTime,
      duration: widget.duration,
      onSeek: widget.onSeek,
      onSliderChanged: widget.onSliderChanged,
    );

    // 进度条是否在暂停按钮上面
    final progressBarAtTop = widget.isLive != true && _isFullStatus;

    Widget body = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 播放或暂停按钮
        DefaultIconButton(
          icon: widget.isPlaying
              ? 'assets/images/common/icon_video_pause_small.png'
              : 'assets/images/common/icon_video_play_small.png',
          onPressed: widget.onPlayOrPause,
        ),
        // 中间区域
        Expanded(
          child: widget.bottomBarChildWidget ??
              (progressBarAtTop ? const SizedBox() : panelProgressBar),
        ),

        // 切换播放倍数
        Offstage(
          offstage: widget.isLive == true || _isFullStatus == false,
          child: IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () => _showRatesOverlay.value = true,
            icon: Text(
              widget.currentRate ?? '',
              style: const TextStyle(
                  fontSize: 14, color: Colors.white, fontWeight: fontWeight),
            ),
          ),
        ),
        // 切换清晰度
        Offstage(
          offstage:
              widget.definition?.isNotEmpty != true || _isFullStatus == false,
          child: IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () => _showDefinitionsOverlay.value = true,
            icon: Text(
              widget.definition ?? '',
              style: const TextStyle(
                  fontSize: 14, color: Colors.white, fontWeight: fontWeight),
            ),
          ),
        ),

        // 全屏/半屏切换按钮
        if (widget.showToggleOrientationBtn)
          DefaultIconButton(
            icon: _isFullStatus == true
                ? 'assets/images/common/icon_video_16_9.png'
                : 'assets/images/common/icon_video_full.png',
            onPressed: _toggleOrientation,
            size: 40,
          ),
      ],
    );

    // 点播或回放 且全屏时 进度条样式不一样
    if (progressBarAtTop) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          panelProgressBar,
          body,
        ],
      );
    }

    return _AnimatedBuilderRow(
      animation: _topTween!,
      alwaysShow: widget.panelHitBehavior == PanelHitBehavior.none,
      // 点播或回放 且全屏时 进度条样式不一样
      height: (_isFullStatus && widget.isLive != true)
          ? 89
          : widget.bottomBarHeight,
      isTop: false,
      child: body,
    );
  }

  /// 头部
  Widget get _buildTop {
    return _AnimatedBuilderRow(
      alwaysShow: widget.panelHitBehavior == PanelHitBehavior.none,
      animation: _topTween!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DefaultLeading(
            iconColor: Colors.white,
            onPopTap: () {
              // 需要拦截时 直接在拦截里面处理退出逻辑
              if (shouldPopScope) {
                _closeSelf();
              } else {
                _closePageCallBack();
              }
            },
          ),
          Text(
            widget.title ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// 关闭页面的方法
  Future<bool> _closePageCallBack({bool needReturn = false}) async {
    // 当前是全屏时 先调整为半屏 而不是直接关闭页面
    bool isDoVerticalOk = false;
    if (_isFullStatus == true) {
      await _toggleOrientation(true);
      if (widget.showToggleOrientationBtn) {
        isDoVerticalOk = true;
      }
    }

    // 处理本身就没有半屏业务的情况
    if (!widget.showToggleOrientationBtn) {
      if (!shouldPopScope) {
        _closeSelf();
      }
      return true;
    }

    // 本身有半屏业务的情况 只会旋转为半屏 不会退出
    if (isDoVerticalOk == true) return false;

    // 将要退出时 判断是否需要处理再次确认的逻辑
    bool? result = true;
    // 直播时退出需二次确认
    if (widget.isLive == true) {
      result = await showDefaultTipsDialog(context,
          contentText: '是否退出该直播间', confirmText: '退出');
    }
    if (!shouldPopScope && result == true) {
      _closeSelf();
    }
    return result == true;
  }

  /// 关闭页面的方法
  void _closeSelf() {
    Navigator.maybePop(context);
  }

  /// 旋转屏幕方向
  Future<void> _toggleOrientation([bool? isReset]) async {
    if (_isFullStatus == true || isReset == true) {
      await ScreenUtils.toPortraitUp();
      _isFullStatus = false;
    } else {
      await ScreenUtils.toLandscape();
      _isFullStatus = true;
    }
  }

  /// 触碰panel面板对应收缩面板动画
  void _createNavigatorTimer() {
    _timer ??= Timer(
      const Duration(seconds: 8),
      () async {
        _animationController?.forward();
      },
    );
  }

  /// 关闭定时器
  void _clearNavigatorTimer() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// 当前手指拖动的起始位置
  double? _currentHorizontalPositionDx;

  /// 当前播放到多少秒 用于在水平滑动时判断是快进还是快退
  int? currentPlaySecondsOnDrag;

  /// 当前用户水平滑动到多少秒  用于快进或快退
  final ValueNotifier<Duration> _currentHorizontalDragPos =
      ValueNotifier(const Duration(seconds: 0));

  /// 当前是否横向拖动
  final ValueNotifier<bool> _isHorizontalDragNow = ValueNotifier(false);

  /// 横向拖动开始
  void _onHorizontalDragStart(details) {
    // 在按下的时候现存一下当前的点的位置
    _currentHorizontalPositionDx = details.globalPosition.dx;
    currentPlaySecondsOnDrag = widget.currentTime ?? 0;
  }

  /// 横向拖动结束 松手的时候，说明就不打架了，所以就各回各家，各找各妈
  void _onHorizontalDragEnd(details) {
    // 这里就给播放器设置更新后的位置，就是时间
    widget.onSeek?.call(_currentHorizontalDragPos.value.inSeconds);
    _isHorizontalDragNow.value = false;
  }

  /// 横向拖动更新
  void _onHorizontalDragUpdate(details) {
    double curDragDx = details.globalPosition.dx;
    // 确定当前是前进或者后退
    int cdx = curDragDx.toInt();
    int pdx = _currentHorizontalPositionDx!.toInt();
    bool isBefore = cdx > pdx;

    int dragRange = 0;
    if ((widget.duration ?? 0) < 360) {
      // // 方法1 最大滑动间隔就2分钟 较精确  + -, 不满足, 左右滑动合法滑动值，> 1
      if (isBefore && cdx - pdx < 1 || !isBefore && pdx - cdx < 1) return;
      dragRange = isBefore
          ? currentPlaySecondsOnDrag! + 1
          : currentPlaySecondsOnDrag! - 1;
    } else {
      // 方法2  按比例滑动间隔大 觉得跟进度条滑动切换进度的功能重复了
      // 计算手指滑动的比例
      int newInterval = pdx - cdx;
      double playerW = MediaQuery.of(context).size.width;
      int curIntervalAbs = newInterval.abs();
      double movePropCheck = (curIntervalAbs / playerW) * 100;
      // 计算进度条的比例
      double durProgCheck = ((widget.duration ?? 1)).toDouble() / 100;
      int checkTransform = (movePropCheck * durProgCheck).toInt();
      dragRange = isBefore
          ? currentPlaySecondsOnDrag! + checkTransform
          : currentPlaySecondsOnDrag! - checkTransform;
    }

    // 是否溢出 最大
    int lastSecond = widget.duration ?? 0;
    if (dragRange >= lastSecond) {
      dragRange = lastSecond;
    }
    // 是否溢出 最小
    if (dragRange <= 0) {
      dragRange = 0;
    }
    _isHorizontalDragNow.value = true;
    // 更新下上一次存的滑动位置
    _currentHorizontalPositionDx = curDragDx;
    // 更新时间
    currentPlaySecondsOnDrag = dragRange.toInt();
    _currentHorizontalDragPos.value =
        Duration(seconds: currentPlaySecondsOnDrag!.toInt());
  }

  /// build 滑动进度时间显示
  Widget get _buildDragProgressTime {
    return ValueListenableBuilder<bool>(
      valueListenable: _isHorizontalDragNow,
      builder: (_, isTouch, __) {
        return isTouch
            ? Container(
                height: 88,
                width: 168,
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 8),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                ),
                child: ValueListenableBuilder<Duration>(
                  valueListenable: _currentHorizontalDragPos,
                  builder: (_, dragPos, __) {
                    bool isLeft = dragPos.inSeconds < (widget.currentTime ?? 0);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DefaultAssetImage(
                          isLeft
                              ? 'assets/images/common/icon_drag_left.png'
                              : 'assets/images/common/icon_drag_right.png',
                          width: 40,
                          height: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_duration2String(dragPos)} / ${_duration2String(Duration(seconds: widget.duration ?? 0))}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            : Container();
      },
    );
  }

  /// 时间数据转成时分秒字符串
  String _duration2String(Duration duration) {
    if (duration.inMilliseconds < 0) return "---";

    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    int inHours = duration.inHours;
    return inHours > 0
        ? "$inHours:$twoDigitMinutes:$twoDigitSeconds"
        : "$twoDigitMinutes:$twoDigitSeconds";
  }

  /// 当前手指拖动的起始垂直位置
  double _currentVerticalPositionDy = 0;

  /// 是否在拖动垂直的左边，用来区分调节音量还是亮度
  bool _isDragVerLeft = false;

  /// 当前用户水平垂直拖动到多少
  final ValueNotifier<double> _currentVerticalDragValue = ValueNotifier(0);

  /// 当前是否垂直拖动
  final ValueNotifier<bool> _isVerticalDragNow = ValueNotifier(false);

  /// build 显示垂直亮度，音量
  Widget get _buildDragVolumeAndBrightness {
    return ValueListenableBuilder<bool>(
        valueListenable: _isVerticalDragNow,
        builder: (_, isTouch, __) {
          // 不显示
          if (!isTouch) return Container();

          return Card(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            child: ValueListenableBuilder<double>(
                valueListenable: _currentVerticalDragValue,
                builder: (_, dragValue, __) {
                  IconData iconData;
                  // 判断当前值范围，显示的图标
                  if (dragValue <= 0) {
                    iconData = !_isDragVerLeft
                        ? Icons.volume_mute
                        : Icons.brightness_low;
                  } else if (dragValue < 0.5) {
                    iconData = !_isDragVerLeft
                        ? Icons.volume_down
                        : Icons.brightness_medium;
                  } else {
                    iconData = !_isDragVerLeft
                        ? Icons.volume_up
                        : Icons.brightness_high;
                  }
                  // 显示，亮度 || 音量
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          iconData,
                          color: Colors.white,
                        ),
                        Container(
                          width: 100,
                          height: 3,
                          margin: const EdgeInsets.only(left: 8),
                          child: extend.LinearProgressIndicator(
                            value: dragValue,
                            backgroundColor: Colors.white54,
                            valueColor: const AlwaysStoppedAnimation(
                                ColorHelper.colorTheme),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          );
        });
  }

  /// 垂直拖动开始
  void _onVerticalDragStart(DragStartDetails details) async {
    double clientW = MediaQuery.of(context).size.width;
    double curTouchPosX = details.globalPosition.dx;

    // 更新位置
    _currentVerticalPositionDy = details.globalPosition.dy;
    // 是否左边
    _isDragVerLeft = (curTouchPosX > (clientW / 2)) ? false : true;

    // 大于 右边 音量 ， 小于 左边 亮度
    if (!_isDragVerLeft) {
      // 音量
      final newValue = await _getCurrentVolume();
      _isVerticalDragNow.value = true;
      _currentVerticalDragValue.value = newValue;
    } else {
      // 亮度
      final newValue = await _getCurrentBrightness();
      _isVerticalDragNow.value = true;
      _currentVerticalDragValue.value = newValue;
    }
  }

  /// 垂直拖动更新
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isVerticalDragNow.value) return;
    double curDragDy = details.globalPosition.dy;
    // 确定当前是前进或者后退
    int cdy = curDragDy.toInt();
    int pdy = _currentVerticalPositionDy.toInt();
    bool isBefore = cdy < pdy;
    // + -, 不满足, 上下滑动合法滑动值，> 3
    if (isBefore && pdy - cdy < 3 || !isBefore && cdy - pdy < 3) return;
    // 区间
    double dragRange = isBefore
        ? _currentVerticalDragValue.value + 0.03
        : _currentVerticalDragValue.value - 0.03;
    // 是否溢出
    if (dragRange > 1) {
      dragRange = 1.0;
    }
    if (dragRange < 0) {
      dragRange = 0.0;
    }
    _currentVerticalPositionDy = curDragDy;
    _isVerticalDragNow.value = true;
    _currentVerticalDragValue.value = dragRange;
    // 音量
    if (!_isDragVerLeft) {
      _setVolume(dragRange);
    }
    // 亮度
    else {
      _setBrightness(dragRange);
    }
  }

  /// 垂直拖动结束
  void _onVerticalDragEnd(DragEndDetails details) {
    _isVerticalDragNow.value = false;
  }

  /// 更新屏幕亮度
  Future<void> _setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e, s) {
      LogUtils.instance.e('更新屏幕亮度发生错误', e, s);
    }
  }

  /// 获取当前屏幕亮度
  Future<double> _getCurrentBrightness() async {
    try {
      return await ScreenBrightness().current;
    } catch (e, s) {
      LogUtils.instance.e('更新屏幕亮度发生错误', e, s);
      return 0;
    }
  }

  /// 还原屏幕亮度
  Future<void> _resetBrightness() async {
    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (e, s) {
      LogUtils.instance.e('还原屏幕亮度发生错误', e, s);
    }
  }

  /// 更新设备音量
  Future<void> _setVolume(double volume) async {
    try {
      VolumeController().setVolume(volume);
    } catch (e, s) {
      LogUtils.instance.e('更新设备音量发生错误', e, s);
    }
    return;
  }

  /// 获取当前设备音量
  Future<double> _getCurrentVolume() async {
    try {
      return await VolumeController().getVolume();
    } catch (e, s) {
      LogUtils.instance.e('获取当前设备音量发生错误', e, s);
      return 0;
    }
  }
}

/// 头部和底部的Row
class _AnimatedBuilderRow extends StatelessWidget {
  const _AnimatedBuilderRow({
    Key? key,
    required this.animation,
    required this.child,
    this.isTop = true,
    this.alwaysShow,
    this.height,
  }) : super(key: key);
  final Animation<double> animation;
  final Widget child;
  final bool isTop;
  final double? height;

  /// 是否一直显示而不是受动画控制
  final bool? alwaysShow;

  @override
  Widget build(BuildContext context) {
    Widget body = Container(
      constraints: BoxConstraints(minHeight: height ?? 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
          end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: child,
    );

    return alwaysShow == true
        ? body
        : AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return SizeTransition(
                sizeFactor: animation,
                child: child,
              );
            },
            child: body,
          );
  }
}
