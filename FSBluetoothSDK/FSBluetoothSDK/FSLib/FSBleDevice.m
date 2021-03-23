//
//  FSBleDevice.m
//  FSBluetoothSDK
//
//  Created by zt on 2021/2/28.
//

#import "FSBleDevice.h"
#import "FSLibHelp.h"

@interface FSBleDevice ()

/* 模块厂商 */
@property (nonatomic) NSString   * _Nullable manufacturer;

/* 模块机型 */
@property (nonatomic) NSString   * _Nullable model;

/* 硬件版本 */
@property (nonatomic) NSString   * _Nullable hardware;

/* 软件版本 */
@property (nonatomic) NSString   * _Nullable software;

@end

@implementation FSBleDevice

#pragma mark 重写父类的方法

#pragma mark 对外开放方法
// 发送速度指令
- (void)sendTargetSpeed:(int)speed {

}

// 发送坡度指令
- (void)sendTargetIncline:(int)incline {

}

// 发送阻力指令
- (void)sendTargetLevel:(int)level {

}

// 暂停设备
- (void)pause {

}

// 停止设备
- (void)stop {

}

// 恢复设备
- (void)resume {

}

#pragma mark setter && getter
- (UIImage *)fsDefaultImage {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"FSDeiveceDefImg" ofType:@"bundle"];
    if (!bundlePath) {
        FSLog(@"bundle 文件为空，直接返回空");
        return nil;
    }

    NSString *str = FSSF(@"device_deficon_%ld.png", (long)self.module.type);
    UIImage *iconImage = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:str]];
    if (!iconImage) {
        FSLog(@"bundle 文件找不到图片，直接返回空");
        return nil;
    }
    
    return iconImage;
}

@end
