//
//  AppDelegate.m
//  FSDemo
//
//  Created by zt on 2021/4/8.
//

#import "AppDelegate.h"
#import <FSExpand/FSExpand.h>
#import <FSBleFramework/FSBleFramework.h>



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    NSLog(@"%@", @"0".add(@"1"));
    [FSSport current];
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

    return YES;
}


@end
