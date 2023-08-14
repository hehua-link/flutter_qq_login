import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_qq_login/flutter_qq_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterQqLogin = FlutterQqLogin();

  bool startLogin = false;
  bool _isInstalled = false;
  Map<String, dynamic> qqInfo = {};
  Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {

    _flutterQqLogin.init(appId: "_Your_app_id_");
    bool isInstalled = await _flutterQqLogin.isInstalled();

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isInstalled = isInstalled;
    });

  }

  @override
  Widget build(BuildContext context) {
    Widget userInfoWidget = Container();
    if (startLogin) userInfoWidget = CircularProgressIndicator();
    if (userInfo.isNotEmpty) {
      userInfoWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.network(userInfo['figureurl_qq_1']),
          ),
          SizedBox(width: 5,),
          Text(userInfo['nickname']),
        ],
      );
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('QQ Login Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('isInstalled QQ: $_isInstalled'),
              ElevatedButton(
                child: Text("Login"),
                onPressed: () {
                  doLogin();
                },
              ),
              SizedBox(height: 10,),
              userInfoWidget
            ],
          ),
        ),
      ),
    );
  }

  Future<void> doLogin() async {
    if (mounted) {
      setState(() {
        startLogin = true;
      });
    }
    Map<String, dynamic> tempQqInfo = await _flutterQqLogin.login();
    print('flutter_qq_plugin -> qqInfo = $tempQqInfo');
    Map<String, dynamic> tempUserInfo = await _flutterQqLogin.getUserInfo(tempQqInfo['access_token'], tempQqInfo['openid']);
    print('flutter_qq_plugin -> userInfo = $tempUserInfo');
    if (mounted) {
      setState(() {
        qqInfo = tempQqInfo;
        userInfo = tempUserInfo;
        startLogin = false;
      });
    }
  }
}
