# flutter_qq_login

[中文请移步此处](./README_CN.md)

Flutter QQ Login Plugin

|             | Android | iOS   |
|-------------|---------|-------|
| **Support** | SDK 19+ | 11.0+ |

<p>
  <img src="https://github.com/yechong/flutter_qq_login/blob/main/doc/images/android.gif?raw=true"
    alt="An animated image of the iOS QQ Login Plugin UI" height="400"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/yechong/flutter_qq_login/blob/main/doc/images/iphone.gif?raw=true"
   alt="An animated image of the Android QQ Login Plugin UI" height="400"/>
</p>

## Features

This plugin has integrated the function of QQ login:
- Determine whether the QQ APP has been installed `isQQInstalled()`
- The data obtained after successful login, including `OpenId`, `AccessToken` and other important data
- Get user information `getUserInfo()`

## Getting Started

Before using this plugin, it is strongly recommended to read the official documentation in detail
- [Android_SDK environment construction](https://wiki.connect.qq.com/qq%e7%99%bb%e5%bd%95)
- [iOS_SDK environment construction](https://wiki.connect.qq.com/ios_sdk%e7%8e%af%e5%a2%83%e6%90%ad%e5%bb%ba)

### Usage

```dart
import 'package:flutter_qq_login/flutter_qq_login.dart';

// Create FlutterQqLogin
final flutterQqLogin = FlutterQqLogin();

// Initialization, please fill in the APP application ID created by QQ Internet
flutterQqLogin.init(appId: "Your APPID");

// Determine whether the QQ application is currently installed
bool isInstalled = await flutterQqLogin.isInstalled();

// Call up QQ login, return OpenId, AccessToken and other important data after successful login
Map<String, dynamic> qqInfo = await flutterQqLogin.login();

// Get user information
Map<String, dynamic> userInfo = await flutterQqLogin.getUserInfo(qqInfo['access_token'], qqInfo['openid']);

```

### Configure Android version

Configure `android/app/build.gradle`
```
android {
    ...

    defaultConfig {
        ...
        minSdkVersion 19
        ...
    }

}

```

Configure `android/app/src/main/AndroidManifest.xml`

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
	<!-- new content start -->
	<uses-permission android:name="android.permission.INTERNET" />
	<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
	<!-- new content end -->
	<application>
		...
		<!-- new content start -->
		<activity
            android:name="com.tencent.tauth.AuthActivity"
            android:noHistory="true"
            android:launchMode="singleTask"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="Your APPID" />
            </intent-filter>
        </activity>
        <activity
            android:name="com.tencent.connect.common.AssistActivity"
            android:configChanges="orientation|keyboardHidden"
            android:screenOrientation="behind"
            android:theme="@android:style/Theme.Translucent.NoTitleBar" />
		<!-- new content end -->
		...
	</application>
	<!-- new content start -->
	<queries>
		<package android:name="com.tencent.mobileqq" />
	</queries>
	<!-- new content end -->
</manifest>
```


### Configure iOS version

Configure `URL Types`
- Use `xcode` to open your iOS project `Runner.xcworkspace`
- In the `info` configuration tab under `URL Types`, add a new entry
    - `identifier` fills in `tencentopenapi`
    - `URL Schemes` fill in `tencent123456789`, where `123456789` is your `APPID`
    - As shown below:
      ![xcode configuration example](https://raw.githubusercontent.com/yechong/flutter_qq_login/main/doc/images/ios_screenshot_01.png)


Configure `LSApplicationQueriesSchemes`
- Method 1, configure `info` in `xcode`
    - Open `info` configuration, add a `LSApplicationQueriesSchemes`, namely `Queried URL Schemes`
    - Add these items:
        - mqqopensdknopasteboard
        - mqqapi
        - mqq
        - mqqOpensdkSSoLogin
        - mqqconnect
        - mqqopensdkdataline
        - mqqopensdkgrouptribeshare
        - mqqopensdkfriend
        - mqqopensdkapi
        - mqqopensdkapiV2
        - mqqopensdkapiV3
        - mqzoneopensdk
        - wtloginmqq
        - wtloginmqq2
        - mqqwpa
        - mqzone
        - mqzonev2
        - mqzoneshare
        - wtloginqzone
        - mqzonewx
        - mqzoneopensdkapiV2
        - mqzoneopensdkapi19
        - mqzoneopensdkapi
        - mqzoneopensdk
  - As shown below:
    ![xcode configuration example](https://raw.githubusercontent.com/yechong/flutter_qq_login/main/doc/images/ios_screenshot_02.png)

- Method 2, modify `Info.plist` directly
    - Use `Android Studio` to open `ios/Runner/Info.plist` under the project project
    - Add the following configuration under the `dict` node (refer to the configuration format in the file):
```
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>mqqopensdknopasteboard</string>
	<string>mqqapi</string>
	<string>mqq</string>
	<string>mqqOpensdkSSoLogin</string>
	<string>mqqconnect</string>
	<string>mqqopensdkdataline</string>
	<string>mqqopensdkgrouptribeshare</string>
	<string>mqqopensdkfriend</string>
	<string>mqqopensdkapi</string>
	<string>mqqopensdkapiV2</string>
	<string>mqqopensdkapiV3</string>
	<string>mqzoneopensdk</string>
	<string>wtloginmqq</string>
	<string>wtloginmqq2</string>
	<string>mqqwpa</string>
	<string>mqzone</string>
	<string>mqzonev2</string>
	<string>mqzoneshare</string>
	<string>wtloginqzone</string>
	<string>mqzonewx</string>
	<string>mqzoneopensdkapiV2</string>
	<string>mqzoneopensdkapi19</string>
	<string>mqzoneopensdkapi</string>
	<string>mqzoneopensdk</string>
</array>
```


## LICENSE

```Copyright 2018 OpenFlutter Project

Licensed to the Apache Software Foundation (ASF) under one or more contributor
license agreements.  See the NOTICE file distributed with this work for
additional information regarding copyright ownership.  The ASF licenses this
file to you under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License.  You may obtain a copy of
the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
License for the specific language governing permissions and limitations under
the License.```
