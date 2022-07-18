import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kit/flutter_kit.dart';
import 'package:flutter_kit/flutter_kit_platform_interface.dart';
import 'package:flutter_kit/flutter_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterKitPlatform 
    with MockPlatformInterfaceMixin
    implements FlutterKitPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterKitPlatform initialPlatform = FlutterKitPlatform.instance;

  test('$MethodChannelFlutterKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterKit>());
  });

  test('getPlatformVersion', () async {
    MockFlutterKitPlatform fakePlatform = MockFlutterKitPlatform();
    FlutterKitPlatform.instance = fakePlatform;
  
    expect(await FlutterKit.getPlatformVersion(), '42');
  });
}
