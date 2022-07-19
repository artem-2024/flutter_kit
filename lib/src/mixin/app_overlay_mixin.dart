import 'package:flutter/material.dart';

///
/// App弹窗，通过Overlay实现
/// 可自定义显示位置
///
mixin AppOverlayMixin {
  ///widget上下文
  BuildContext get widgetContext;

  ///默认弹窗显示的widget
  final Widget _popWidget = const Padding(padding: EdgeInsets.all(0));

  ///可重写get
  Widget get popWidget => _popWidget;

  ///是否可以点击外面取消 default=false
  ///false时点击空白区域的事件将被拦截(不生效)
  ///true时点击空白区域会关闭弹窗
  bool get barrierDismissible => false;

  ///是否自定义显示位置 default=false
  ///false时显示在屏幕正中间
  ///true时可以套一层Positioned自定义显示位置
  bool get isDiyPosition => false;

  ///当前存储的child overlay
  OverlayEntry? _childWidgetOverlay;

  /// 可判断当前是否显示了overlay
  ValueNotifier<bool> isOverlayShowing = ValueNotifier(false);

  ///build child overlay
  OverlayEntry _buildChildWidgetOverlay({Color? backgroundColor}) =>
      _buildOverlay(child: popWidget, backgroundColor: backgroundColor);

  ///销毁方法，清除所有overlay
  void destroyOverlay() {
    _childWidgetOverlay?.remove();
    _childWidgetOverlay = null;
  }

  ///显示overlay
  ///[backgroundColor]底层背景色可控制， 默认black38
  void showOverlay(bool isShow, {Color? backgroundColor}) {
    isOverlayShowing.value = isShow;
    if (isShow == true) {
      if (_childWidgetOverlay != null) {
        destroyOverlay();
      }
      _childWidgetOverlay =
          _buildChildWidgetOverlay(backgroundColor: backgroundColor);
      Overlay.of(widgetContext)?.insert(_childWidgetOverlay!);
    } else {
      destroyOverlay();
    }
  }

  /// 显示overlay 带动画
  /// [backgroundColor]底层背景色可控制， 默认black38
  void showOverlayWithAnim(bool isShow, {Color? backgroundColor}) async {
    if (isShow == true) {
      if (_childWidgetOverlay != null) {
        destroyOverlay();
      }
      var overlayState = Overlay.of(widgetContext);
      if (overlayState == null) return;
      AnimationController showAnimationController = AnimationController(
        vsync: overlayState,
        duration: const Duration(milliseconds: 250),
      );
      AnimationController offsetAnimationController = AnimationController(
        vsync: overlayState,
        duration: const Duration(milliseconds: 350),
      );
      Animation<double> opacityShow =
           Tween(begin: 0.0, end: 1.0).animate(showAnimationController);
      CurvedAnimation offsetCurvedAnimation =  CurvedAnimation(
          parent: offsetAnimationController, curve: const _MyCurve());
      //平移动画
      Animation<double> offsetAnim =
           Tween(begin: 50.0, end: 0.0).animate(offsetCurvedAnimation);
      var animPopWidget = AnimatedBuilder(
        animation: opacityShow,
        child: popWidget,
        builder: (context, childToBuild) {
          return Opacity(
            opacity: opacityShow.value,
            child: AnimatedBuilder(
              animation: offsetAnim,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0, offsetAnim.value),
                  child: childToBuild,
                );
              },
            ),
          );
        },
      );
      _childWidgetOverlay = OverlayEntry(builder: (_) {
        return Positioned.fill(
          child: Material(
            color: backgroundColor ?? Colors.black38,
            child: GestureDetector(
              onTap: () async {
                if (barrierDismissible == true && _childWidgetOverlay != null) {
                  destroyOverlay();
                }
              },
              behavior: HitTestBehavior.translucent,
              child: isDiyPosition == true
                  ? Stack(
                      children: <Widget>[animPopWidget],
                    )
                  : Center(
                      child: animPopWidget,
                    ),
            ),
          ),
        );
      });
      overlayState.insert(_childWidgetOverlay!);
      showAnimationController.forward();
      offsetAnimationController.forward();
    } else {
      destroyOverlay();
    }
  }

  ///返回一个Overlay
  ///暂时用GestureDetector包裹child来屏蔽屏幕事件
  OverlayEntry _buildOverlay({required Widget child, Color? backgroundColor}) {
    return OverlayEntry(builder: (_) {
      return Positioned.fill(
        child: Material(
          color: backgroundColor ?? Colors.black38,
          child: GestureDetector(
            onTap: () {
              if (barrierDismissible == true && _childWidgetOverlay != null) {
                destroyOverlay();
              }
            },
            behavior: HitTestBehavior.translucent,
            child: isDiyPosition == true
                ? Stack(
                    children: <Widget>[child],
                  )
                : Center(
                    child: child,
                  ),
          ),
        ),
      );
    });
  }
}

///
/// 自动获取context、自动处理销毁
///
mixin AutoDestroyOverlayMixin<T extends StatefulWidget>
    on State<T>, AppOverlayMixin {
  @override
  BuildContext get widgetContext => context;

  @override
  void dispose() {
    destroyOverlay();
    isOverlayShowing.dispose();
    super.dispose();
  }
}

class _MyCurve extends Curve {
  const _MyCurve();

  @override
  double transform(double t) {
    t -= 1.0;
    double b = t * t * ((2 + 1) * t + 2) + 1.0;
    return b;
  }
}
