//
//  FSBleDevice.h
//  FSBluetoothSDK
//
//  Created by zt on 2021/2/28.
//  运动秀的蓝牙设备

#import "BleDevice.h"

NS_ASSUME_NONNULL_BEGIN


@interface FSBleDevice : BleDevice

/* 模块厂商 */
@property (nonatomic, readonly) NSString   * _Nullable manufacturer;

/* 模块机型 */
@property (nonatomic, readonly) NSString   * _Nullable model;

/* 硬件版本 */
@property (nonatomic, readonly) NSString   * _Nullable hardware;

/* 软件版本 */
@property (nonatomic, readonly) NSString   * _Nullable software;

/// 改变速度
/// @param speed 目标速度
- (void)sendTargetSpeed:(int)speed;

/// 改变坡度
/// @param incline 目标坡度
- (void)sendTargetIncline:(int)incline;


/// 改变阻力
/// @param level 目标阻力
- (void)sendTargetLevel:(int)level;

/// 暂停设备
- (void)pause;

/// 停止设备
- (void)stop;

// 恢复设备 到运行中
- (void)resume;

@end

NS_ASSUME_NONNULL_END
