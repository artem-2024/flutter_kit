import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'logger.dart';

///
/// 吐司提示
///
class ToastUtils {
  ToastUtils._();

  static void showText(String? content,{bool needCancelBefore = false}) async {
    if (content?.isNotEmpty != true) return;
    if(needCancelBefore){
      try{
        await Fluttertoast.cancel();
      }catch(e,s){
       LogUtils.instance.e('清空toast错误',e,s);
      }
    }
    Fluttertoast.showToast(
      msg: content!,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black38,
      textColor: Colors.white,
      fontSize: 13.0,
    );
  }

  static void showTextInDebug(String? content) async {
    if(kDebugMode){
      showText(content,needCancelBefore: false);
    }
  }
}
