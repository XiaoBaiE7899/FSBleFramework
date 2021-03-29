
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

/* 运动ID */
@property (nonatomic, readonly) NSString *uid;

/* 体重 */
@property (nonatomic, readonly) NSString *weight;

/* 身高 */
@property (nonatomic, readonly) NSString *height;

/* 年龄 */
@property (nonatomic, readonly) NSString *age;

/* 性别 */
@property (nonatomic, readonly) NSString *gender;

/* 调整速度 */
@property (nonatomic, readonly) NSString *adjustSpeed;

/* 调整坡度 */
@property (nonatomic, readonly) NSString *adjustSlope;

/* 阻力 */
@property (nonatomic, readonly) NSString *level;

/* 频率 */
@property (nonatomic, readonly) NSString *frequency;

/* 启动倒计时秒数 */
@property (nonatomic, readonly) NSString *countDwonSecond;

/* 功率 */
@property (nonatomic, readonly) NSString *watt;

/* 判断设备是不是正在暂停中，重写了getter方法， */
@property (nonatomic, assign) BOOL isPausing;

/* 判断设备是不是正在运行 重写了getter方法， 运动设备不同，内部判断也不同 */
//@property (nonatomic, assign) BOOL isRunning; // 状态重新封装以后，这个不需要了

/* 设备是否已经停止  重写setter方法 */
@property (nonatomic, assign) BOOL hasStoped;

/* 已获取速度参数 */
@property (nonatomic, readonly) BOOL hasGetSpeedParam;

/* 已获取坡度参数 */
@property (nonatomic, readonly) BOOL hasGetInclineParma;

/* 已获取阻力参数*/
@property (nonatomic, readonly) BOOL hasGetLevelParam;


// FIXME: 注释应该详细说明，什么情况下，不能启动设备
/// 启动设备，如果可以启动返回yes，如果不能启动，返回NO
- (BOOL)startDevice;

/// 改变速度
/// @param speed 目标速度
- (void)sendTargetSpeed:(int)speed;

/// 改变坡度
/// @param incline 目标坡度
- (void)sendTargetIncline:(int)incline;


/// 同时控制速度&坡度
/// @param speed 目标速度
/// @param incline 目标坡度
- (void)sendTargetSpeed:(int)speed targetIncline:(int)incline;


/// 改变阻力
/// @param level 目标阻力
- (void)sendTargetLevel:(int)level;


/// 同时控制阻力&批斗
/// @param level 目标阻力
/// @param incline 目标坡度
- (void)sendTargetLevel:(int)level targetIncline:(int)incline;

/// 暂停设备
- (void)pause;

/// 停止设备
- (void)stop;

// 恢复设备 到运行中
- (void)resume;

@end

NS_ASSUME_NONNULL_END
