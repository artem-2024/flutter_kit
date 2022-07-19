import 'package:flutter/material.dart';
import '../flutter/tabs.dart' as extend;
import '../../flutter_kit.dart';

///
/// 默认的TabBar
///
class DefaultTabBar extends extend.TabBar {
  DefaultTabBar({
    Key? key,
    List<Widget>? tabs,
    List<String>? tabTitles,
    bool isScrollable = false,
    TabController? controller,
    bool showIndicator = true,
    ValueChanged<int>? onTap,
    BoxPainter? indicatorPainter,
    Color? labelColor,
    Color? unselectedLabelColor,
    TextStyle? labelStyle,
    TextStyle? unselectedLabelStyle,
    EdgeInsetsGeometry? labelPadding,
  }) : super(
          key: key,
          tabs: tabs ??
              List.generate(
                tabTitles?.length ?? 0,
                (index) => DefaultTab(
                  text: tabTitles![index],
                ),
              ),
          isScrollable: isScrollable,
          controller: controller,
          labelColor: labelColor,
          unselectedLabelColor: unselectedLabelColor,
          labelStyle: labelStyle,
          labelPadding: labelPadding,
          unselectedLabelStyle: unselectedLabelStyle,
          indicator: showIndicator
              ? DefaultTabDecoration(indicatorPainter: indicatorPainter)
              : null,
          indicatorColor: showIndicator ? null : Colors.transparent,
          onTap: onTap,
        );
}

///
/// 默认的TabBar - Item
///
class DefaultTab extends extend.Tab {
  const DefaultTab({
    Key? key,
    String? text,
  }) : super(
          key: key,
          text: text,
          height: defaultTabBarHeight,
        );
}

/// 默认的TabBar容器，可定于背景色和底部线条
class DefaultTabBarContainer extends StatelessWidget {
  const DefaultTabBarContainer({
    Key? key,
    required this.tabBar,
    this.backgroundColor = Colors.white,
    this.showBottomBorder = true,
    this.bottomBorderColor,
  }) : super(key: key);
  final DefaultTabBar tabBar;
  final Color backgroundColor;
  final bool showBottomBorder;
  final Color? bottomBorderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: showBottomBorder == true
            ? Border(
                bottom: BorderSide(
                  color: bottomBorderColor ?? ColorHelper.colorLine,
                ),
              )
            : null,
      ),
      child: tabBar,
    );
  }
}

/// 当DefaultTabBar用于Sliver系列中
class DefaultTabBarSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  DefaultTabBarSliverPersistentHeaderDelegate({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => defaultTabBarHeight;

  @override
  double get minExtent => defaultTabBarHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

/// 默认tab指示器
class DefaultTabDecoration extends Decoration {
  const DefaultTabDecoration({this.indicatorPainter});

  final BoxPainter? indicatorPainter;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return indicatorPainter ?? DefaultTabIndicatorPainter();
  }
}

/// 默认tab指示器 - 绘制 - 底部线条样式
class DefaultTabIndicatorPainter extends BoxPainter {
  DefaultTabIndicatorPainter({
    this.color = ColorHelper.colorTheme,
    this.width = 28,
  });

  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill;
    final w = width;
    const h = 3.0;
    //构建矩形
    Rect rect = Rect.fromLTWH(
      offset.dx - w / 2 + configuration.size!.width / 2,
      configuration.size!.height - h,
      w,
      h,
    );
    //根据上面的矩形,构建一个圆角矩形
    RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(h / 2));
    canvas.drawRRect(rRect, paint);
  }
}

/// tab指示器 - 绘制 - 圆角矩形包裹样式
class OutlineTabIndicatorPainter extends BoxPainter {
  const OutlineTabIndicatorPainter();

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint();
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    const w = 80.0;
    const h = 26.0;
    Rect rect = Rect.fromLTWH(
      offset.dx - w / 2 + configuration.size!.width / 2,
      (configuration.size!.height - h) / 2,
      w,
      h,
    );
    RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(h / 2));
    canvas.drawRRect(rRect, paint);
  }
}
