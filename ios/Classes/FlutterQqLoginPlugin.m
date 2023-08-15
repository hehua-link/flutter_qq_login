#import "FlutterQqLoginPlugin.h"

#import <TencentOpenAPI/TencentOpenApiUmbrellaHeader.h>


@interface FlutterQqLoginPlugin () <TencentSessionDelegate>
@property (nonatomic, strong) TencentOAuth *_tencentOAuth;
@property (nonatomic, strong) NSArray *_permissions;
@property (nonatomic, strong) FlutterResult loginCallback; // 登录回调
@property (nonatomic, strong) FlutterResult userInfoCallback; // 获取用户信息回调
@end

@implementation FlutterQqLoginPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_qq_login"
            binaryMessenger:[registrar messenger]];
  FlutterQqLoginPlugin* instance = [[FlutterQqLoginPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar addApplicationDelegate:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }
  else if ([@"init" isEqualToString:call.method]) {
      NSDictionary *arguments = call.arguments; // 获取传递的参数
      NSString *appId = arguments[@"appId"]; // 获取特定参数的值
      NSLog(@"appId=%@", appId);
      
      [TencentOAuth setIsUserAgreedAuthorization:YES];
      
      self._tencentOAuth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
      NSLog(@"_tencentOAuth=%@", self._tencentOAuth);
      
      self._permissions = [NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo", @"add_t", nil];
      NSLog(@"_permissions=%@", self._permissions);
      
      result(nil);
  }
  else if ([@"isInstalled" isEqualToString:call.method]) {
      bool isInstalled = [TencentOAuth iphoneQQInstalled];
      NSLog(@"isInstalled=%d", isInstalled);
      NSNumber *isInstalledNumber = [NSNumber numberWithBool:isInstalled];
      result(isInstalledNumber);
  }
  else if ([@"login" isEqualToString:call.method]) {
      // 保存登录回调
      self.loginCallback = result;
      // 授权QQ登录
      [self._tencentOAuth authorize:self._permissions];
  }
  else if ([@"getUserInfo" isEqualToString:call.method]) {
      self.userInfoCallback = result;
      [self._tencentOAuth getUserInfo];
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // Handle openURL here
    NSLog(@"---handleOpenURL---");
    return [TencentOAuth HandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    // Handle openURL with options here
    NSLog(@"---handleOpenURL2---");
    return [TencentOAuth HandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"---handleOpenURL3---");
    return [TencentOAuth HandleOpenURL:url];
}

- (void)tencentDidLogin {
    NSLog(@"---tencentDidLogin---");
    NSLog(@"accessToken=%@ openid=%@", self._tencentOAuth.accessToken, self._tencentOAuth.openId);
    // 模拟异步操作完成后返回结果给Flutter
    
    if (self._tencentOAuth.accessToken && 0 != [self._tencentOAuth.accessToken length]) {
        // 记录登录用户的OpenID、Token以及过期时间
        
        // 计算时间戳（以秒为单位）
        NSTimeInterval timestampInSeconds = [self._tencentOAuth.expirationDate timeIntervalSince1970];
        // 转换为毫秒
        long long timestampInMilliseconds = (long long)(timestampInSeconds * 1000);
        
        NSDictionary *dictionary = @{
            @"access_token": self._tencentOAuth.accessToken,
            @"openid": self._tencentOAuth.openId,
            @"expire_date": @(timestampInMilliseconds)
        };
                
        NSString *jsonString = [self convertToJsonString:dictionary];
        
        if (jsonString && jsonString.length > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.loginCallback) {
                    self.loginCallback(jsonString); // 传递nil表示登录成功
                    self.loginCallback = nil; // 清空回调
                }
            });
        }
    }
    else {
        
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    NSLog(@"---tencentDidNotLogin--- %d", cancelled);
}

- (void)tencentDidNotNetWork {
    NSLog(@"---tencentDidNotNetWork---");
}

- (void)getUserInfoResponse:(APIResponse *)response {
    NSLog(@"---getUserInfoResponse---");
    if (URLREQUEST_SUCCEED == response.retCode && kOpenSDKErrorSuccess == response.detailRetCode) {
        NSLog(@"jsonResponse=%@", response.jsonResponse);
        
        NSString *jsonString = [self convertToJsonString:response.jsonResponse];
        
        if (jsonString && jsonString.length > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.userInfoCallback) {
                    self.userInfoCallback(jsonString); // 传递nil表示登录成功
                    self.userInfoCallback = nil; // 清空回调
                }
            });
        }
        
    } else {
        NSDictionary *dictionary = @{
            @"retCode": @(response.retCode),
            @"errorMsg": response.errorMsg
        };
        
        NSString *jsonString = [self convertToJsonString:dictionary];
        
        if (jsonString && jsonString.length > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.userInfoCallback) {
                    self.userInfoCallback(jsonString); // 传递nil表示登录成功
                    self.userInfoCallback = nil; // 清空回调
                }
            });
        }
    }
}

/**
    将给定的 NSDictionary 对象转换为 JSON 格式的字符串。
 
    @param dictionary 要转换的 NSDictionary 对象。
    @return 转换后的 JSON 格式的字符串，如果转换失败则返回 nil。
 */
- (NSString *)convertToJsonString:(NSDictionary *)dictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        NSLog(@"Error creating JSON data: %@", error);
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
