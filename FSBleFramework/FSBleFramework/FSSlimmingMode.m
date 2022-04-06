
/*
 校验码:Byte0
 器材识别:Byte1
 运行/停止:Byte2      0：停止：停止运动  1：运行：开始运动
 时间设定/显示:Byte3   单位为分钟/秒，不管APP给液晶面板发什么数据，面板上就显示什么数据，而不需要判断是分钟还是秒。
 速度设定/显示:Byte4 范围为1~100，速度设定必须在手动模式和运行的条件下设置才有效，自动模式和停止状态下设定无效
 模式设定/显示:Byte5 手动档和自动档标志位，1为手动，0为自动。自动模式P1~P3，手动模式
 上一曲/下一曲:Byte6 0：未操作 1：上一曲 2：下一曲
 音乐播放/停止:Byte7 0：停止播放音乐 1：播放音乐
 音量控制:Byte8     0：未操作音量，不加不减  1：音量加  2：音量减
 待机:Byte9        0：不待机  1：待机
 校验和:Byte10
 */

#import "FSSlimmingMode.h"

@implementation FSSlimmingMode

- (instancetype)init {
    if (self = [super init]) {
        self.speed = 1;
    }
    return self;
}

@end

@implementation FSParams

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dic {
    return [[self alloc] initWithDictionary:dic];
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"FSParams::没定义的key");
}

@end

@implementation FSMotors

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dic {
    return [[self alloc] initWithDictionary:dic];
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"FSMotors::  没定义的key");
}

@end
