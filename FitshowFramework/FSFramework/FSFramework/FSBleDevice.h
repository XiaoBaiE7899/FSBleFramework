
//  运动秀的蓝牙设备

#import "BleDevice.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSBleDevice : BleDevice

#pragma mark 设备的参数数据
/* 设备的默认图片，在boudle文件里面，重写getter方法 */
@property (nonatomic, strong) UIImage *fsDefaultImage;

/*是否为英制单位 0:公里  1: 英里  1英里(mi) = 1.60934千米(公里) */
@property (nonatomic, readonly) BOOL imperial;

/* 最大速度 */
@property (nonatomic, readonly, copy) NSString *maxSpeed;

/* 最小速度 */
@property (nonatomic, readonly, copy) NSString *minSpeed;

/* 最大坡度 */
@property (nonatomic, readonly, copy) NSString *maxIncline;

/* 最小坡度 */
@property (nonatomic, readonly, copy) NSString *minIncline;

/* 最大阻力 */
@property (nonatomic, readonly, copy) NSString *maxLevel;

/* 最小阻力 */
@property (nonatomic, readonly, copy) NSString *minLevel;

/* 车表段数 */
@property (nonatomic, readonly, copy) NSString *paragraphs;

/* 坡度是否支持控制 */
@property (nonatomic, readonly) BOOL           supportIncline;

/* 阻力是否支持控制 */
@property (nonatomic, readonly) BOOL           supportLevel;

/* 速度是否支持控制 */
@property (nonatomic, readonly) BOOL           supportSpeed;

/* 是否支持控制 速度、坡度、阻力只要有一个可以控制，这个设置就可以控制 */
@property (nonatomic, readonly) BOOL           supportControl;

/* 是否支持暂停 */
@property (nonatomic, readonly) BOOL           supportPause;

/* 设备总里程 */
@property (nonatomic, readonly) NSString      *totalDistance;

#pragma mark 设备的实时数据

/* 设备的旧状态 初始化状态：-1 */
@property (nonatomic, readonly) FSDeviceState      oldStatus;

/* 设备的新状态 初始化状态：-1 */
@property (nonatomic, readonly) FSDeviceState      currentStatus;

/* 速度 区分英制单位&公制单位 */
@property (nonatomic, readonly) NSString *speed;

/* 坡度 */
@property (nonatomic, readonly) NSString *incline;

/* 运动时长 秒 */
@property (nonatomic, readonly) NSString *eElapsedTime;

/* 运动距离 区分英制单位&公制单位 */
@property (nonatomic, readonly) NSString *distance;

/* 消耗的卡路里 单位没写，有点麻烦 */
@property (nonatomic, readonly) NSString *calory;

/* 步数 */
@property (nonatomic, readonly) NSString *steps;

/* 次数 */
@property (nonatomic, readonly) NSString *counts;

/* 心率 */
@property (nonatomic, readonly) NSString *heartRate;

/* 段数 */
@property (nonatomic, readonly) NSString *paragraph;

/* 错误码 */
@property (nonatomic, readonly) NSString *errorCode;

/* 阻力 */
@property (nonatomic, readonly) NSString *level;

/* 频率 */
@property (nonatomic, readonly) NSString *frequency;

/* 启动倒计时秒数 */
@property (nonatomic, readonly) NSString *countDwonSecond;

/* 功率 */
@property (nonatomic, readonly) NSString *watt;

/* 设备是否已经停止  重写setter方法 */
@property (nonatomic, assign) BOOL hasStoped;

/* 已获取速度参数 */
@property (nonatomic, readonly) BOOL hasGetSpeedParam;

/* 已获取坡度参数 */
@property (nonatomic, readonly) BOOL hasGetInclineParma;

/* 已获取阻力参数*/
@property (nonatomic, readonly) BOOL hasGetLevelParam;

/// 启动设备，跑步机只有当设备处于正常待机状态才能启动，车表则是设备处于正常待机或睡眠状态都能正常启动  其他情况都不能启动
- (BOOL)startDevice;

/// 改变速度  只有跑步机才支持改变速度
/// @param speed 目标速度  速度单位是0.1, e.g. 如果要把速度调整到5.0，应该传承50，以此类推
- (void)sendTargetSpeed:(int)speed;

/// 改变坡度
/// @param incline 目标坡度
- (void)sendTargetIncline:(int)incline;


/// 同时控制速度&坡度
/// @param speed 目标速度 速度单位是0.1, e.g. 如果要把速度调整到5.0，应该传承50，以此类推
/// @param incline 目标坡度
- (void)sendTargetSpeed:(int)speed targetIncline:(int)incline;


/// 改变阻力
/// @param level 目标阻力
- (void)sendTargetLevel:(int)level;


/// 同时控制阻力&坡度
/// @param level 目标阻力
/// @param incline 目标坡度
- (void)sendTargetLevel:(int)level targetIncline:(int)incline;

// MARK: 恢复暂停，只有跑步机1.1协议才有，只有设备是跑步机并且协议是1.1版本的才有暂停功能，车表不会发送指令
/// 暂停设备
- (void)pause;

/// 停止设备
- (void)stop;

// MARK: 恢复设备，只有跑步机1.1协议才有，只有设备是跑步机并且协议是1.1版本的才有暂停功能，车表不会发送指令
/// 恢复设备 到运行中
- (void)resume;

@end

NS_ASSUME_NONNULL_END
