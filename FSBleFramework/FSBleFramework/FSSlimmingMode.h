

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSSlimmingMode : NSObject

/// 0：停止：停止运动  1：运行：开始运动
@property (nonatomic, assign) int run;
/// 单位为分钟/秒，不管APP给液晶面板发什么数据，面板上就显示什么数据，而不需要判断是分钟还是秒。
@property (nonatomic, assign) int time;
/// 范围为1~100，速度设定必须在手动模式和运行的条件下设置才有效，自动模式和停止状态下设定无效
@property (nonatomic, assign) int speed;
/// 手动档和自动档标志位，1为手动，0为自动。自动模式P1~P3，手动模式
@property (nonatomic, assign) long mode;

@end


// 甩脂机  才需要用的设备 参数
@interface FSParams : NSObject

@property (nonatomic, strong) NSNumber *max_speed;

@property (nonatomic, strong) NSNumber *max_time;

@property (nonatomic,   copy) NSString *max_resistance;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

// 甩脂机 才需要用的点击模式
@interface FSMotors : NSObject

@property (nonatomic,   copy) NSString *cmd;

@property (nonatomic, strong) NSNumber *device_id;

@property (nonatomic,   copy) NSString *image;

@property (nonatomic,   copy) NSString *name;

@property (nonatomic, assign) BOOL     isSelected;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
