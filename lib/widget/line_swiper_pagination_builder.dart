import 'dart:async';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

class LineSwiperPaginationBuilder extends SwiperPlugin {
  ///color when current index,if set null , will be Theme.of(context).primaryColor
  final Color? activeColor;

  ///,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color? color;

  ///Size of the dot when activate
  final double activeSize;

  ///Size of the dot
  final double size;

  /// Space between dots
  final double space;

  final Key? key;

  final double normalWidth;

  final double normalHeight;

  final double currentHeight;

  final double currentWidth;

  const LineSwiperPaginationBuilder({
    this.activeColor,
    this.color,
    this.key,
    this.size = 10.0,
    this.activeSize = 10.0,
    this.normalWidth = 3,
    this.normalHeight = 3,
    this.currentHeight = 3,
    this.currentWidth = 12,
    this.space = 3.0,
  });

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    if (config.itemCount > 20) {
      debugPrint(
          "The itemCount is too big, we suggest use FractionPaginationBuilder instead of DotSwiperPaginationBuilder in this sitituation");
    }
    Color? activeColor = this.activeColor;
    Color? color = this.color;

    if (activeColor == null || color == null) {
      ThemeData themeData = Theme.of(context);
      activeColor = this.activeColor ?? themeData.primaryColor;
      color = this.color ?? themeData.scaffoldBackgroundColor;
    }

    if (config.layout == SwiperLayout.DEFAULT) {
      return PageViewIndicator(
        length: config.itemCount,
        pageController: config.pageController!,
        normalWidth: normalWidth,
        normalHeight: normalHeight,
        currentHeight: currentHeight,
        currentWidth: normalWidth,
        normalColor: color,
        currentColor: activeColor,
        padding: space,
        currentDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(currentHeight / 2),
            color: activeColor),
        normalDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(normalHeight / 2),
            color: color),
      );
    }

    List<Widget> list = [];

    int itemCount = config.itemCount;
    int activeIndex = config.activeIndex;

    for (int i = 0; i < itemCount; ++i) {
      bool active = i == activeIndex;
      list.add(Container(
        key: Key("pagination_$i"),
        margin: EdgeInsets.all(space),
        child: ClipOval(
          child: Container(
            color: active ? activeColor : color,
            width: active ? activeSize : size,
            height: active ? activeSize : size,
          ),
        ),
      ));
    }

    if (config.scrollDirection == Axis.vertical) {
      return Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    } else {
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    }
  }
}

class PageViewIndicator extends StatefulWidget {
  ///PageView 子view集合的长度
  final int length;

  ///PageController
  final PageController pageController;

  ///普通颜色
  final Color normalColor;

  ///普通宽度
  final double normalWidth;

  ///普通高度
  final double normalHeight;

  ///普通Decoration
  final Decoration? normalDecoration;

  ///当前颜色
  final Color currentColor;

  ///当前宽度
  final double currentWidth;

  ///当前高度
  final double currentHeight;

  ///当前Decoration
  final Decoration? currentDecoration;

  ///间距
  final double padding;

  const PageViewIndicator({
    Key? key,
    required this.length,
    required this.pageController,
    this.normalColor = Colors.white,
    this.normalWidth = 8,
    this.normalHeight = 8,
    this.normalDecoration,
    this.currentColor = Colors.grey,
    this.currentWidth = 8,
    this.currentHeight = 8,
    this.currentDecoration,
    this.padding = 8,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageState();
  }
}

class _PageState extends State<PageViewIndicator> {
  late final StreamController<double> _streamController;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<double>();
    widget.pageController.addListener(() {
      _streamController.sink.add(widget.pageController.page ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.normalWidth * widget.length +
          widget.padding * (widget.length + 1),
      height: widget.currentHeight,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,

            ///普通圆点用ListView显示
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, position) {
                  return Container(
                    width: widget.normalWidth,
                    height: widget.normalHeight,
                    margin: EdgeInsets.only(left: widget.padding),
                    decoration: widget.normalDecoration ??
                        BoxDecoration(
                            color: widget.normalColor, shape: BoxShape.circle),
                  );
                }),
          ),
          Positioned(
            ///StreamBuilder刷新
            left: 0,
            ///StreamBuilder刷新
            child: StreamBuilder<double>(
                stream: _streamController.stream,
                initialData: 0,
                builder: (context, snapshot) {
                  ///表示当前进度的圆点
                  return Container(
                    width: widget.currentWidth,
                    height: widget.currentHeight,
                    decoration: widget.currentDecoration ??
                        BoxDecoration(
                            color: widget.currentColor, shape: BoxShape.circle),
                    margin: EdgeInsets.only(
                      left: left(snapshot.data ?? 0),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  double left(double page) {
    if (widget.currentWidth > widget.normalWidth) {
      return widget.normalWidth * page +
          widget.padding * page +
          widget.padding -
          (widget.currentWidth - widget.normalWidth) / 2;
    } else {
      return (widget.normalWidth * page + (page + 1) * widget.padding);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }
}
