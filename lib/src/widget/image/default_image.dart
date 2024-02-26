import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/src/widget/default_loading.dart';

import '../../utils/logger.dart';

/// 得到一个图片widget（注意：可能为null）
Widget? getDefaultImage(
  String? imgUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? defaultChild,
}) {
  if (imgUrl?.isNotEmpty != true) {
    return DefaultImageFiledWidget(width: width, height: height, fit: fit);
  }
  if (imgUrl!.startsWith("assets/")) {
    // 资源文件
    return DefaultAssetImage(
      imgUrl,
      width: width,
      height: height,
      fit: fit,
    );
  } else if (imgUrl.startsWith("http")) {
    return getDefaultNetWorkImage(
      imgUrl,
      width: width,
      height: height,
      fit: fit,
      notCompletedWidget: defaultChild,
    );
  }

  return defaultChild;
}

/// 得到一个网络图片widget
Widget getDefaultNetWorkImage(String? imgUrl, {
  double? width,
  double? height,
  BoxShape? shape,
  BorderRadius? borderRadius,
  Widget? loadingWidget,
  Widget? failedWidget,
  Widget? notCompletedWidget,
  BoxFit fit = BoxFit.cover,
  BoxBorder? border,
  bool enableMemoryCache = true,
  //当这个image被销毁的时候是否清理内存缓存
  bool clearMemoryCacheWhenDispose = false,
  Color? color,
  BlendMode? colorBlendMode,
  bool needAppendOSSStyle = true,
  Alignment alignment = Alignment.center,
}) {
  // String requestUrl =
  //     (needAppendOSSStyle ? appendAliOSSStyle(imgUrl) : imgUrl) ?? '';

  Widget imgWidget = ExtendedImage.network(
    imgUrl??'',
    shape: shape,
    width: width,
    fit: fit,
    retries: 0,
    enableMemoryCache: enableMemoryCache,
    // 缓存的是传递过来的url
    imageCacheName: imgUrl,
    // 压缩率
    compressionRatio: 0.9,
    // 最大缓存时间一周
    cacheMaxAge: const Duration(days: 7),
    clearMemoryCacheIfFailed: true,
    height: height,
    // borderRadius: borderRadius,
    // 原始图像将保留,直到新图像完成加载并且不会出现“白色闪烁间隙”.
    gaplessPlayback: true,
    border: border,
    clearMemoryCacheWhenDispose: clearMemoryCacheWhenDispose,
    color: color,
    alignment: alignment,
    colorBlendMode: colorBlendMode,
    loadStateChanged: (value) {
      var loadState = value.extendedImageLoadState;
      // if (loadState == LoadState.loading){
      //   LogUtils.instance.d('请求网络图片地址: para = $imgUrl  requestUrl = $requestUrl');
      // }

      if (notCompletedWidget != null && loadState != LoadState.completed) {
        return notCompletedWidget;
      } else {
        if (loadState == LoadState.loading) {
          return loadingWidget ?? const DefaultImageFiledWidget();
        } else if (loadState == LoadState.failed) {
          return failedWidget ?? const DefaultImageFiledWidget();
        }
      }
      return null;
    },
  );
  if (borderRadius != null) {
    imgWidget = Material(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: imgWidget,
    );
  }
  return imgWidget;
}


/// App默认图片加载错误显示的widget
class DefaultImageFiledWidget extends StatelessWidget {
  const DefaultImageFiledWidget({
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.fill,
  }) : super(key: key);
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: DefaultCircularProgressIndicator(),
      ),
    );
    // return DefaultAssetImage(
    //   imageLoadFiledBundleUrl,
    //   width: width,
    //   height: height,
    //   fit: fit,
    // );
  }
}

/// 使用sdk自带的Asset图片加载
class DefaultAssetImage extends StatelessWidget {
  const DefaultAssetImage(
    this.name, {
    Key? key,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fit,
    this.color,
    this.package,
  }) : super(key: key);

  final String name;
  final double? width;
  final double? height;
  final Alignment alignment;
  final BoxFit? fit;
  final Color? color;
  final String? package;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      name,
      width: width,
      height: height,
      alignment: alignment,
      fit: fit,
      color: color,
      package: package,
      errorBuilder: (_, e, s) {
        LogUtils.instance.e('加载Asset图片失败', e, s);
        return const Text('未知图标');
      },
      gaplessPlayback: true,
    );
  }
}

///
/// 清理指定的网络图片缓存
///
void evictNetworkImages([List<String?>? urlList]) async {
  if (urlList?.isNotEmpty == true) {
    for (var element in urlList!) {
      if(element?.isNotEmpty == true){
        clearMemoryImageCache(element);
      }
    }
  }
}

/// 清理所有网络图片缓存
void evictAllNetworkImages()=>clearMemoryImageCache();

/*/// 图片加载类型
enum _ImageLoadType {
  network,
}*/
/*///
/// 基于[ExtendedImage]图片封装工具类
///
class DefaultImage extends StatelessWidget {
  const DefaultImage.network(
    this.imgUrl, {
    Key? key,
    this.width,
    this.height,
    this.border,
    this.borderRadius,
    this.colorBlendMode,
    this.color,
    this.shape,
    this.loadingBuilder,
    this.errorBuilder,
    this.enableMemoryCache = true,
    this.clearMemoryCacheWhenDispose = false,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
    this.loadingWidget,
    this.failedWidget,
    this.notCompletedWidget,
    this.needAppendOSSStyle = true,
  })  : imageType = _ImageLoadType.network,
        super(key: key);

  final String? imgUrl;
  final double? width;
  final double? height;
  final Alignment alignment;
  final BoxFit fit;
  final Color? color;
  final BoxShape? shape;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final bool enableMemoryCache;

  /// 当这个image被销毁的时候是否清理内存缓存
  final bool clearMemoryCacheWhenDispose;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final BlendMode? colorBlendMode;

  final Widget? loadingWidget;
  final Widget? failedWidget;
  final Widget? notCompletedWidget;
  final _ImageLoadType imageType;
  final bool needAppendOSSStyle;

  @override
  Widget build(BuildContext context) {
    LogUtils.instance.d('DefaultImage build');
    switch (imageType) {
      case _ImageLoadType.network:
      default:
        String requestUrl =
            (needAppendOSSStyle ? appendAliOSSStyle(imgUrl) : imgUrl) ?? '';
        // LogUtils.instance.d('请求网络图片地址: para = $imgUrl  requestUrl = $requestUrl');

        return ExtendedImage.network(
          requestUrl,
          key: key,
          shape: shape,
          width: width,
          fit: fit,
          retries: 0,
          enableMemoryCache: enableMemoryCache,
          clearMemoryCacheIfFailed: true,
          height: height,
          borderRadius: borderRadius,
          border: border,
          clearMemoryCacheWhenDispose: clearMemoryCacheWhenDispose,
          color: color,
          colorBlendMode: colorBlendMode,
          loadStateChanged: (value) {
            var loadState = value.extendedImageLoadState;
            if (loadState == LoadState.loading){
              LogUtils.instance.d('请求网络图片地址: para = $imgUrl  requestUrl = $requestUrl');
            }
            if (notCompletedWidget != null &&
                loadState != LoadState.completed) {
              return notCompletedWidget;
            } else {
              if (loadState == LoadState.loading) {
                return loadingWidget ?? const DefaultImageFiledWidget();
              } else if (loadState == LoadState.failed) {
                return failedWidget ?? const DefaultImageFiledWidget();
              }
            }
            return null;
          },
        );
    }
  }
}*/
