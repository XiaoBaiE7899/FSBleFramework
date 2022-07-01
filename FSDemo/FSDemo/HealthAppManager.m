
/*  https://www.jianshu.com/p/cfe1a0cc41ca
 注意:授权页面有 allow 和 notallow的只会弹出一次，
 如不允许后，下次想打开授权就必须进入到设置页面
 
 特别注意：授权页面，写数据关闭时候，读数据打开，其实相当于未授权；
 特别注意：授权页面，写数据打开时候，读数据关闭，其实相当于无数据；
 @"x-apple-health://app/"
 */
/* SCZG
 写入: 距离、步数、卡路里
 读取: 步数
 */

#import "HealthAppManager.h"

#import <UIKit/UIKit.h>


#define CustomHealthErrorDomain @"com.sdqt.healthError"
#define HKVersion [[[UIDevice currentDevice] systemVersion] doubleValue]

static HealthAppManager *healthManager = nil;

@interface HealthAppManager ()

@property (nonatomic, strong) NSPredicate *currentPredicate;
@property (nonatomic, assign) int goalCircye; // 时间周期

@end

@implementation HealthAppManager

+ (HealthAppManager *)shareInstance {
    static dispatch_once_t onceToken;
    NSLog(@"%f", HKVersion);
    dispatch_once(&onceToken, ^{
        if (healthManager == nil) {
            healthManager = [[HealthAppManager alloc] init];
        }
    });
    return healthManager;
}

- (NSSet *)requesReadAuthorizatio {
    HKQuantityType *stepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    return [NSSet setWithObjects:stepCount,nil];
}

- (NSSet *)requesWriteAuthorization {
    // 写入：距离、步数、卡路里
    // 读取：步数
    HKQuantityType *stepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *walkingRunning = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
//    HKQuantityType *cycling = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    return [NSSet setWithObjects:stepCount,walkingRunning,nil];
    
}

- (void)authorizeHealthKit:(void(^)(BOOL success, NSError *error))compltion {
    if (HKVersion <= 8.0) {
        return;
    }
    if (![HKHealthStore isHealthDataAvailable]) {
        NSError *error = [NSError errorWithDomain:@"com.raywenderlich.tutorials.healthkit" code: 2 userInfo: [NSDictionary dictionaryWithObject:@"HealthKit is not available in th is Device" forKey:NSLocalizedDescriptionKey]];
        if (compltion != nil) {
            compltion(NO, error);
        }
        return;
    }
    if ([HKHealthStore isHealthDataAvailable]) {
        if(self.healthStore == nil)
            self.healthStore = [[HKHealthStore alloc] init];
        /** 组装需要读写的数据类型 */
        NSSet *authTypes_w = [self requesWriteAuthorization];
        NSSet *authTypes_r = [self requesReadAuthorizatio];

        /** 注册需要读写的数据类型，也可以在“健康”APP中重新修改 */
        [self.healthStore requestAuthorizationToShareTypes:authTypes_w readTypes:authTypes_r completion:^(BOOL success, NSError *error) {
            // 必须放在这里才能回调
//            [self.healthStore handleAuthorizationForExtensionWithCompletion:^(BOOL success, NSError * _Nullable error) {
//                NSLog(@"22.6.22  回调");
//            }];
            if (!success) {
                NSLog(@"%@\n\n%@",error, [error userInfo]);
                return;
            } else {
                if (compltion != nil) {
                    NSLog(@"error->%@", error.localizedDescription);
                    compltion (success, error);
                }
            }

        }];
    }
    
}

#pragma mark 对外方法
- (void)healthAppSteps:(int)type complete:(void(^)(double value, NSError *error))completion {
    self.goalCircye = type;
    NSLog(@"读取苹果健康的步数");
    [self authorizeHealthKit:^(BOOL success, NSError *error) {
        if (success) {
            /** 查询采样信息样品类的实例，需要获取的数据是步数 */
            HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
            /** NSSortDescriptors用来告诉healthStore怎么样将结果排序。 */
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
            /** 查询的基类是HKQuery，这是一个抽象类，能够实现每一种查询目标，这里我们需要查询的步数是一个HKSample类所以对应的查询类就是HKSampleQuery。 */
            HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:self.currentPredicate limit:HKObjectQueryNoLimit sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                if(error) {
                    completion(0,error);
                } else {
                    NSInteger totleSteps = 0;
                    for(HKQuantitySample *quantitySample in results) {
                        /** 表示某一种数据单位的数量 */
                        HKQuantity *quantity = quantitySample.quantity;
                        HKUnit *heightUnit = [HKUnit countUnit];

                        double usersHeight = [quantity doubleValueForUnit:heightUnit];
                        totleSteps += usersHeight;
                    }
                    NSLog(@"当天行走步数 = %ld",(long)totleSteps);
                    completion(totleSteps,error);
                }
            }];
            /** 执行查询 */
            [self.healthStore executeQuery:query];
        }
    }];
}

+ (void)syncDataToAppleHealt {
    // 1 检查读写权限
    [[HealthAppManager shareInstance] authorizeHealthKit:^(BOOL success, NSError *error) {
        if (success) {
            // 有权限
            //
        }
    }];

}

#pragma setter && getter
- (void)setGoalCircye:(int)goalCircye {
    switch (goalCircye) {
        case 1: {
            self.currentPredicate = [HealthAppManager predicateToday];
        }
            break;
        case 2: {
            self.currentPredicate = [HealthAppManager predicateWeek];
            
        }
            break;
        case 3: {
            self.currentPredicate = [HealthAppManager predicateMonth];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark 内部方法
/**
 当天时间段

 @return 时间段
 */
+ (NSPredicate *)predicateForSamplesToday {
    /** 方式一 */
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond: 0];

    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
    /** 方式二 */
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDate *now = [NSDate date];
//    NSDate *startDate = [calendar startOfDayForDate:now];
//    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
//    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
//    return predicate;
}

+ (NSDate *)dayBegin {
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday  fromDate:nowDate];
    return [calendar dateWithEra:1 year:comp.year month:comp.month day:comp.day hour:0 minute:0 second:0 nanosecond:0];
}

// 今天的时间段
+ (NSPredicate *)predicateToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond: 0];

    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
}


+ (NSDate *)weekBegin {
    NSDate *nowDate = [NSDate date];
    NSInteger timeInterval = nowDate.timeIntervalSince1970;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday  fromDate:nowDate];
    // 获取今天是周几
    NSInteger weekDay = [comp weekday];
    // 计算当前日期和本周的星期一和星期天相差天数
    long firstWeekday = 1, lastWeekday = 7;
    firstWeekday = 1 - weekDay;
    lastWeekday = 7 - weekDay;
    NSDate *hqday = [NSDate dateWithTimeIntervalSince1970:timeInterval + firstWeekday * 86400];
    comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday  fromDate:hqday];
    return [calendar dateWithEra:1 year:comp.year month:comp.month day:comp.day hour:0 minute:0 second:0 nanosecond:0];
}

// 本周的时间段
+ (NSPredicate *)predicateWeek {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [HealthAppManager weekBegin];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitWeekday value:7 toDate:startDate options:0];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
}

+ (NSDate *)monthBegin {
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday  fromDate:nowDate];
    return [calendar dateWithEra:1 year:comp.year month:comp.month day:1 hour:0 minute:0 second:0 nanosecond:0];
}
// 本周的时间段
+ (NSPredicate *)predicateMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [HealthAppManager monthBegin];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitMonth value:31 toDate:startDate options:0];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
}

#pragma mark 添加数据
- (void)addStepCount:(double)count WithBlock:(void(^)(double value, NSError *error))block {
    HKQuantitySample *stepCorrelationItem = [self stepsCountQuantitySample:count];
    [self.healthStore saveObject:stepCorrelationItem withCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) { // 写入成功
                // MARK: 获取步数
            }else {
                // 添加失败
                
            }
        });
    }];
}

/// 步数单位
- (HKQuantitySample *)stepsCountQuantitySample:(double)stepNum {
    NSDate *endDate = [NSDate date];
    // TODO: XB 这个需要修改
//    int startTime = fs_sport.time_s.intValue;
    int startTime = 100;
    NSDate *startDate = [NSDate dateWithTimeInterval:-startTime sinceDate:endDate];
    HKQuantity *stepQuantityConsumed = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:stepNum];
    HKQuantityType *stepConsumedType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantitySample *stepConsumedSample = [HKQuantitySample quantitySampleWithType:stepConsumedType quantity:stepQuantityConsumed startDate:startDate endDate:endDate];
    return stepConsumedSample;
}

- (void)addWalkRunDistance:(double)dist WithBlock:(void(^)(double value, NSError *error))block {
    HKQuantitySample *diatanceItem = [self walkingQuantitySample:dist];
    [self.healthStore saveObject:diatanceItem withCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) { // 写入成功
            } else {
                // 添加失败
            }
        });
    }];
}

- (HKQuantitySample *)walkingQuantitySample:(double)distance {
    NSDate *endDate = [NSDate date];
    // TODO: XB 这个需要修改
//    int startTime = fs_sport.time_s.intValue;
    int startTime = 100;
    NSDate *startDate = [NSDate dateWithTimeInterval:-startTime sinceDate:endDate];
    // 单位 米
    HKQuantity *stepQuantityConsumed = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:distance];
    HKQuantityType *stepConsumedType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantitySample *stepConsumedSample = [HKQuantitySample quantitySampleWithType:stepConsumedType quantity:stepQuantityConsumed startDate:startDate endDate:endDate];
    return stepConsumedSample;

}

- (void)addCalory:(double)calory WithBlock:(void(^)(double value, NSError *error))block {
    HKQuantitySample *caloryItem = [self caloryQuantitySample:calory];
    [self.healthStore saveObject:caloryItem withCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) { // 写入成功
            } else {
                // 添加失败
            }
        });
    }];
}

- (HKQuantitySample *)caloryQuantitySample:(double)calory {
    NSDate *endDate = [NSDate date];
    // TODO: XB 这个需要修改
//    int startTime = fs_sport.time_s.intValue;
    int startTime = 100;
    NSDate *startDate = [NSDate dateWithTimeInterval:-startTime sinceDate:endDate];
    // 单位 千卡  版本有区别
    HKQuantity *quantityConsumed;
    if (@available(iOS 11.0, *)) {
        quantityConsumed = [HKQuantity quantityWithUnit:[HKUnit largeCalorieUnit] doubleValue:calory];
    } else {
        quantityConsumed = [HKQuantity quantityWithUnit:[HKUnit calorieUnit] doubleValue:calory];
    }
    HKQuantityType * caloryConsumedType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantitySample *caloryConsumedSample = [HKQuantitySample quantitySampleWithType:caloryConsumedType quantity:quantityConsumed startDate:startDate endDate:endDate];
    return caloryConsumedSample;

}

@end

// HKQuantityTypeIdentifierBodyMassIndex  体重指标
// HKQuantityTypeIdentifierBodyFatPercentage 体脂肪率
// HKQuantityTypeIdentifierHeight  身高
// HKQuantityTypeIdentifierBodyMass 体重
// HKQuantityTypeIdentifierLeanBodyMass 去脂肪体重
// HKQuantityTypeIdentifierWaistCircumference 腰围 11.0
// HKQuantityTypeIdentifierStepCount  步行
// HKQuantityTypeIdentifierDistanceWalkingRunning  步行+跑步距离
// HKQuantityTypeIdentifierDistanceCycling 踩单车距离
// HKQuantityTypeIdentifierDistanceWheelchair 轮椅距离
// HKQuantityTypeIdentifierBasalEnergyBurned 静态能量
// HKQuantityTypeIdentifierActiveEnergyBurned 动态能量
// HKQuantityTypeIdentifierFlightsClimbed 已步行层数
// HKQuantityTypeIdentifierNikeFuel 不能访问，会闪退，可理解为私有api
// HKQuantityTypeIdentifierAppleExerciseTime 不能访问，会闪退，可理解为私有api
// HKQuantityTypeIdentifierPushCount  推动次数
// HKQuantityTypeIdentifierDistanceSwimming  游泳距离
// HKQuantityTypeIdentifierSwimmingStrokeCount 划水次数
// HKQuantityTypeIdentifierVO2Max  最大摄氧量 11.0
// HKQuantityTypeIdentifierDistanceDownhillSnowSports 高山雪地运动距离 11.2
// HKQuantityTypeIdentifierAppleStandTime 这个不知道什么鬼  13
// HKQuantityTypeIdentifierWalkingSpeed 步行速度 14.0
// HKQuantityTypeIdentifierWalkingDoubleSupportPercentage 14.0
// HKQuantityTypeIdentifierWalkingAsymmetryPercentage 14.0
// HKQuantityTypeIdentifierWalkingStepLength
// HKQuantityTypeIdentifierSixMinuteWalkTestDistance
// HKQuantityTypeIdentifierStairAscentSpeed
// HKQuantityTypeIdentifierStairDescentSpeed
// HKQuantityTypeIdentifierAppleMoveTime 14.5
// HKQuantityTypeIdentifierAppleWalkingSteadiness 15.0
// HKQuantityTypeIdentifierHeartRate 心率
// HKQuantityTypeIdentifierBodyTemperature 体温
// HKQuantityTypeIdentifierBasalBodyTemperature 基础体温
// HKQuantityTypeIdentifierBloodPressureSystolic 收缩压、上压、高压
// HKQuantityTypeIdentifierBloodPressureDiastolic 舒张压、下压、抵压
// HKQuantityTypeIdentifierRespiratoryRate  呼吸率
// HKQuantityTypeIdentifierRestingHeartRate 静止心率  11.0
// HKQuantityTypeIdentifierWalkingHeartRateAverage 不允许访问
// HKQuantityTypeIdentifierHeartRateVariabilitySDNN 心率** 11.0
// HKQuantityTypeIdentifierOxygenSaturation 氧饱和度
// HKQuantityTypeIdentifierPeripheralPerfusionIndex 周边血管灌注指数
// HKQuantityTypeIdentifierBloodGlucose  血糖
// HKQuantityTypeIdentifierNumberOfTimesFallen 跌倒次数
// HKQuantityTypeIdentifierElectrodermalActivity 皮胃电活动
// HKQuantityTypeIdentifierInhalerUsage 吸入器用量
// HKQuantityTypeIdentifierInsulinDelivery 胰岛素治疗 11.0
// HKQuantityTypeIdentifierBloodAlcoholContent 血液酒精浓度
// HKQuantityTypeIdentifierForcedVitalCapacity 最大肺活量
// HKQuantityTypeIdentifierForcedExpiratoryVolume1 一秒呼吸量
// HKQuantityTypeIdentifierPeakExpiratoryFlowRate 最高呼气流量率
// HKQuantityTypeIdentifierEnvironmentalAudioExposure 13.0
// HKQuantityTypeIdentifierHeadphoneAudioExposure 13.0
// HKQuantityTypeIdentifierNumberOfAlcoholicBeverages 15.0
// HKQuantityTypeIdentifierDietaryFatTotal 总脂肪
// HKQuantityTypeIdentifierDietaryFatPolyunsaturated 多元不饱和脂肪
// HKQuantityTypeIdentifierDietaryFatMonounsaturated 单元不饱和脂肪
// HKQuantityTypeIdentifierDietaryFatSaturated 饱和脂肪
// HKQuantityTypeIdentifierDietaryCholesterol 膳食胆固醇
// HKQuantityTypeIdentifierDietarySodium 纳质
// HKQuantityTypeIdentifierDietaryCarbohydrates 碳水化合物
// HKQuantityTypeIdentifierDietaryFiber 纤维
// HKQuantityTypeIdentifierDietarySugar 膳食糖分
// HKQuantityTypeIdentifierDietaryEnergyConsumed 膳食能量
// HKQuantityTypeIdentifierDietaryProtein 蛋白质
// HKQuantityTypeIdentifierDietaryVitaminA 维他命A
// HKQuantityTypeIdentifierDietaryVitaminB6 维他命B6
// HKQuantityTypeIdentifierDietaryVitaminB12 维他命B12
// HKQuantityTypeIdentifierDietaryVitaminC 维他命C
// HKQuantityTypeIdentifierDietaryVitaminD 维他命D
// HKQuantityTypeIdentifierDietaryVitaminE 维他命E
// HKQuantityTypeIdentifierDietaryVitaminK 维他命K
// HKQuantityTypeIdentifierDietaryCalcium  钙质
// HKQuantityTypeIdentifierDietaryIron     铁
// HKQuantityTypeIdentifierDietaryThiamin 硫铵
// HKQuantityTypeIdentifierDietaryRiboflavin 核黄素
// HKQuantityTypeIdentifierDietaryNiacin 碳烟酸
// HKQuantityTypeIdentifierDietaryFolate 叶酸
// HKQuantityTypeIdentifierDietaryBiotin 生物素
// HKQuantityTypeIdentifierDietaryPantothenicAcid 泛酸
// HKQuantityTypeIdentifierDietaryPhosphorus 磷质
// HKQuantityTypeIdentifierDietaryPhosphorus 碘
// HKQuantityTypeIdentifierDietaryMagnesium 镁
// HKQuantityTypeIdentifierDietaryZinc 锌
// HKQuantityTypeIdentifierDietarySelenium 硒
// HKQuantityTypeIdentifierDietaryCopper 铜
// HKQuantityTypeIdentifierDietaryManganese 锰
// HKQuantityTypeIdentifierDietaryChromium 铬
// HKQuantityTypeIdentifierDietaryMolybdenum 钼
// HKQuantityTypeIdentifierDietaryChloride 氯化物
// HKQuantityTypeIdentifierDietaryPotassium 钾
// HKQuantityTypeIdentifierDietaryCaffeine 咖啡因
// HKQuantityTypeIdentifierDietaryWater 水
// HKQuantityTypeIdentifierUVExposure 紫外线指数
