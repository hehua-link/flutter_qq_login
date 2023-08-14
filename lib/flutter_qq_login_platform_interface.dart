import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_qq_login_method_channel.dart';

abstract class FlutterQqLoginPlatform extends PlatformInterface {
  /// Constructs a FlutterQqLoginPlatform.
  FlutterQqLoginPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterQqLoginPlatform _instance = MethodChannelFlutterQqLogin();

  /// The default instance of [FlutterQqLoginPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterQqLogin].
  static FlutterQqLoginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterQqLoginPlatform] when
  /// they register themselves.
  static set instance(FlutterQqLoginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init(String appId) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<bool> isInstalled() {
    throw UnimplementedError('isInstalled() has not been implemented.');
  }

  Future<String?> login() {
    throw UnimplementedError('login() has not been implemented.');
  }

  Future<String?> getUserInfo(String accessToken, String openid) {
    throw UnimplementedError('getUserInfo() has not been implemented.');
  }
}
