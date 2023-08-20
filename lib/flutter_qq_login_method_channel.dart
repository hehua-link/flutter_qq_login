import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_qq_login_platform_interface.dart';

/// An implementation of [FlutterQqLoginPlatform] that uses method channels.
class MethodChannelFlutterQqLogin extends FlutterQqLoginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_qq_login');

  @override
  Future<void> init(String appId) async {
    await methodChannel.invokeMethod<String>('init', {'appId': appId});
  }

  @override
  Future<bool> isInstalled() async {
    return await methodChannel.invokeMethod<bool>('isInstalled') ?? false;
  }

  @override
  Future<String?> login() async {
    return await methodChannel.invokeMethod<String>('login');
  }

  @override
  Future<String?> getUserInfo(String accessToken, String openid) async {
    Map<String, dynamic> params = {
      'accessToken': accessToken,
      'openid': openid
    };
    return await methodChannel.invokeMethod<String>('getUserInfo', params);
  }
}
