import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_kit_method_channel.dart';

abstract class FlutterKitPlatform extends PlatformInterface {
  /// Constructs a FlutterKitPlatform.
  FlutterKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterKitPlatform _instance = MethodChannelFlutterKit();

  /// The default instance of [FlutterKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterKit].
  static FlutterKitPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterKitPlatform] when
  /// they register themselves.
  static set instance(FlutterKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
