import 'package:event_bus/event_bus.dart';

///
/// 用于flutter to flutter的事件总线
///
class DefaultEventBus {

  static DefaultEventBus get instance =>
      _instance ??= DefaultEventBus._internal();
  static DefaultEventBus? _instance;

  DefaultEventBus._internal(){
    _eventBus = EventBus();
  }

  late final EventBus _eventBus;

  /// 监听
  Stream<T> on<T>() {
    return _eventBus.on<T>();
  }

  /// 发送
  void fire(event) {
    _eventBus.fire(event);
  }
  /// 销毁
  void destroy() {
    _eventBus.destroy();
  }
}

/*
 eg：

发送：
DefaultEventBus.instance.fire(XxxEvent());

监听：
var _eventSubscription = DefaultEventBus.instance.on<XxxEvent>().listen((e) async {
      //do something

      });

取消监听：
_eventSubscription?.cancel();

 */
