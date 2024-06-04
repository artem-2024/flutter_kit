import 'package:flutter/material.dart';

///
/// 自动释放队列
/// eg : final token = CancelToken();
///     autoDispose(() => token.cancel());
///
mixin AutomaticDisposeMixin<T extends StatefulWidget> on State<T> {
  final Set<VoidCallback> _disposeSet = <VoidCallback>{};

  void autoDispose(VoidCallback callBack) {
    _disposeSet.add(callBack);
  }

  @override
  void dispose() {
    for (var f in _disposeSet) {
      f();
    }
    _disposeSet.clear();
    super.dispose();
  }
}
