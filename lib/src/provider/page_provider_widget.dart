import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flutter_kit.dart';
import '../mixin/after_layout_mixin.dart';
import '../utils/gesture.dart';
import '../widget/view_state/empty_data_container.dart';
import '../widget/view_state/error_data_container.dart';
import '../widget/view_state/loading_data_container.dart';
import 'view_state_model.dart';

///
/// 描述：用于Page中的 Provider Widget 封装
/// 功能：统一处理页面级别的Provider初始化和页面状态监听（如加载中、空数据、异常等不同的展示）
/// 注意：idleChild、viewModel不能为null
///
class PageProviderWidget<A extends ViewStateModel> extends StatefulWidget {
  ///viewModel是必须的
  final A viewModel;

  ///各种状态的子widget see [ViewState]
  final Widget idleChild;
  final Widget? emptyChild;
  final Widget? busyChild;
  final Widget? errChild;
  final Widget? networkErrChild;

  ///model绑定成功回调，通常用来请求数据
  final void Function(A viewModel)? onModelReady;
  final bool autoDispose;

  /// 是否显示头部
  final bool showHeader;

  /// 空数据提示文字
  final String emptyMessage;

  /// 是否用于Sliver系列，为true时会把除idle状态的其他状态widget用Sliver组件包裹
  final bool isSliver;

  const PageProviderWidget({
    Key? key,
    required this.viewModel,
    required this.idleChild,
    this.emptyChild,
    this.busyChild,
    this.errChild,
    this.networkErrChild,
    this.onModelReady,
    this.autoDispose = true,
    this.showHeader = false,
    this.emptyMessage = emptyDataMessage,
    this.isSliver = false,
  }) : super(key: key);

  @override
  State createState() => _PageProviderWidgetState<A>();
}

class _PageProviderWidgetState<A extends ViewStateModel>
    extends State<PageProviderWidget<A>> with AfterLayoutMixin {
  late A _viewModel;

  @override
  void initState() {
    _viewModel = widget.viewModel;
    super.initState();
  }

  @override
  void afterFirstLayoutBuild(BuildContext context) {
    widget.onModelReady?.call(_viewModel);
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
    //监听页面状态
    final selector = Selector<A, ViewState>(
      selector: (_, viewModel) => viewModel.viewState,
      builder: (_, viewState, child) => _getChild(viewState),
    );

    return ChangeNotifierProvider<A>.value(
      value: _viewModel,
      child: selector,
    );
  }

  ///返回最终显示的Child
  Widget _getChild(ViewState viewState) {
    switch (viewState) {
      case ViewState.busy:
        Widget busyChild = widget.busyChild ??
            LoadingDataContainer(
              showHeader: widget.showHeader,
            );
        if (widget.isSliver) {
          busyChild = setSliverContainer(busyChild);
        }

        return busyChild;
      case ViewState.empty:
        Widget emptyWidget = widget.emptyChild ??
            GestureDetector(
              onTap: GestureUtils.throttle(
                  () => widget.onModelReady?.call(_viewModel)),
              behavior: HitTestBehavior.translucent,
              child: EmptyDataContainer(
                showHeader: widget.showHeader,
                title: widget.emptyMessage,
              ),
            );
        if (widget.isSliver) {
          emptyWidget = setSliverContainer(emptyWidget);
        }

        return emptyWidget;
      case ViewState.error:
        {
          Widget errorWidget;
          // 登录过期异常返回未授权的widget
          var error = _viewModel.viewStateError;

          if (error?.isNetworkTimeOut == true) {
            errorWidget = widget.networkErrChild ??
                ErrorDataContainer(
                  showHeader: widget.showHeader,
                  title: '未能连接到互联网，检查是否没有打开网络或者禁止本应用联网',
                  onRefresh: () => widget.onModelReady?.call(_viewModel),
                );
          } else {
            errorWidget = widget.errChild ??
                ErrorDataContainer(
                  showHeader: widget.showHeader,
                  title: error?.errorMessage,
                  onRefresh: () => widget.onModelReady?.call(_viewModel),
                );
          }

          if (widget.isSliver) {
            errorWidget = setSliverContainer(errorWidget);
          }

          return errorWidget;
        }
      case ViewState.idle:
      default:
        return widget.idleChild;
    }
  }

  /// 处理Sliver包裹
  Widget setSliverContainer(Widget child) {
    child = SliverToBoxAdapter(
      child: SizedBox(
        height: 150,
        child: child,
      ),
    );
    return child;
  }
}
