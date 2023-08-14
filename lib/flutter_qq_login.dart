import 'dart:convert';

import 'flutter_qq_login_platform_interface.dart';

class FlutterQqLogin {
  Future<void> init({required String appId}) {
    return FlutterQqLoginPlatform.instance.init(appId);
  }

  Future<bool> isInstalled() {
    return FlutterQqLoginPlatform.instance.isInstalled();
  }

  Future<Map<String, dynamic>> login() async {
    String data = await FlutterQqLoginPlatform.instance.login() ?? "";
    if (data.isNotEmpty) {
      return jsonDecode(data);
    }
    return {};
  }

  Future<Map<String, dynamic>> getUserInfo(String accessToken, String openid) async {
    String data = await FlutterQqLoginPlatform.instance.getUserInfo(accessToken, openid) ?? "";
    if (data.isNotEmpty) {
      return jsonDecode(data);
    }
    return {};
  }
}
