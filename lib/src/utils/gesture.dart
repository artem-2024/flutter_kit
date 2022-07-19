import 'dart:async';

import 'package:flutter/foundation.dart';

class GestureUtils {
  GestureUtils._();

  /// 防抖
  /// 在触发事件时，不立即执行目标操作，而是给出一个延迟的时间，在该时间范围内如果再次触发了事件，
  /// 则重置延迟时间，直到延迟时间结束才会执行目标操作。
  static void Function() debounce(VoidCallback func, [int milliseconds = 100]) {
    Timer? debounce;
    return () {
      if (debounce != null && debounce!.isActive) {
        debounce!.cancel();
      }
      debounce = Timer(Duration(milliseconds: milliseconds), func);
    };
  }

  /// 节流
  /// 在触发事件时，立即执行目标操作，同时给出一个延迟的时间，在该时间范围内如果再次触发了事件，
  /// 该次事件会被忽略，直到超过该时间范围后触发事件才会被处理。
  static void Function() throttle(FutureOr<void> Function() func) {
    bool enable = true;
    return () async {
      if (enable == true) {
        enable = false;
        var result = func.call();
        if (result is Future) {
          await result;
        }
        enable = true;
      }
    };
  }
}
