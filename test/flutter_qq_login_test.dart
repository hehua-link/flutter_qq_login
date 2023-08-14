import 'package:flutter_qq_login/flutter_qq_login_method_channel.dart';
import 'package:flutter_qq_login/flutter_qq_login_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterQqLoginPlatform with MockPlatformInterfaceMixin implements FlutterQqLoginPlatform {

  @override
  Future<void> init(String appId) => Future.value(null);

  @override
  Future<bool> isInstalled() => Future.value(true);

  @override
  Future<String?> login() => Future.value('{"ret":0}');

  @override
  Future<String?> getUserInfo(String accessToken, String openid) => Future.value('{"ret":0}');
}

void main() {
  final FlutterQqLoginPlatform initialPlatform = FlutterQqLoginPlatform.instance;

  test('$MethodChannelFlutterQqLogin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterQqLogin>());
  });
}
