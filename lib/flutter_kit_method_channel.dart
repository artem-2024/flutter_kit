import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_kit_platform_interface.dart';

/// An implementation of [FlutterKitPlatform] that uses method channels.
class MethodChannelFlutterKit extends FlutterKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_kit');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
