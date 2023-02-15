
#import "BleDevice.h"
#import "FSBleDeice.h"
#import "BleModule.h"
#import "FSManager.h"
#import "FSBleTools.h"
#import "FSSlimmingMode.h"
#import "NSDictionary+fsExtent.h"
#import "NSString+fsExtent.h"
#import "FSSport.h"

NSString * _Nonnull const CHAR_READ_MFRS    = @"2A29"; // 厂家
NSString * _Nonnull const CHAR_READ_PN      = @"2A24"; // 型号
NSString * _Nonnull const CHAR_READ_HV      = @"2A27"; // 硬件版本
NSString * _Nonnull const CHAR_READ_SV      = @"2A28"; // 软件版本
NSString * _Nonnull const CHAR_NOTIFY_UUID  = @"FFF1"; // 通知通道
NSString * _Nonnull const CHAR_WRITE_UUID   = @"FFF2"; // 写入通道


@implementation FSDeviceParam

- (instancetype)init {
    if (self = [super init]) {
        self.imperial       = NO;
        self.maxSpeed       = @"0";
        self.minSpeed       = @"0";
        self.maxIncline     = @"0";
        self.minIncline     = @"0";
        self.maxLevel       = @"0";
        self.minLevel       = @"0";
        self.paragraph      = @"0";
        self.supportIncline = NO;
        self.supportLevel   = NO;
        self.supportControl = NO;
        self.supportSpeed   = NO;
        self.supportPause   = NO;
        self.totalDistance  = @"0";
    }
    return self;
}

- (BOOL)supportControl {
    if (self.supportSpeed ||
        self.supportLevel ||
        self.supportIncline) {
        return YES;
    }
    return NO;
}

@end

@implementation FSDeviceInfo

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
}

- (FSParams *)paramModel {
    FSParams *model = [FSParams new];
    if (kFSIsEmptyString(self.paramString)) {
        return model;
    }
    
    NSDictionary *dic = /*[FSBleTools jsonStingToDictionary:self.paramString]*/self.paramString.fsToDictionary();
    model = [FSParams modelWithDictionary:dic];
    return model;
}

- (NSArray<FSMotors *> *)motorModels {
    NSArray *arr = /*[FSBleTools jsonStingToArray:self.motorModeString]*/self.motorModeString.fsToArray();
    switch (self.type.intValue) {
        case FSSportTypeSlimming: {
            if (arr) {
                NSMutableArray *data = NSMutableArray.array;
                for (NSDictionary *dic in arr) {
                    FSMotors *param = [FSMotors modelWithDictionary:dic];
                    [data addObject:param];
                }
                return data;
            }
        }
            break;
        default:
            break;
    }
    return nil;
}

@end

@implementation FSBaseDevice

- (instancetype)initWithModule:(BleModule *)module {
    if (self = [super initWithModule:module]) {
        [self dataReset];
        // 设备参数初始化
        self.deviceParam = [FSDeviceParam new];
        // 设备信息初始化
        self.deviceInfo = [FSDeviceInfo new];
        // 获取设备信息 环球项目不需要去获取数据
        // [self pullDeviceInfo];
    }
    return self;
}


- (BOOL)moduleInfoAgterConnented:(CBCharacteristic *)chat {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    NSArray     *arr       = @[CHAR_READ_MFRS, CHAR_READ_PN, CHAR_READ_HV, CHAR_READ_SV];
    NSData      *data      = chat.value;
    NSUInteger  len        =  data.length;
    Byte        *databytes = (Byte *)[data bytes];
    NSString *string = @"";
    for (int i = 0; i < len; i++) {
        uint16_t temp = databytes[i];
        NSString *str = FSFM(@"%c", temp);
        string = [string stringByAppendingString:str];
    }
    if ([chat.UUID.UUIDString isEqualToString:CHAR_READ_MFRS]) {
        self.module.manufacturer = string;
    } else if ([chat.UUID.UUIDString isEqualToString:CHAR_READ_PN]) {
        self.module.model        = string;
    } else if ([chat.UUID.UUIDString isEqualToString:CHAR_READ_HV]) {
        self.module.hardware     = string;
    } else if ([chat.UUID.UUIDString isEqualToString:CHAR_READ_SV]) {
        self.module.software     = string;
    }
    return [arr containsObject:chat.UUID.UUIDString];
}

- (BOOL)onService {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    CBUUID  *server = UUID(FITSHOW_UUID);
    CBUUID  *send   = UUID(CHAR_WRITE_UUID);
    CBUUID  *recv   = UUID(CHAR_NOTIFY_UUID);
    NSArray *arr    = @[CHAR_READ_MFRS, CHAR_READ_PN, CHAR_READ_HV, CHAR_READ_SV];
    for (CBService *s in self.module.services) {
        [s.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // FIXME: 读取以下这些信息，应该确保通知通道已经打开，否则有可能造成数据为空，添加以后读取都没问题，这个问题暂时没处理
            if ([arr containsObject:obj.UUID.UUIDString]) {
                [self.module.peripheral readValueForCharacteristic:obj];
            }
        }];
        if ([s.UUID isEqual:server]) {
            for (CBCharacteristic *c in s.characteristics) {
                if ([c.UUID isEqual:recv]) {
                    self.bleNotifyChar = c;
                    [s.peripheral setNotifyValue:YES forCharacteristic:c];
                } else if ([c.UUID isEqual:send]) {
                    self.bleWriteChar = c;
                }
            }
        }
    }

    if (self.bleNotifyChar && self.bleWriteChar) {
        fs_sport.fsDevice = self;
        return YES;
    }

    return NO;
}

- (void)onDisconnected {
    [self.sendCmdTimer invalidate];
    self.sendCmdTimer = nil;
    [self.heartbeatTmr invalidate];
    self.heartbeatTmr = nil;
    // 调用父类的方法，设置连接的状态为：没有连接
    [super onDisconnected];
}



- (void)dataReset {
//    FSLog(@"%@", NSStringFromSelector(_cmd));
    self.isStarting       = NO;
    self.isRunning        = NO;
    self.isPausing        = NO;
    self.isWillStart      = NO;
    self.hasStoped        = NO;
    self.oldStatus        = FSDeviceStateDefault;
    self.currentStatus    = FSDeviceStateDefault;
    self.speed            = @"0";
    self.incline          = @"0";
    self.exerciseTime     = @"0";
    self.heartRate        = @"0";
    self.errorCode        = @"0";
    self.weight           = @"0";
    self.height           = @"0";
    self.age              = @"0";
    self.gender           = @"0";
    self.adjustSpeed      = @"0";
    self.adjustIncline    = @"0";
    self.resistance       = @"0";
    self.frequency        = @"0";
    self.countdownSeconds = @"0";
    self.watt             = @"0";
    self.distance         = @"0";
    self.calory           = @"0";
    self.steps            = @"0";
    self.counts           = @"0";
    self.paragraph        = @"0";
    self.uid              = @"0";
    self.stopWithCmd      = NO;
    self.discontrolType   = FSDiscontrolTypeNone;
    self.subSafeCode      = 0;
}

- (void)updateState:(NSTimer *__nullable)sender {
}

- (void)updateDeviceParams {
}

- (void)sendData:(NSData *)data {
    BleCommand *cmd = [BleCommand make:self.bleWriteChar data:data];
    
    [self sendCommand:cmd];
}


- (BOOL)start {
    return YES;
}

- (void)stop {}

- (void)targetSpeed:(int)targetSpeed incline:(int)targetIncline {}

- (void)setTargetLevl:(int)t_level incline:(int)t_incline {}

//- (void)sendData:(NSData *)data {
//    Command *cmd = [Command make:self.bleWriteChar data:data];
//    [self sendCommand:cmd];
//    BleCommand *cmd = [BleCommand m]
//}

// 重启模块
- (void)fsRestartBleModule {
    uint8_t cmd[] = {0x02,0x60, 0x0A, 0x00, 0x03};
    NSData *rst = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    [self sendData:rst];
}

- (void)minDeviceCnts:(NSInteger)cnt {}
- (void)minDeviceTime:(NSInteger)time {}
- (void)minPause {}
- (void)minRestore {}

// 甩脂机
// 甩脂机的程序模式
- (void)slimmingStartParagram {}

// 甩脂机  控制速度
- (void)slimmingTargetSpeed:(int)speed {}

// 甩脂机  控制时间
- (void)slimmingTargetTime:(int)time {}

/// 发送相同时间还是无效
/// 修改时间 加randomNum参数是为了避免与上一条指令一模一样而设备不响应
- (void)slimmingTargetTime:(int)time randomNum:(int)randomNum {}

/// 甩脂机 切换模式
- (void)slimmingSwitchMode {}

// 21.12.16 power_cmd
- (void)cleanAll {}
- (void)cleanCals {}
- (void)cleanCnts {}
- (void)cleanTime {}

- (int)paramRangeOfMax:(int)maxValue min:(int)minValue compare:(int)value {
    if (value > maxValue) return maxValue;
    if (value < minValue) return minValue;
    return value;
}

// MARK:  坡度阻力是有符号的整形，因此如果小于0，要转换数据数据
- (int)signedParam:(int)value {
    if (value < 0) {
        int targetVlue = 256 - value * (-1);
        return targetVlue;
    }
    if (value == 256) {
        return 0;
    }
    return value;
}

#pragma mark 内部方法
- (void)pullDeviceInfo {
    NSString *type        = [NSString stringWithFormat:@"%d", self.module.sportType];
//    NSString *factory     = self.module.factory;
//    NSString *machineCode =  self.module.machineCode;
    
//    FSLog(@"SDK 获取设备信息");
    
    FSDeviceInfo *deviceInfo = [FSBleTools readDeviceInfoFromPlistFile:self];
    
    if (deviceInfo) {
        // plist 文件已经存在，直接读取数据, 在方法内部直接对设备信息赋值，这里可以直接返回
        self.deviceInfo = deviceInfo;
        return;
    }
    
    // @"https://api.fitshow.com/api/device/getdeviceinfo/"
    

    NSDictionary *dic = @{
        @"factory" : self.module.factory,
        @"model" : self.module.machineCode,
        @"type" : type
    };
    
//    NSString *urlString = @"https://api.fitshow.com/api/device/getdeviceinfo/";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fs_sport.hostUrl]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 30;
    // 设备组请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *paramData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = paramData;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([self.module.name isEqualToString:@"FS-123456"]) {
//                FSLog(@"获取数据 类型%d  厂商%@  机型%@", self.module.sportType, self.module.factory, self.module.model);
                
//            }
            // 回调数据
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                // 需要判断 数据是否正确性
                if([dic objectForKey:@"code"]) {
                    NSNumber *code = dic[@"code"];
                    if (code.integerValue == 1) { // 只有这个状态才有数据
                        // !!!:  22.7.8 添加数据安全过滤
                        if (![dic[@"data"] isKindOfClass:[NSDictionary class]]) {
                            return;
                        }
                        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:dic[@"data"]];
                        if ([info objectForKey:@"params"]) {
                            info[@"paramString"] = /*[FSBleTools ditionaryToJsonSting:dic[@"params"]]*/dic.fsToJsonString();
                            [FSBleTools createDeviceInfoPlistFileWith:@[info]];
                        }
                        
                        if ([info objectForKey:@"motorMode"]) {
                            info[@"motorModeString"] = /*[FSBleTools ditionaryToJsonSting:dic[@"motorMode"]]*/dic.fsToJsonString();
                            [FSBleTools createDeviceInfoPlistFileWith:@[info]];
                        }
                        
                    }
                }
            }
            
            if (error) {
//                FSLog(@"获取设备信息失败，%@", error);
            }
            
        });
        
    }];
    
    [task resume];
    
    
}

#pragma mark setter && getter
- (NSString *)display_speed {
    if (self.module.isTreadmillProtocol) { // 跑步机的速度要除以10
//        return [NSString stringWithFormat:@"%.1f", self.speed.intValue / 10.0];
        return self.speed.fsDiv(@"10").decimalPlace(1);
    }
    
    if (self.module.isSectionProtocol) { // 车表的速度除以100
        return self.speed.fsDiv(@"100").decimalPlace(1);
//        return [NSString stringWithFormat:@"%.1f", self.speed.intValue / 100.0];
    }
    return self.speed;
}

- (NSString *)displayDistance {
    // 22.6.8  距离保留2位小数
    return self.distance.fsDiv(@"1000").decimalPlace(2);
//    return [NSString stringWithFormat:@"%.1f", self.distance.intValue / 1000.0];
}

- (NSString *)calculateDist {
    if (self.deviceParam.imperial) { // 英制单位
        return self.distance.fsMul(@"1.60934").decimalPlace(0);
    }
    // 公制单位
    return self.distance;
}

@end




