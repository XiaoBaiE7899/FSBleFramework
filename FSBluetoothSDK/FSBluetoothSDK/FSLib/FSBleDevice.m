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

/* 心跳包定时器 */
@property (nonatomic, strong) NSTimer *heartbeatTimer;

@end

@implementation FSBleDevice

#pragma mark 重写父类的方法
- (BOOL)onService {
    FSLog(@"执行子类onService");
    CBUUID *server = UUID(SERVICES_UUID); // 服务
    CBUUID *send = UUID(CHAR_WRITE_UUID); // 写特征
    CBUUID *recv = UUID(CHAR_NOTIFY_UUID); //听特征
    for (CBService *s in self.module.services) {
        // 读取数据
        [s.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.UUID.UUIDString isEqualToString:CHAR_READ_MFRS] || // 获取厂家
                [obj.UUID.UUIDString isEqualToString:CHAR_READ_PN]   || // 获取型号
                [obj.UUID.UUIDString isEqualToString:CHAR_READ_HV]   || // 硬件版本
                [obj.UUID.UUIDString isEqualToString:CHAR_READ_SV]      // 获取软件版本
                ) {
                [self.module.peripheral readValueForCharacteristic:obj];
            }

            // 查找 指定服务下的 通知通道&可写通道
            if ([s.UUID isEqual:server]) {
                for (CBCharacteristic *c in s.characteristics) {
                    if ([c.UUID isEqual:recv]) { // 通知通道
                        [self setValue:c forKeyPath:@"bleNotifyChar"];
                        [s.peripheral setNotifyValue:YES forCharacteristic:c];
                    } else if ([c.UUID isEqual:send]) { // 可写通道
                        [self setValue:c forKeyPath:@"bleWriteChar"];
                    }
                }
            }
        }];

    }
    // 通知通道  && 可写通道都找打了  才能返回yes,
    if (self.bleNotifyChar && self.bleWriteChar) {
        return YES;
    }
    // 回调找不到服务
    if (self.fsDeviceDeltgate && [self.fsDeviceDeltgate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
        [self disconnect:DisconnectTypeService];
        [self.fsDeviceDeltgate device:self didDisconnectedWithMode:DisconnectTypeService];
    }
    return NO;
}

- (void)onConnected {
    FSLog(@"执行子类onConnected");
    // 已连上的方法
}

- (void)onDisconnected {
    FSLog(@"执行子类onDisconnected");
}

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

// 指令
// 数据解析

@end
