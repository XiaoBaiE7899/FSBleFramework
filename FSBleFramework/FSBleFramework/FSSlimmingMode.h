

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 甩脂机的点击模式
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

// 最大速度
@property (nonatomic, strong) NSNumber *max_speed;

// 最大时间
@property (nonatomic, strong) NSNumber *max_time;

// 最大阻力  运动秀项目添加的，SCZG，最后CZDL放弃使用
@property (nonatomic,   copy) NSString *max_resistance;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

// 甩脂机 才需要用的点击模式
@interface FSMotors : NSObject

// 甩脂机的指令
@property (nonatomic,   copy) NSString *cmd;

// 设备id
@property (nonatomic, strong) NSNumber *device_id;

// 图片
@property (nonatomic,   copy) NSString *image;

// 名字
@property (nonatomic,   copy) NSString *name;

// 是否选中
@property (nonatomic, assign) BOOL     isSelected;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
