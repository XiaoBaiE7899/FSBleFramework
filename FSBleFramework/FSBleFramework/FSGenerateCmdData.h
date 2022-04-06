
#import <Foundation/Foundation.h>
#import "FSSlimmingMode.h"
#import "FSFrameworkEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSGenerateCmdData : NSObject

// 跑步机----
+ (NSData *(^)(void))treadmillSpeedParam;

+ (NSData *(^)(void))treadmillInclineParam;

+ (NSData *(^)(void))treadmillStart;

+ (NSData *(^)(void))treadmillStatus;

+ (NSData *(^)(void))treadmillStop;

+ (NSData *(^)(int, int))treadmillControlSpeedAndIncline;

+ (NSData *(^)(int, int, int, int, int))treadmillWriteUserData;


// 车表----
+ (NSData *(^)(void))sectionParamInfo;

+ (NSData *(^)(void))sectionStatue;

+ (NSData *(^)(void))sectionSportDada;

+ (NSData *(^)(void))sectionReady;

+ (NSData *(^)(void))sectionStart;

+ (NSData *(^)(void))sectionStop;

+ (NSData *(^)(int, int))sectionControlParam;

+ (NSData *(^)(int, int, int, int, int))sectionWriteUserData;

// 甩脂机、筋膜枪----------

+ (NSData *(^)(void))slimmingWakeUps;

+ (NSData *(^)(SlimmingMode, NSData *))slimmingStart;

+ (NSData *(^)(NSData *))slimmingStop;

// 切换新模式 跟 启动程序模式 代码一样
+ (NSData *(^)(NSData *, FSSlimmingMode *))slimmingNewMode;

+ (NSData *(^)(int, NSData *))slimmingTime;

+ (NSData *(^)(int, int, NSData *))slimmingChangeTime;

+ (NSData *(^)(int, NSData *))slimmingSpeed;

+ (NSData *(^)(SlimmingMode, NSData *))slimmingMode;


// 跳绳、健腹轮、莫高挑 ----
+ (NSData *(^)(void))ropeInfo;

+ (NSData  *(^)(void))ropeStarFreeMode;

+ (NSData *(^)(NSInteger))ropeStarCountsMode;

+ (NSData *(^)(NSInteger))ropeStarTimeMode;

+ (NSData *(^)(void))ropeStop;

+ (NSData *(^)(void))ropePause;

+ (NSData *(^)(void))ropeRestore;

+ (NSData *(^)(void))ropeSetDeviceDate;

+ (NSData *(^)(void))ropeReadDeviceDate;

+ (NSData *(^)(void))ropeHeartbeat;


// 力量器械


@end

NS_ASSUME_NONNULL_END
