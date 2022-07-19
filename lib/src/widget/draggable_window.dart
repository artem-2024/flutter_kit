import 'package:flutter/material.dart';

/// 自定义是否重写offset偏移滑动逻辑
typedef GestureDragUpdateOffsetCallback = Offset? Function(
    Size screenSize, Offset currentOffset, Offset delta);

/// 拖拽窗体
class DraggableWindowWidget extends StatefulWidget {
  /// 控件容器
  final Widget child;

  /// 初始化的偏移量
  final Offset initOffset;

  /// 自定义重写滑动逻辑
  final GestureDragUpdateOffsetCallback? onGestureDragUpdateOffsetCallback;

  const DraggableWindowWidget({
    Key? key,
    required this.child,
    this.initOffset = Offset.zero,
    this.onGestureDragUpdateOffsetCallback,
  }) : super(key: key);

  @override
  _DraggableWindowWidgetState createState() => _DraggableWindowWidgetState();
}

class _DraggableWindowWidgetState extends State<DraggableWindowWidget> {
  late Size _widgetSize;

  /// x轴最大的值,可滑动区域的高度
  late double _maxX, _maxY;

  /// 依赖的offset数据源
  late final ValueNotifier<Offset> _offset =
      ValueNotifier<Offset>(widget.initOffset);

  @override
  void initState() {
    super.initState();
    if (widget.onGestureDragUpdateOffsetCallback == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initScreenInfo());
    }
  }

  /// 初始化需要的屏幕信息参数
  void _initScreenInfo() {
    _widgetSize = context.size!;
    _maxX = MediaQuery.of(context).size.width - _widgetSize.width;

    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final position = renderBox?.localToGlobal(Offset.zero);
    _maxY = MediaQuery.of(context).size.height -
        (position?.dy ?? 0) -
        _widgetSize.height+_offset.value.dy;
  }

  /// 测量位移
  Offset? _calculatePosition(Size size, Offset offset, Offset nextOffset) {
    double dx = 0;
    double dy = 0;

    final double dxValue = offset.dx + nextOffset.dx;
    final double dyValue = offset.dy + nextOffset.dy;

    /// 水平方向判断不能屏幕越界
    /// 如果有设置左边的安全边界 默认为0
    if (dxValue <= 0) {
      dx = 0;
    } else if (dxValue >= _maxX) {
      dx = _maxX;
      if (_offset.value.dx == dx) {
        return null;
      }
    } else {
      dx = dxValue;
    }

    /// 垂直方向偏移量必须存在可视区域,考虑安全边界的问题
    if (dyValue >= _maxY) {
      dy = _maxY;
    } else if (dyValue <= 0) {
      dy = 0;
    } else {
      dy = dyValue;
    }
    return Offset(dx, dy);
  }

  /// 偏移滑动的
  void _onPanUpdate(DragUpdateDetails detail) {
    final Offset? offset = widget.onGestureDragUpdateOffsetCallback != null
        ? widget.onGestureDragUpdateOffsetCallback!
            .call(MediaQuery.of(context).size, _offset.value, detail.delta)
        : _calculatePosition(
            MediaQuery.of(context).size, _offset.value, detail.delta);

    if (offset != null) {
      _offset.value = offset;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      builder: (BuildContext context, Offset offset, Widget? child) {
        return Positioned(left: offset.dx, top: offset.dy, child: child!);
      },
      valueListenable: _offset,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        child: widget.child,
        // onPanEnd: (DragEndDetails details) {
        //   debugPrint('${details.primaryVelocity}');
        // },
      ),
    );
  }
}
