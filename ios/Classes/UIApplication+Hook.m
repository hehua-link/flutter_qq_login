// UIApplication+Hook.m
#import "UIApplication+Hook.h"
#import <objc/runtime.h>

@implementation UIApplication (Hook)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(openURL:);
        SEL swizzledSelector = @selector(g_openURL:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        if (originalMethod && swizzledMethod) {
            method_exchangeImplementations(originalMethod, swizzledMethod);
            NSLog(@"openURL: 方法交换成功！");
        }
    });
}

- (BOOL)g_openURL:(NSURL *)url {
    NSLog(@"拦截到 openURL: %@", url);
    if ([UIApplication.sharedApplication respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [UIApplication.sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) {
            NSLog(@"openURL:options:completionHandler: 返回 %d", success);
        }];
    } else {
        return [self g_openURL:url];
    }
    return YES;
}

@end
