import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'default_appbar.dart';
import 'default_loading.dart';
import 'image/default_image.dart';

///
/// ViewPage 左右滑动方式浏览图片、视频
/// 图片支持手势缩放，下滑退出，双击放大
/// 需要支持视频请联系我
///
class AlbumViewPage extends StatefulWidget {
  ///媒体资源集合
  final List<AlbumBean> albums;

  ///首次展示的下标
  final int initIndex;

  ///是否可以编辑（eg:删除）
  final bool isEditAble;

  ///是否显示标题
  final bool isShowAppBar;

  /// 例如某张图片被用户点了删除，回调要删除的下标
  final ValueChanged<int>? onRemoveCallback;

  /// 是否启用滑动退出 default = true
  final bool useSlideToExit;

  const AlbumViewPage({
    Key? key,
    required this.albums,
    this.initIndex = 0,
    this.isEditAble = true,
    this.isShowAppBar = true,
    this.useSlideToExit = true,
    this.onRemoveCallback,
  }) : super(key: key);

  @override
  State createState() => _AlbumViewPageState();
}

class _AlbumViewPageState extends State<AlbumViewPage>
    with SingleTickerProviderStateMixin {
  ///控制滑动退出
  late final GlobalKey<ExtendedImageSlidePageState> _slidePageKey =
      GlobalKey<ExtendedImageSlidePageState>();

  ///PageView滚动控制
  late ExtendedPageController _pageController;

  ///当前展示的下标
  late int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initIndex;
    _pageController = ExtendedPageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // 图片浏览
    Widget photoView = ExtendedImageGesturePageView.builder(
      onPageChanged: (newIndex) {
        setState(() {
          currentIndex = newIndex;
        });
      },
      itemBuilder: (_, index) => _buildItem(widget.albums[index], index),
      itemCount: widget.albums.length,
      controller: _pageController,
      physics: const ClampingScrollPhysics(),
    );

    // 标题栏
    if (widget.isShowAppBar == true) {
      photoView = Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildAppBar, Expanded(child: photoView)],
      );
    }
    // 主题
    photoView = Material(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: photoView,
    );

    // 是否启动滑动退出
    if (widget.useSlideToExit) {
      //用滑动退出组件包裹
      photoView = ExtendedImageSlidePage(
        key: _slidePageKey,
        slideAxis: SlideAxis.vertical,
        slideType: SlideType.onlyImage,
        resetPageDuration: const Duration(milliseconds: 100),
        slidePageBackgroundHandler: (offset, s) {
          return Color.fromRGBO(0, 0, 0, 1 - offset.dy.abs() / size.height);
        },
        slideEndHandler: (
          Offset offset, {
          ExtendedImageSlidePageState? state,
          ScaleEndDetails? details,
        }) {
          return offset.dy.abs() > 60;
        },
        child: photoView,
      );
    }

    return photoView;
  }

  ///标题栏
  DefaultAppBar get _buildAppBar {
    return DefaultAppBar(
      title: Text(
        '${currentIndex + 1}/${widget.albums.length}',
        style: const TextStyle(color: Colors.black),
      ),
      actions: [
        widget.isEditAble == true
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  var length = widget.albums.length;
                  if (length < 1) {
                    return;
                  }
                  int removeIndex = currentIndex;
                  setState(() {
                    widget.albums.removeAt(removeIndex);
                    if (widget.albums.isEmpty) {
                      currentIndex = 0;
                    }
                  });
                  widget.onRemoveCallback?.call(removeIndex);
                },
              )
            : Container(),
      ],
    );
  }

  ///PageView  Item
  Widget _buildItem(AlbumBean data, int index) {
    if (data.albumDataType == AlbumDataType.imageProvider &&
        data.albumData is ImageProvider) {
      return _buildImageProviderItem(data.albumData, data.albumId, index);
    } else if (data.albumDataType == AlbumDataType.imageFilePath) {
      return _buildImageProviderItem(
          ExtendedFileImageProvider(File(data.albumData)), data.albumId, index);
    } else if (data.albumDataType == AlbumDataType.imagePath) {
      if (data.isLocal == true) {
        return _buildImageProviderItem(
            ExtendedAssetImageProvider(data.albumData), data.albumId, index);
      } else {
        return _buildImageProviderItem(
            ExtendedNetworkImageProvider(data.albumData,
                cache: true, retries: 0, scale: 1.0),
            data.albumId,
            index);
      }
    }
    return Container();
  }

  ///ImageProvider类型的Item
  Widget _buildImageProviderItem(
    ImageProvider imageProvider,
    String? id,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        _slidePageKey.currentState?.popPage();
        Navigator.maybePop(context);
      },
      child: ExtendedImage(
        image: imageProvider,
        //启动滑动退出
        enableSlideOutPage: widget.useSlideToExit,
        //默认/手势/编辑 (none, gesture, editor)
        mode: ExtendedImageMode.gesture,
        //加载状态回调
        loadStateChanged: (value) {
          var loadState = value.extendedImageLoadState;
          if (loadState == LoadState.loading) {
            return Container(
              alignment: Alignment.center,
              color: Colors.transparent,
              child: const DefaultCircularProgressIndicator(),
            );
          } else if (loadState == LoadState.failed) {
            return const DefaultImageFiledWidget();
          }
          return null;
        },
      ),
    );
  }
}

///
/// 资源类型
///
enum AlbumDataType {
  ///直接是ImageProvider （不支持flutterBoost传递）
  imageProvider,

  ///图片asset路径或网络路径
  imagePath,

  ///图片文件路径
  imageFilePath,

  ///视频路径
  videoPath,
}

///
/// 图片或视频的数据类
///
class AlbumBean {
  String? albumId;

  ///数据类型
  AlbumDataType? albumDataType;

  ///数据(可能是String类型的路径，也可能是ImageProvider)
  dynamic albumData;

  ///是否是本地数据
  bool? isLocal;

  ///视频缩略图路径
  String? thumbPath;

  AlbumBean(
      {this.albumId,
      this.albumDataType = AlbumDataType.imagePath,
      this.albumData,
      this.isLocal,
      this.thumbPath});

  AlbumBean.fromJson(Map<String, dynamic> json) {
    albumId = json['albumId'];
    albumDataType = AlbumDataType.values[json['albumDataType'] ?? 0];
    isLocal = json['isLocal'];
    albumData = json['albumData'];
    thumbPath = json['thumbPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['albumId'] = albumId;
    map['isLocal'] = isLocal;
    map['albumDataType'] = albumDataType?.index ?? -1;
    map['albumData'] = albumData?.toString() ?? '';
    map['thumbPath'] = thumbPath;
    return map;
  }
}
