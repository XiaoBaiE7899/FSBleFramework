
#import <Foundation/Foundation.h>
#import "FSSlimmingMode.h"
#import "FSFrameworkEnum.h"

/* 22.7.11
 MARK: 这是设备的指令集
 SDK 已经适配并且调试过的的指令
 SDK 调用不会涉及到这个类，
 */






NS_ASSUME_NONNULL_BEGIN

@interface FSGenerateCmdData : NSObject

// 跑步机  ---- 相关指令

/// 获取跑步机的速度参数
+ (NSData *(^)(void))treadmillSpeedParam;

/// 获取跑步机的坡度参数
+ (NSData *(^)(void))treadmillInclineParam;

/// 启动跑步机
+ (NSData *(^)(void))treadmillStart;

/// 查询跑步机实时状态， 如果跑步机处于FSDeviceStateRunning，FSDeviceStatePaused，FSDeviceStateTreadmillStopping 这条指令是带数据上报的，具体的数据位在协议有说明
+ (NSData *(^)(void))treadmillStatus;


/// 停止跑步机，发送这条指令，如果设备没有响应，会发送失控的通知：kCmdUncontrolled
+ (NSData *(^)(void))treadmillStop;


/*
 调整设备的速度与坡度，第一个：速度 精度：0.1， 第二个参数：坡度
 例如把设备的速度调整为：5KM/H  坡度调整为6， 传入的数据为： 50， 6
 */
+ (NSData *(^)(int, int))treadmillControlSpeedAndIncline;

/*
 写入用户数据，
 参数分别为：UID(因为历史问题，这里必须传入0), 体重(KG), 身高(cm), 年龄, 性别:(0-男， 1-女)
 0, 60, 170, 25, 0
 */
+ (NSData *(^)(int, int, int, int, int))treadmillWriteUserData;


// 车表----
/// 获取车表的参数信息
+ (NSData *(^)(void))sectionParamInfo;

/// 获取车表的状态
+ (NSData *(^)(void))sectionStatue;

/// 获取运动数据
+ (NSData *(^)(void))sectionSportDada;

/// 车表准备
+ (NSData *(^)(void))sectionReady;

/// 启动设备
+ (NSData *(^)(void))sectionStart;

/// 停止设备
+ (NSData *(^)(void))sectionStop;

/// 控制参数  阻力、坡度
+ (NSData *(^)(int, int))sectionControlParam;

/*
 写入用户数据，
 参数分别为：UID(因为历史问题，这里必须传入0), 体重(KG), 身高(cm), 年龄, 性别:(0-男， 1-女)
 0, 60, 170, 25, 0
 */
+ (NSData *(^)(int, int, int, int, int))sectionWriteUserData;

// 甩脂机、筋膜枪----------
// 唤醒设备
+ (NSData *(^)(void))slimmingWakeUps;

/// 指令模式启动
+ (NSData *(^)(SlimmingMode, NSData *))slimmingStart;

/// 停止当前模式
+ (NSData *(^)(NSData *))slimmingStop;

// 切换新模式 跟 启动程序模式 代码一样
+ (NSData *(^)(NSData *, FSSlimmingMode *))slimmingNewMode;

/// 运动时间
+ (NSData *(^)(int, NSData *))slimmingTime;

/// 改变时间，
+ (NSData *(^)(int, int, NSData *))slimmingChangeTime;

/// 跳转速速
+ (NSData *(^)(int, NSData *))slimmingSpeed;

/// 切换模式
+ (NSData *(^)(SlimmingMode, NSData *))slimmingMode;


// 跳绳、健腹轮、莫高挑 ----
// 设备信息
+ (NSData *(^)(void))ropeInfo;

// 启动自由模式
+ (NSData  *(^)(void))ropeStarFreeMode;

// 固定次数，启动
+ (NSData *(^)(NSInteger))ropeStarCountsMode;

// 固定时间  启动
+ (NSData *(^)(NSInteger))ropeStarTimeMode;

// 停止
+ (NSData *(^)(void))ropeStop;

// 暂停
+ (NSData *(^)(void))ropePause;

// 重启
+ (NSData *(^)(void))ropeRestore;

// 设置数据
+ (NSData *(^)(void))ropeSetDeviceDate;

// 读取数据
+ (NSData *(^)(void))ropeReadDeviceDate;

// 读取电量
+ (NSData *(^)(void))ropeHeartbeat;


// 力量器械


@end

NS_ASSUME_NONNULL_END
