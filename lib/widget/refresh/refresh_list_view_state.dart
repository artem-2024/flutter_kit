import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/config/build_config.dart';
import 'package:lms_app/widget/view_state/empty_data_container.dart';
import 'package:lms_app/widget/view_state/error_data_container.dart';
import 'package:lms_app/widget/view_state/view_state_title.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../default_loading.dart';

/// 自定义列表的加载状态
class RefreshListViewState {
  const RefreshListViewState({
    this.listSourceRepository,
    this.isSliver = false,
    this.loadingMoreBusyingWidget,
    this.fullScreenBusyingWidget,
    this.errorWidget,
    this.fullScreenErrorWidget,
    this.noMoreLoadWidget,
    this.emptyWidget,
  });

  final LoadingMoreBase? listSourceRepository;
  final bool isSliver;
  final Widget? loadingMoreBusyingWidget;
  final Widget? fullScreenBusyingWidget;
  final Widget? errorWidget;
  final Widget? fullScreenErrorWidget;
  final Widget? noMoreLoadWidget;
  final Widget? emptyWidget;

  Widget build(BuildContext context, IndicatorStatus status) {
    Widget widget;
    switch (status) {
      case IndicatorStatus.none:
        widget = Container(height: 0.0);
        break;
      case IndicatorStatus.loadingMoreBusying:
        widget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 5.0),
              height: 15.0,
              width: 15.0,
              child: const DefaultCircularProgressIndicator(),
            ),
            const Text(
              "拼命加载中",
              style: TextStyle(
                fontSize: 14,
                color: ColorHelper.colorTextBlack1,
              ),
            )
          ],
        );
        widget = setBackground(false, widget, 35.0);
        widget = loadingMoreBusyingWidget ?? widget;
        break;
      case IndicatorStatus.fullScreenBusying:
        widget = fullScreenBusyingWidget ?? const DefaultLoading(title: '刷新中');
        if (isSliver) {
          widget = SliverFillRemaining(
            child: widget,
          );
        } else {
          widget = CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                child: widget,
              )
            ],
          );
        }
        break;
      case IndicatorStatus.error:
        widget = const ViewStateTitle(errorMessage);
        widget = setBackground(false, widget, 35.0);
        widget = errorWidget ?? widget;
        widget = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            listSourceRepository?.errorRefresh();
          },
          child: widget,
        );
        break;
      case IndicatorStatus.fullScreenError:
        widget = fullScreenErrorWidget ?? const ErrorDataContainer();
        widget = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            listSourceRepository?.errorRefresh();
          },
          child: widget,
        );
        if (isSliver) {
          widget = SliverFillRemaining(
            child: widget,
          );
        } else {
          widget = CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                child: widget,
              )
            ],
          );
        }
        break;
      case IndicatorStatus.noMoreLoad:
        widget = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 0.5,
                color: const Color(0xffEBEFF2),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              '到底啦',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xffA3ABB8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 0.5,
                color: const Color(0xffEBEFF2),
              ),
            ),
            const SizedBox(width: 16),
          ],
        );
        widget = setBackground(false, widget, 80.0);
        widget = noMoreLoadWidget ?? widget;
        break;
      case IndicatorStatus.empty:
        widget = emptyWidget ?? const EmptyDataContainer();
        widget = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => listSourceRepository?.errorRefresh(),
          child: widget,
        );
        if (isSliver) {
          widget = SliverFillRemaining(
            child: widget,
          );
        } else {
          widget = CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                child: widget,
              )
            ],
          );
        }
        break;
    }
    return widget;
  }

  Widget setBackground(bool full, Widget widget, double height,
      {Color? backgroundColor}) {
    widget = Container(
      width: double.infinity,
      height: height,
//        color: backgroundColor ?? Colors.grey[200],
      alignment: Alignment.center,
      child: widget,
    );
    return widget;
  }
}
