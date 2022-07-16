import 'package:flutter/material.dart';

///
/// Image帧动画
///
class FrameAnimationImage extends StatefulWidget {
  final List<String> _assetList;
  final double? width;
  final double? height;
  final bool autoStart;
  final bool autoLoop;
  final int interval;

  const FrameAnimationImage(
    this._assetList, {
    Key? key,
    this.width,
    this.height,
    this.interval = 200,
    this.autoStart = true,
    this.autoLoop = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FrameAnimationImageState();
  }
}

class FrameAnimationImageState extends State<FrameAnimationImage>
    with SingleTickerProviderStateMixin {
  // 动画控制
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    final int imageCount = widget._assetList.length;
    final int maxTime = widget.interval * imageCount;

    // 启动动画controller
    _controller = AnimationController(
        duration: Duration(milliseconds: maxTime), vsync: this);
    if (widget.autoLoop) {
      _controller.addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _controller.forward(from: 0.0); // 完成后重新开始
        }
      });
    }

    _animation =
        Tween<double>(begin: 0, end: imageCount.toDouble()).animate(_controller)
          ..addListener(() {
            setState(() {
              // the state that has changed here is the animation object’s value
            });
          });
    if (widget.autoStart) {
      _controller.forward();
    }
  }

  void start() => _controller.forward();

  void stop() => _controller.stop();

  void reset() => _controller.reset();

  void reStart() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void didUpdateWidget(FrameAnimationImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animValue = _animation.value.floor();
    final length = widget._assetList.length;
    int ix;
    if(animValue >= length-1){
      ix = length -1;
    }else{
      ix = animValue % length;
    }
    List<Widget> images = [];
    // 把所有图片都加载进内容，否则每一帧加载时会卡顿
    for (int i = 0; i < widget._assetList.length; ++i) {
      if (i != ix) {
        images.add(
          Image.asset(
            widget._assetList[i],
            width: 0,
            height: 0,
          ),
        );
      }
    }

    images.add(
      Image.asset(
        widget._assetList[ix],
        width: widget.width,
        height: widget.height,
      ),
    );

    return Stack(alignment: AlignmentDirectional.center, children: images);
  }
}
