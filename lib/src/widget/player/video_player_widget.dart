import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import '../default_loading.dart';
import 'video_player_controls.dart';

///
/// 播放器
///
class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({Key? key,required this.videoUrl,this.showVerticalLeading = true,this.valueChanged,}) : super(key: key);
  final String videoUrl;
  final bool showVerticalLeading;
  final ValueChanged<VideoPlayerValue>? valueChanged;
  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {

  VideoPlayerController? videoPlayerController;

  ChewieController? chewieController;
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    videoPlayerController?.addListener(listener);
    chewieController = ChewieController(
      showControlsOnInitialize: true,
      // placeholder: Container(color: Colors.black,child: const Center(child: DefaultCircularProgressIndicator())),
      looping: true,
      autoPlay: true,
      autoInitialize: true,
      videoPlayerController: videoPlayerController!,
      showOptions: false,
      aspectRatio: 16/9,
      customControls: VideoPlayerControls(showVerticalLeading: widget.showVerticalLeading,url: widget.videoUrl,),
      allowedScreenSleep: false,
    );
    // initializePlayerSource();
  }
  @override
  void dispose() {
    Wakelock.disable();
    videoPlayerController?.removeListener(listener);
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  void listener() {
    if (!mounted) return;
    final value = videoPlayerController?.value;
    if (value != null) {
      widget.valueChanged?.call(value);
    }
  }

  // void initializePlayerSource()async{
  //   await videoPlayerController?.initialize();
  //   // await videoPlayerController?.play();
  // }

  /// 暂停播放  [ignoreOnFullScreen]是否忽略全屏的情况，因为该插件的全屏方式的原理是跳转到新页面
  void pause({bool ignoreOnFullScreen = false}){
    if (ignoreOnFullScreen && chewieController?.isFullScreen == true) return;
    if (chewieController?.isPlaying == true) {
      chewieController?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: chewieController!,
    );
  }

}
