import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../image/default_image.dart';
import 'refresh_list_data_source.dart';
import 'refresh_list_view_state.dart';
import 'refresh_list_indicator.dart';
import 'need_evict_network_image_mixin.dart';

typedef BuildListItemCallBack<A> = Widget Function(
    BuildContext context, A data, int index);

///
/// 上下拉刷新-适用于普通列表，Sliver列表，NesSliver列表，瀑布流，Grid表格
/// 下拉刷新使用flutter sdk自带，
/// 加载更多使用第三方插件，文档：https://github.com/fluttercandies/loading_more_list/blob/master/README-ZH.md
///
///
class RefreshList<T> extends StatefulWidget {
  @override
  RefreshListState<T> createState() => RefreshListState<T>();

  const RefreshList({
    Key? key,
    required this.loadDataCallBack,
    required this.buildListItemCallBack,
    this.onDataChangeListener,
    this.pageSize = 15,
    this.headSlivers,
    this.bottomSlivers,
    this.needClearPhotoCache = false,
    this.isSliver = false,
    this.isNes = false,
    this.haveRefresh = true,
    this.loadingMoreBusyingWidget,
    this.fullScreenBusyingWidget,
    this.errorWidget,
    this.fullScreenErrorWidget,
    this.noMoreLoadWidget,
    this.emptyWidget,
    this.scrollController,
    this.physics,
    this.itemExtent,
    this.gridDelegate,
    this.padding = const EdgeInsets.all(0),
    this.shrinkWrap = false,
  }) : super(key: key);

  ///滚动物理效果，默认Always
  final ScrollPhysics? physics;

  ///滚动控制，非必传
  final ScrollController? scrollController;

  ///数据变化的回调
  final OnDataChangeListener? onDataChangeListener;

  ///加载列表数据的回调
  final LoadDataCallBack<List<T>?> loadDataCallBack;

  ///默认一页的数据条数
  final int pageSize;

  ///列表item的构建回调
  final BuildListItemCallBack<T> buildListItemCallBack;

  ///是否用于Sliver系列       default=false
  final bool isSliver;

  ///是否用于NestedScrollView    default=false
  final bool isNes;

  ///是否有下拉刷新     default true
  final bool haveRefresh;

  ///加载更多页的loading控件
  final Widget? loadingMoreBusyingWidget;

  ///加载第一页的loading控件
  final Widget? fullScreenBusyingWidget;

  ///加载更多页失败的控件
  final Widget? errorWidget;

  ///加载第一页失败的控件
  final Widget? fullScreenErrorWidget;

  ///没有更多页的控件
  final Widget? noMoreLoadWidget;

  ///为空页的控件
  final Widget? emptyWidget;

  /// 是否需要清理列表中的图片缓存，default=false，true时需要同时满足以下条件才有效
  /// 数据类本身就是图片路径String 或者 mixin [NeedEvictNetWorkImageMixin]
  final bool needClearPhotoCache;

  ///列表的头部和底部，仅isSliver=true时才有效,且集合中所有widget也必须属于Sliver系列
  final List<Widget>? headSlivers;

  final List<Widget>? bottomSlivers;

  /// 指定item大小
  final double? itemExtent;

  /// 支持表格
  final SliverGridDelegate? gridDelegate;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry padding;

  final bool shrinkWrap;
}

class RefreshListState<T> extends State<RefreshList<T>> {
  /// 数据源
  late RefreshListDataSource<T> _refreshListDataSource;

  /// 列表的加载状态
  late RefreshListViewState _refreshListViewState;

  /// 下拉刷新的State Key
  GlobalKey<RefreshIndicatorState>? _refreshKey;

  /// 滚动控制
  late final _scrollController = widget.scrollController ?? ScrollController();
  @override
  void initState() {
    super.initState();

    if (widget.haveRefresh == true) {
      _refreshKey = GlobalKey();
    }

    _refreshListDataSource = RefreshListDataSource<T>(
      widget.pageSize,
      loadDataCallBack: widget.loadDataCallBack,
      onDataChangeListener: widget.onDataChangeListener,
    );

    _refreshListViewState = RefreshListViewState(
      listSourceRepository: _refreshListDataSource,
      loadingMoreBusyingWidget: widget.loadingMoreBusyingWidget,
      fullScreenBusyingWidget: widget.fullScreenBusyingWidget,
      errorWidget: widget.errorWidget,
      fullScreenErrorWidget: widget.fullScreenErrorWidget,
      noMoreLoadWidget: widget.noMoreLoadWidget,
      emptyWidget: widget.emptyWidget,
      isSliver: widget.isSliver,
      //emptyIconColor: Color(),
      //emptyMsgColor: Color(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (widget.needClearPhotoCache == true) {
      _clearPhotosMemory();
    }
    _refreshListDataSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget loadMoreList = widget.isSliver == true
        ? _buildJustLoadMoreList4Sliver()
        : _buildJustLoadMoreList();

    if (widget.haveRefresh == false) return loadMoreList;

    return RefreshListIndicator(
      refreshKey: _refreshKey,
      onRefresh: () async {
        await _refreshListDataSource.refresh(false);
      },
      isNes: widget.isNes,
      child: loadMoreList,
    );
  }

  ///公开方法：回到顶部
  void goTop() async {
    //需要时请联系我
  }

  ///公开方法：主动刷新，参数为是否显示指示器
  Future refresh(
      {bool showIndicator = false, bool clearBeforeRequest = true}) async {
    if (showIndicator == true) {
      return _refreshKey?.currentState?.show();
    } else {
      return _refreshListDataSource.refresh(clearBeforeRequest);
    }
  }

  ///根据下标删除列表中某个元素
  void deleteItemByIndex({int? index}) {
    if (index == -1 ||
        index == null ||
        _refreshListDataSource.isEmpty ||
        index >= _refreshListDataSource.length) {
      return;
    }
    _refreshListDataSource.removeAt(index);
    if (_refreshListDataSource.isEmpty) {
      _refreshListDataSource.indicatorStatus = IndicatorStatus.empty;
    }
    _refreshListDataSource.setState();
  }

  ///拿到当前列表所有数据
  List<T> getListData() {
    return _refreshListDataSource;
  }
  /// 赋值新数据
  void setNewData(List<T> data,{bool checkEmpty = true}) {
    _refreshListDataSource.clear();
    _refreshListDataSource.addAll(data);
    if (checkEmpty && _refreshListDataSource.isEmpty) {
      _refreshListDataSource.indicatorStatus = IndicatorStatus.empty;
    }
    _refreshListDataSource.setState();
  }

  ScrollPhysics get _defaultPhysics => const AlwaysScrollableScrollPhysics();

  ///普通的加载更多列表
  Widget _buildJustLoadMoreList() {
    return LoadingMoreList<T>(
      ListConfig<T>(
        padding: widget.padding,
        physics: widget.physics ?? _defaultPhysics,
        controller: _scrollController,
        shrinkWrap: widget.shrinkWrap,
        showGlowTrailing: false,
        showGlowLeading: false,
        indicatorBuilder: _refreshListViewState.build,
        itemBuilder: widget.buildListItemCallBack,
        sourceList: _refreshListDataSource,
        gridDelegate: widget.gridDelegate,
        extendedListDelegate: ExtendedListDelegate(
          collectGarbage:
              widget.needClearPhotoCache == true ? _collectGarbage : null,
        ),
        itemExtent: widget.itemExtent,
      ),
    );
  }

  ///Sliver系列的加载更多列表
  Widget _buildJustLoadMoreList4Sliver() {
    var list = LoadingMoreSliverList<T>(
      SliverListConfig<T>(
        padding: widget.padding,
        indicatorBuilder: _refreshListViewState.build,
        itemBuilder: widget.buildListItemCallBack,
        sourceList: _refreshListDataSource,
        gridDelegate: widget.gridDelegate,
        lastChildLayoutType: LastChildLayoutType.foot,
        extendedListDelegate: ExtendedListDelegate(
          collectGarbage:
              widget.needClearPhotoCache == true ? _collectGarbage : null,
        ),
        itemExtent: widget.itemExtent,
      ),
    );

    var slivers = <Widget>[];

    //添加头部，如果有的话
    if (widget.headSlivers != null && widget.headSlivers!.isNotEmpty) {
      slivers.addAll(widget.headSlivers!);
    }
    //添加列表
    slivers.add(list);

    //添加底部
    if (widget.bottomSlivers != null && widget.bottomSlivers!.isNotEmpty) {
      slivers.addAll(widget.bottomSlivers!);
    }

    return LoadingMoreCustomScrollView(
      controller: _scrollController,
      showGlowLeading: false,
      showGlowTrailing: false,
      rebuildCustomScrollView: true,
      physics: widget.physics ?? _defaultPhysics,
      slivers: slivers,
    );
  }

  ///列表不可见部分回调，通常用于清理图片缓存
  void _collectGarbage(List<int> indexes) {
    for (var index in indexes) {
      final item = _refreshListDataSource[index];
      _clearItemMemory(item);
    }
  }

  ///清掉图片缓存 针对列表全部
  void _clearPhotosMemory() async {
    if (_refreshListDataSource.isNotEmpty) {
      for (var item in _refreshListDataSource) {
        _clearItemMemory(item);
      }
    }
  }

  ///清掉图片缓存 针对单个item
  void _clearItemMemory(T item) {
    if (item is NeedEvictNetWorkImageMixin<T>) {
      var urlList = item.getImageUrlList(item);
      evictNetworkImages(urlList);
    }else if(item is String){
      evictNetworkImages([item]);
    }
  }
}
