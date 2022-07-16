import 'package:flutter/material.dart' hide ExpansionTile;
import 'package:lms_app/config/build_config.dart';
import 'package:lms_app/flutter/expansion_tile.dart' as extend;

///
/// 默认的伸缩控件
///
class DefaultExpansionTile extends StatelessWidget {
  const DefaultExpansionTile({
    Key? key,
    this.title,
    this.titleTextContent,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.collapsedBackgroundColor = ColorHelper.colorLine,
    this.isRoot = true,
    this.onExpansionChanged,
    this.showBorderOnExpansion = true,
    this.expandedCrossAxisAlignment = CrossAxisAlignment.start,
    this.childrenPadding,
    this.titlePadding = const EdgeInsets.only(left: 12),
    this.headPadding = const EdgeInsets.only(top: 8,bottom: 8,right: 12),
    this.initiallyExpanded = false,
  }) : super(key: key);
  final Widget? title;
  final String? titleTextContent;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final Color? collapsedBackgroundColor;
  final ValueChanged<bool>? onExpansionChanged;
  final bool showBorderOnExpansion;

  /// 标题边距
  final EdgeInsetsGeometry titlePadding;
  /// 头部总边距
  final EdgeInsetsGeometry headPadding;
  /// 是否是第一级
  final bool isRoot;
  final CrossAxisAlignment? expandedCrossAxisAlignment;
  final EdgeInsetsGeometry? childrenPadding;
  final bool initiallyExpanded;
  @override
  Widget build(BuildContext context) {
    return extend.ExpansionTile(
      title: title ??
          Text(
            titleTextContent ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: ColorHelper.colorTextBlack1,
              fontWeight: fontWeight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      margin: margin,
      collapsedBackgroundColor: collapsedBackgroundColor,
      isRoot: isRoot,
      onExpansionChanged: onExpansionChanged,
      showBorderOnExpansion: showBorderOnExpansion,
      expandedCrossAxisAlignment: expandedCrossAxisAlignment,
      childrenPadding: childrenPadding,
      titlePadding: titlePadding,
      headPadding: headPadding,
      initiallyExpanded: initiallyExpanded,
      children: children,
    );
  }
}
