import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///
/// 描述：用于Provider Widget 封装，
/// 不能用于页面，只能用于Widget，页面的请使用[PageProviderWidget]，
/// 功能：统一处理Provider初始化和销毁
/// 注意：viewModel，child不能为null
///
class ProviderWidget<A extends ChangeNotifier> extends StatefulWidget {
  ///viewModel是必须的
  final A viewModel;

  final Widget child;

  ///model绑定成功回调，通常用来请求数据
  final void Function(A viewModel)? onModelReady;
  final bool autoDispose;

  const ProviderWidget({
    Key? key,
    required this.viewModel,
    required this.child,
    this.onModelReady,
    this.autoDispose= true,
  })  : super(key: key);

  @override
  State createState() => _ProviderWidgetState<A>();
}

class _ProviderWidgetState<A extends ChangeNotifier>
    extends State<ProviderWidget<A>> {
  late A _viewModel;

  @override
  void initState() {
    _viewModel = widget.viewModel;
    widget.onModelReady?.call(_viewModel);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.autoDispose == true) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<A>.value(
      value: _viewModel,
      child: widget.child,
    );
  }
}
