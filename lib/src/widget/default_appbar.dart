import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/base_app.dart';
import '../../flutter_kit.dart';

///
/// 头部
///
class DefaultAppBar extends AppBar {
  DefaultAppBar({
    Key? key,
    String? titleText,
    Widget? title,
    List<Widget>? actions,
    Widget? leading,
    double? elevation,
    SystemUiOverlayStyle? systemOverlayStyle,
    Widget? background,
    bool centerTitle = true,
    Color? backgroundColor,
  }) : super(
            key: key,
            centerTitle: centerTitle,
            toolbarHeight: defaultAppBarHeight,
            leading: leading ?? const DefaultLeading(),
            title: title ??
                DefaultTitleWidget(
                  titleContent: titleText,
                ),
            actions: actions,
            elevation: elevation,
            shadowColor: const Color(0xffF4F5F7),
            systemOverlayStyle: systemOverlayStyle,
            flexibleSpace: background,
            backgroundColor: backgroundColor);
}

///
/// 头部 - Sliver系列
///
class DefaultSliverAppBar extends StatelessWidget {
  const DefaultSliverAppBar({
    Key? key,
    this.titleText,
    this.actions,
    this.leading,
    this.elevation,
    this.background,
    this.systemOverlayStyle,
    this.expandedHeight = 211,
    this.backgroundColor,
  }) : super(key: key);
  final String? titleText;
  final List<Widget>? actions;
  final Widget? leading;
  final double? elevation;
  final Widget? background;
  final double? expandedHeight;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      forceElevated: true,
      leading: leading ?? const DefaultSliverLeading(),
      elevation: elevation,
      toolbarHeight: defaultAppBarHeight,
      systemOverlayStyle: systemOverlayStyle,
      // backgroundColor: backgroundColor,
      backgroundColor: MaterialStateColor.resolveWith(
        (Set<MaterialState> states) {
          return states.contains(MaterialState.scrolledUnder)
              ? Colors.white
              : Colors.black;
        },
      ),
      expandedHeight: expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const <StretchMode>[
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        titlePadding: const EdgeInsets.only(
          bottom: kToolbarHeight - defaultAppBarHeight,
          left: 10,
          right: 10,
        ),
        centerTitle: true,
        title: Builder(
          builder: (context) {
            final FlexibleSpaceBarSettings? settings = context
                .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
            return Opacity(
              opacity: settings?.isScrolledUnder == true ? 1 : 0,
              child: DefaultTitleWidget(
                titleContent: titleText,
              ),
            );
          },
        ),
        background: background,
      ),
    );
  }
}

///
/// 默认的返回按钮 - Sliver系列
///
class DefaultSliverLeading extends StatelessWidget {
  const DefaultSliverLeading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        final FlexibleSpaceBarSettings? settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
        return settings?.isScrolledUnder == true
            ? const DefaultLeading()
            : const DefaultLeading(
                // iconAsset: 'assets/images/common/icon_arrow_left_with_bg.png',
                iconSize: Size(28, 28),
              );
      },
    );
  }
}

///
/// 默认的返回按钮
///
class DefaultLeading extends StatelessWidget {
  const DefaultLeading({
    Key? key,
    this.iconSize = const Size(9, 15),
    this.iconColor,
    this.onPopTap,
  }) : super(key: key);
  final Size iconSize;
  final Color? iconColor;
  final VoidCallback? onPopTap;

  @override
  Widget build(BuildContext context) {
    return BackButton(
      color: iconColor,
      onPressed: () {
        if (onPopTap != null) {
          onPopTap!.call();
          return;
        }
        Navigator.of(context).maybePop();
      },
    );
    // return Builder(
    //   builder: (BuildContext context) {
    //     return IconButton(
    //       tooltip: 'back',
    //       icon: DefaultAssetImage(
    //         iconAsset,
    //         width: iconSize.width,
    //         height: iconSize.height,
    //         color: iconColor,
    //       ),
    //       onPressed: () {
    //         if (onPopTap != null) {
    //           onPopTap!.call();
    //           return;
    //         }
    //         Navigator.of(context).maybePop();
    //       },
    //     );
    //   },
    // );
  }
}

///
/// 默认的关闭按钮
///
class DefaultCloseButton extends StatelessWidget {
  const DefaultCloseButton({
    Key? key,
    this.isExitApp = false,
    this.iconColor,
    this.onPressed,
    this.size = 16,
  }) : super(key: key);
  final Color? iconColor;
  final bool isExitApp;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: null,
      icon: Icon(Icons.clear,size: size,color: iconColor,),
      // icon: DefaultAssetImage(
      //   'assets/images/common/icon_close.png',
      //   width: size,
      //   height: size,
      //   color: iconColor,
      // ),
      onPressed: onPressed ??
          () {
            if (isExitApp == true) {
              exitApp();
            } else {
              Navigator.of(context).maybePop();
            }
          },
    );
  }
}

///
/// 默认的标题文本控件
///
class DefaultTitleWidget extends StatelessWidget {
  const DefaultTitleWidget({
    Key? key,
    this.titleContent,
    this.textStyle,
  }) : super(key: key);

  final String? titleContent;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return Text(
          titleContent ?? '',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: textStyle ??
              const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
        );
      },
    );
  }
}
