import 'package:flutter/material.dart';

import '../../../flutter_kit.dart';

/// 首页组件空数据状态时展示的内容
class ComponentEmptyContainer extends StatelessWidget {
  const ComponentEmptyContainer({
    Key? key,
    this.onTap,
    this.title = '暂无数据',
    this.btnText = '刷新一下',
    this.showBtn = true,
  }) : super(key: key);
  final VoidCallback? onTap;
  final String title;
  final String btnText;

  /// 是否显示按钮
  final bool showBtn;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            const Icon(
              Icons.find_in_page_outlined,
              size: 49,
            ),
            const SizedBox(height: 12),
            Wrap(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                ),
                Offstage(
                  offstage: showBtn != true,
                  child: const Text(
                    '，',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Offstage(
                  offstage: showBtn != true,
                  child: Text(
                    btnText,
                    style:
                        TextStyle(fontSize: 12, color: getColorTheme(context),decoration: TextDecoration.underline,),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
