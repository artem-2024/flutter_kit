import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/utils/logger.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'image/default_image.dart';

///
/// 查看图片列表ViewPage，可以缩放查看以及左右翻页
///
class PhotoViewPage extends StatefulWidget {
  /// 弹窗查看
  static void showPhotoViewDialog({
    required BuildContext context,
    required List<String> urlList,
    int initialIndex = 0,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return GestureDetector(
          onTap: () => Navigator.pop(dialogContext),
          child: PhotoViewPage(
            urlList: urlList,
            initialIndex: initialIndex,
          ),
        );
      },
    );
  }

  PhotoViewPage({
    Key? key,
    required this.urlList,
    this.initialIndex = 0,
  })  : pageController = PageController(initialPage: initialIndex),
        super(key: key);
  final List<String> urlList;
  final int initialIndex;
  final PageController pageController;

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhotoViewGallery.builder(
      pageController: widget.pageController,
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: ExtendedNetworkImageProvider(widget.urlList[index]),
          errorBuilder: (_, e, s) {
            LogUtils.instance.e('预览单个图片失败', e, s);
            return const Center(child: DefaultImageFiledWidget());
          },
          maxScale: 4.0,
          minScale: PhotoViewComputedScale.contained,
          initialScale: PhotoViewComputedScale.contained,
          heroAttributes: PhotoViewHeroAttributes(tag: '$index'),
          scaleStateCycle: (PhotoViewScaleState actual) {
            return actual == PhotoViewScaleState.initial
                ? PhotoViewScaleState.covering
                : PhotoViewScaleState.initial;
          },
        );
      },
      itemCount: widget.urlList.length,
      loadingBuilder: (context, event) {
        double? progressValue;
        if ((event?.cumulativeBytesLoaded ?? 0) > 0) {
          progressValue =
              event!.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 0);
        }
        return Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: progressValue,
            ),
          ),
        );
      },
      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
    );
  }
}
