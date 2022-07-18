//
//  AppDelegate.m
//  FSDemo
//
//  Created by zt on 2021/4/8.
//

#import "AppDelegate.h"
#import <FSExpand/FSExpand.h>
#import <FSBleFramework/FSBleFramework.h>

//#import <AddressBook/AddressBook.h> // iOS 9 以前
#import <Contacts/Contacts.h> // iOS 9 以后

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    NSLog(@"%@", @"0".add(@"1"));
//    [FSSport current];
    [FSSport currentWithHostURL:@"http://192.168.0.236:8082/api/device/getDeviceInfo/"];
    FSLog(@"蓝牙SDK版本:%.2f", FSBleFrameworkVersionNumber);
    // 测试  静态库类目
//    NSData *data = FSGenerateCmdData.treadmillSpeedParam();
//    FSLog(@"测试  静态库类目%@", data.fsToString());
    // 测试缓存数据
    NSDictionary *dic1 = @{
        @"brand" : @"fs",
        @"device" : @(1),
        @"factory" : @(1),
        @"image" : @"imgUrl",
        @"model" : @(1),
        @"name" : @"deviceName",
        @"type" : @(0),
        @"paramString" : @"参数字符串",
        @"motorModeString" : @"电机模式",
        @"unDEFINE" : @"DDD"
    };
    NSDictionary *dic2 = @{
        @"brand" : @"fs",
        @"device" : @(2),
        @"factory" : @(2),
        @"image" : @"imgUrl",
        @"model" : @(2),
        @"name" : @"deviceName",
        @"type" : @(0),
        @"paramString" : @"参数字符串",
        @"motorModeString" : @"电机模式",
        @"unDEFINE" : @"DDD"
    };
    NSDictionary *dic3 = @{
        @"brand" : @"fs",
        @"device" : @(3),
        @"factory" : @(3),
        @"image" : @"imgUrl",
        @"model" : @(3),
        @"name" : @"deviceName",
        @"type" : @(0),
        @"paramString" : @"参数字符串",
        @"motorModeString" : @"电机模式",
        @"unDEFINE" : @"DDD"
    };
    NSArray *testData1 = @[dic1];
    [FSBleTools createDeviceInfoPlistFileWith:testData1];
    
    NSArray *testData2 = @[dic2];
    [FSBleTools createDeviceInfoPlistFileWith:testData2];
    
    NSArray *testData3 = @[dic1, dic2, dic3];
    [FSBleTools createDeviceInfoPlistFileWith:testData3];
    
    // 通讯录访问
//    [self requestAuthorizationAddressBook];

    return YES;
}

- (void)requestAuthorizationAddressBook {
    // 判断是否授权
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (status) {
        case CNAuthorizationStatusNotDetermined: {
            FSLog(@"512还没授权，需要授权");
//            [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    // 回到主线程操作
//                }
            [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                FSLog(@"512 %d  %@", granted, error);
                            
            }];
        }
            
            break;
        case CNAuthorizationStatusRestricted: {
            FSLog(@"512已经被限制,家长控制");
        }
            break;
        case CNAuthorizationStatusDenied: {
            FSLog(@"512拒绝访问");
        }
            break;
        case CNAuthorizationStatusAuthorized: {
            FSLog(@"512允许访问");
        }
            
        default:
            break;
    }
}


@end
