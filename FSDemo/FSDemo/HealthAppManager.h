
//  苹果健康 相关数据的写入与读取

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HealthAppManager : NSObject

@property (nonatomic, strong) HKHealthStore *healthStore;

+ (HealthAppManager *)shareInstance;


// 请求授权
- (void)authorizeHealthKit:(void(^)(BOOL success, NSError *error))compltion;

// 数据同步到苹果健康  距离、步数  卡路里(NO)
+ (void)syncDataToAppleHealt;

// 读取步数
- (void)healthAppSteps:(int)type complete:(void(^)(double value, NSError *error))completion;

// 今天的0时0分0秒
+ (NSDate *)dayBegin;

// 本周第一天的 0时0分0秒
+ (NSDate *)weekBegin;

// 本月第一天的 0时0分0秒
+ (NSDate *)monthBegin;

@end

NS_ASSUME_NONNULL_END
