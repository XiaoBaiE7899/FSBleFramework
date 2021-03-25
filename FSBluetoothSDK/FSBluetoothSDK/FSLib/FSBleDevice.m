
#import "FSBleDevice.h"
#import "FSLibHelp.h"



@interface FSBleDevice ()

/* 模块厂商 */
@property (nonatomic) NSString   * _Nullable manufacturer;

/* 模块机型 */
@property (nonatomic) NSString   * _Nullable model;

/* 硬件版本 */
@property (nonatomic) NSString   * _Nullable hardware;

/* 软件版本 */
@property (nonatomic) NSString   * _Nullable software;

/*是否为英制单位 0:公里  1: 英里  1英里(mi) = 1.60934千米(公里) */
@property (nonatomic) BOOL imperial;

/* 最大速度 */
@property (nonatomic) NSString *maxSpeed;

/* 最小速度 */
@property (nonatomic) NSString *minSpeed;

/* 最大坡度 */
@property (nonatomic) NSString *maxIncline;

/* 最小坡度 */
@property (nonatomic) NSString *minIncline;

/* 最大阻力 */
@property (nonatomic) NSString *maxLevel;

/* 最小阻力 */
@property (nonatomic) NSString *minLevel;

/* 车表段数 */
@property (nonatomic) NSString *paragraphs;

/* 坡度是否支持控制 */
@property (nonatomic) BOOL           supportIncline;

/* 阻力是否支持控制 */
@property (nonatomic) BOOL           supportLevel;

/* 速度是否支持控制 */
@property (nonatomic) BOOL           supportSpeed;

/* 是否支持控制 速度、坡度、阻力只要有一个可以控制，这个设置就可以控制 */
@property (nonatomic) BOOL           supportControl;

/* 是否支持暂停 */
@property (nonatomic) BOOL           supportPause;

/* 设备总里程 */
@property (nonatomic) NSString      *totalDistance;

#pragma mark 设备的实时数据

/* 设备的旧状态 初始化状态：-1 */
@property (nonatomic) NSString      *oldStatus;

/* 设备的新状态 初始化状态：-1 */
@property (nonatomic) NSString      *currentStatus;

/* 速度 区分英制单位&公制单位 */
@property (nonatomic) NSString *speed;

/* 坡度 */
@property (nonatomic) NSString *incline;

/* 运动时长 秒 */
@property (nonatomic) NSString *eElapsedTime;

/* 运动距离 区分英制单位&公制单位 */
@property (nonatomic) NSString *distance;

/* 消耗的卡路里 单位没写，有点麻烦 */
@property (nonatomic) NSString *calory;

/* 步数 */
@property (nonatomic) NSString *steps;

/* 次数 */
@property (nonatomic) NSString *counts;

/* 心率 */
@property (nonatomic) NSString *heartRate;

/* 段数 */
@property (nonatomic) NSString *paragraph;

/* 错误码 */
@property (nonatomic) NSString *errorCode;

/* 运动ID */
@property (nonatomic) NSString *uid;

/* 体重 */
@property (nonatomic) NSString *weight;

/* 身高 */
@property (nonatomic) NSString *height;

/* 年龄 */
@property (nonatomic) NSString *age;

/* 性别 */
@property (nonatomic) NSString *gender;

/* 调整速度 */
@property (nonatomic) NSString *adjustSpeed;

/* 调整坡度 */
@property (nonatomic) NSString *adjustSlope;

/* 阻力 */
@property (nonatomic) NSString *level;

/* 频率 */
@property (nonatomic) NSString *frequency;

/* 启动倒计时秒数 */
@property (nonatomic) NSString *second;

/* 功率 */
@property (nonatomic) NSString *watt;

/* 心跳包定时器 */
@property (nonatomic, strong) NSTimer *heartbeatTimer;

@end

@implementation FSBleDevice

#pragma mark 重写父类的方法
- (BOOL)onService {
    FSLog(@"执行子类onService");
    CBUUID *server = UUID(SERVICES_UUID); // 服务
    CBUUID *send = UUID(CHAR_WRITE_UUID); // 写特征
    CBUUID *recv = UUID(CHAR_NOTIFY_UUID); //听特征
    for (CBService *s in self.module.services) {
        // 读取数据
        [s.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.UUID.UUIDString isEqualToString:CHAR_READ_MFRS] || // 获取厂家
                [obj.UUID.UUIDString isEqualToString:CHAR_READ_PN]   || // 获取型号
                [obj.UUID.UUIDString isEqualToString:CHAR_READ_HV]   || // 硬件版本
                [obj.UUID.UUIDString isEqualToString:CHAR_READ_SV]      // 获取软件版本
                ) {
                [self.module.peripheral readValueForCharacteristic:obj];
            }

            // 查找 指定服务下的 通知通道&可写通道
            if ([s.UUID isEqual:server]) {
                for (CBCharacteristic *c in s.characteristics) {
                    if ([c.UUID isEqual:recv]) { // 通知通道
                        [self setValue:c forKeyPath:@"bleNotifyChar"];
                        [s.peripheral setNotifyValue:YES forCharacteristic:c];
                    } else if ([c.UUID isEqual:send]) { // 可写通道
                        [self setValue:c forKeyPath:@"bleWriteChar"];
                    }
                }
            }
        }];

    }
    // 通知通道  && 可写通道都找打了  才能返回yes,
    if (self.bleNotifyChar && self.bleWriteChar) {
        return YES;
    }
    // 回调找不到服务
    if (self.fsDeviceDeltgate && [self.fsDeviceDeltgate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
        [self disconnect:DisconnectTypeService];
        [self.fsDeviceDeltgate device:self didDisconnectedWithMode:DisconnectTypeService];
    }
    return NO;
}

- (void)onConnected {
    FSLog(@"执行子类onConnected");
    // 已连上的方法
}

- (void)onDisconnected {
    FSLog(@"执行子类onDisconnected");
}

#pragma mark 对外开放方法
// 发送速度指令
- (void)sendTargetSpeed:(int)speed {

}

// 发送坡度指令
- (void)sendTargetIncline:(int)incline {

}

// 发送阻力指令
- (void)sendTargetLevel:(int)level {

}

// 暂停设备
- (void)pause {

}

// 停止设备
- (void)stop {

}

// 恢复设备
- (void)resume {

}

#pragma mark setter && getter
- (UIImage *)fsDefaultImage {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"FSDeiveceDefImg" ofType:@"bundle"];
    if (!bundlePath) {
        FSLog(@"bundle 文件为空，直接返回空");
        return nil;
    }

    NSString *str = FSSF(@"device_deficon_%ld.png", (long)self.module.type);
    UIImage *iconImage = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:str]];
    if (!iconImage) {
        FSLog(@"bundle 文件找不到图片，直接返回空");
        return nil;
    }
    return iconImage;
}

#pragma mark 蓝牙指令公用方法
- (NSDateComponents *)systemtime:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
//    NSDate *date = [NSDate date];
    comps = [calendar components:unitFlags fromDate:date];
    return comps;
}
// 发送数据准备
- (NSData *)prepareSendData:(UInt8 *)data length:(int)len {
    UInt8 crc = [self checkCrcCode:data length:len];
    data[len - 2] = crc;
    NSData *rst = [NSData dataWithBytes:data length:len];
    return rst;
}

// 计算校验码
- (UInt8)checkCrcCode:(UInt8 *)data length:(int)len {
    uint16_t crc = data[0];
    for (int i = 1; i < len; i++) {
        crc =  crc^data[i];
    }
    crc = (crc & 0xff);
    return crc;
}

// 获取蓝牙模块信息
- (NSData *)cmdFSModuleInfo {
    NSDate *date = [NSDate date];
    int year   = (int)[self systemtime:date].year;
    year = year & 0xff;
    int month  = (int)[self systemtime:date].month;
    int day    = (int)[self systemtime:date].day;
    int hour   = (int)[self systemtime:date].hour;
    int minute = (int)[self systemtime:date].minute;
    int second = (int)[self systemtime:date].second;
    uint8_t cmd[] = {BLE_CMD_START, TreadmillInfo, TreadmillInfoModel, year, month, day, hour, minute, second, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

#pragma mark 跑步机指令
/// 获取跑步机速度参数
- (NSData *)cmdTreadmillSpeedParam {
    uint8_t cmd[] = {BLE_CMD_START, TreadmillInfo, TeadmillInfoSpeed, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 获取跑步机坡度参数
- (NSData *)cmdTreadmillInclineParam {
    uint8_t cmd[] = {BLE_CMD_START,TreadmillInfo, TeadmillInfoIncline, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 累计里程
- (NSData *)cmdTreadmillTotalInfo {
    uint8_t cmd[] = {BLE_CMD_START,TreadmillInfo, TeadmillInfoTotal, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 跑步机状态
- (NSData *)cmdTreadmillStatus {
    // 发送指令以后会返回 设备的状态
    uint8_t cmd[] = {BLE_CMD_START, TreadmillStatus, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 启动跑步机
- (NSData *)cmdTreadmillStart {
    uint8_t cmd[] = {BLE_CMD_START, TreadmillControl, TreadmillControlReady, 0x00, 0x00, 0x00, 0x00, TreadmillStartModeNormal, 0x00, 0x00, 0x00, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 恢复跑步机
- (NSData *)cmdTreadmillResume {
    uint8_t cmd[] = {BLE_CMD_START, TreadmillControl, TreadmillControlStart,0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 停止跑步机
- (NSData *)cmdTreadmillStop {
    uint8_t cmd[] = {BLE_CMD_START, TreadmillControl,
    TreadmillControlStop,0, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

// 固定时间
- (NSData *)fixedTime:(uint)second {
    uint8_t timelow = second & 0xff;
    uint8_t timehigh = (second >> 8) & 0xff;
    uint8_t cmd[] = {BLE_CMD_START, TreadmillControl, TreadmillControlReady, 0x00, 0x00, 0x00, 0x00, TreadmillStartModeTimer, 0x00, timelow, timehigh, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

// 固定距离
- (NSData *)fixedDistance:(uint)distance {
    uint8_t distancelow = distance & 0xff;
    uint8_t distancehigh = (distance >> 8) & 0xff;
    uint8_t cmd[] = {BLE_CMD_START, TreadmillControl, TreadmillControlReady, 0x00, 0x00, 0x00, 0x00, TreadmillStartModeDistance, 0x00, distancelow, distancehigh, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

// 固定卡路里
- (NSData *)fixedCaloriesr:(int)calory {
    calory = calory * 10;
    uint8_t calorylow = calory & 0xff;
    uint8_t caloryhigh = (calory >> 8) & 0xff;
    uint8_t cmd[] = {BLE_CMD_START, TreadmillControl, TreadmillControlReady, 0x00, 0x00, 0x00, 0x00, TreadmillStartModeCalorises, 0x00, calorylow, caloryhigh, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 暂停
- (NSData *)cmdTreadmillPause {
    uint8_t cmd[] = {BLE_CMD_START, TreadmillControl,
    TreadmillControlStop,0, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 控制速度和坡度
- (NSData *)cmdControlDeviceSpeed:(int)v incline:(int)p {
    uint8_t cmd[] = {BLE_CMD_START, TreadmillControl, TreadmillControlTarget, v, p,0, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 读取跑步机当前运动量
- (NSData *)cmdTreadmillSportData {
    uint8_t cmd[] = {BLE_CMD_START, TreadmillData, TreadmillDataSport, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 跑步机当前运动信息
- (NSData *)cmdTreadmillData {
    uint8_t cmd[] = {BLE_CMD_START, TreadmillData, TreadmillDataInfo, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

#pragma mark 车表指令
/// 获取车表设备参数0x02 0x41 0x02 0x40 0x03：  阻力B  坡度B  配置B  段数B
- (NSData *)cmdSectionParamInfo {
    uint8_t cmd[] = {BLE_CMD_START, SectionParam, SectionParamInfo, 0x40, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 获取车表累计值0x02 0x41 0x03 0x42 0x03：
- (NSData *)cmdSectionParamTotal {
    uint8_t cmd[] = {BLE_CMD_START, SectionParam, SectionParamTotal, 0x42, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 同步时间：传入数据  年月日周时分秒 年传入后2位
- (NSData *)cmdSectionParamDate {
    // 指令 0x02 0x41 0x04 时间(7) xx 0x03
    // 数据 0x02 0x41 0x04 0x45 0x03
    NSDate *date = [NSDate date];
    int year   = (int)[self systemtime:date].year;
    year = year & 0xff;
    int month  = (int)[self systemtime:date].month;
    int weeday = (int)[self systemtime:date].weekday;
    int day    = (int)[self systemtime:date].day;
    int hour   = (int)[self systemtime:date].hour;
    int minute = (int)[self systemtime:date].minute;
    int second = (int)[self systemtime:date].second;
    uint8_t cmd[] = {BLE_CMD_START, SectionParam, SectionParamDate, year, month, day, weeday, hour, minute, second, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 车表状态
- (NSData *)cmdSectionStatue {
    // 指令 0x02 0x43 0x01 0x42 0x03
    // 数据
    uint8_t cmd[] = {BLE_CMD_START, SectionStatus, 0x42, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 当前运动量信息
- (NSData *)cmdSectionDada {
    // 指令 0x02 0x43 0x01 0x42 0x03
    // 数据 0x02 0x43 0x01 时间(W) 距离(W) 热量(W) 计数(W) xx 0x03
    uint8_t cmd[] = {BLE_CMD_START, SectionData, SectionDataSportData, 0x42, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 启动车表  开始  继续
- (NSData *)cmdSectionDadaStart {
    // 指令：0x02 0x44 0x02 0x46 0x03
    // 返回：0x02 0x44 0x02 xx   0x03
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlStart, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 车表准备就绪
- (NSData *)cmdSectionReady {
    // 指令:0x02 0x44 0x01 0x45 0x03
    // 返回:0x02 0x44 0x01 倒计值(B) xx 0x03
    // 若设备需要倒计时提示用户，返回数据为倒计秒数， 若不需要请返回0
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlReady, 0x45, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 暂停
- (NSData *)cmdSectionPause {
    // 指令 0x02 0x44 0x03 0x47 0x03
    // 返回 0x02 0x44 0x03 xx 0x03
//    PLog(@"%@", NSStringFromSelector(_cmd));
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlPause, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 停止车表
- (NSData *)cmdSectionStop {
    // 指令  0x02 0x44 0x04 0x40 0x03
    // 返回  0x02 0x44 0x04 xx   0x03
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlStop, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 控制车表的阻力和坡度
- (NSData *)cmdSectionControlLevel:(int)level incline:(int)p {
    // 指令：0x02 0x44 0x05 阻⼒(B) 坡度(B) xx 0x03
    // 返回：0x02 0x44 0x05 0x41 0x03
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlParam, level, p, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

// 设备控制 步进  FIXME: 这个指令不明白什么意思  需要问清楚
- (void)cmdSectionControlStep:(int)zuli incline:(int)slope {

}

/// 写入用户数据
- (NSData *)cmdSectionWriteUserData:(int)u_id weight:(int)w height:(int)h age:(int)a sexy:(int)sex {
    // 指令 0x02 0x44 0x0A ID(L) 体重(B) ⾝⾼(B) 年龄(B) 性别(B) xx 0x03  L表示长整型
    // 返回 0x02 0x44 0x0A 0x4E 0x03
    // 体重： kg　　⾝⾼：cm　　性别：0男1⼥
        uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlUser, (Byte)((u_id >> 24) & 0xFF), (Byte)((u_id >> 16) & 0xFF), (Byte)((u_id >> 8) & 0xFF), (Byte)(u_id & 0xFF), w, h, a, sex, 0x00, BLE_CMD_END};
        return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 自由运动模式
- (NSData *)cmdSectionSportModeFree {
    // 开始运动前，APP会发送此指令来明确设备要进⾏的运动模式
    // 指令 0x02 0x44 0x0B 运动ID(L) 模式(B) 段数(B) 目标(W) xx 0x03
    // 返回 0x02 0x44 0x0B 0x4F 0x03
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlSportMode, 0x01, 0x00, 0x00, 0x00, SectionStartModeFree, 0x00, 0x00, 0x00, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

-(NSData *)cmdSectionSportModeTime:(int)time {
//    PLog(@"%@", NSStringFromSelector(_cmd));
    uint8_t low = time & 0xff;
    uint8_t heigh = (time >> 8) & 0xff;
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlSportMode, 0x01, 0x00, 0x00, 0x00, SectionStartModeTime, 0x00, low, heigh, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

- (NSData *)cmdSectionSportModeDistance:(int)distance {
    uint8_t low = distance & 0xff;
    uint8_t heigh = (distance >> 8) & 0xff;
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlSportMode, 0x01, 0x00, 0x00, 0x00, SectionStartModeDistance, 0x00, low, heigh, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

- (NSData *)cmdSectionSportModeCalory:(int)calory {
    uint8_t low = calory & 0xff;
    uint8_t heigh = (calory >> 8) & 0xff;
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlSportMode, 0x01, 0x00, 0x00, 0x00, SectionStartModeCalory, 0x00, low, heigh, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

- (NSData *)cmdSectionSportModeCount:(int)count {
    uint8_t low = count & 0xff;
    uint8_t heigh = (count >> 8) & 0xff;
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlSportMode, 0x01, 0x00, 0x00, 0x00, SectionStartModeCount, 0x00, low, heigh, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

- (NSData *)cmdSectionSportModeResistance:(int)resistance {
    uint8_t low = resistance & 0xff;
    uint8_t heigh = (resistance >> 8) & 0xff;
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlSportMode, 0x01, 0x00, 0x00, 0x00, SectionStartModeResistance, 0x00, low, heigh, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

- (NSData *)cmdSectionSportModeheartRate:(int)heartRate {
//    PLog(@"%@", NSStringFromSelector(_cmd));
    uint8_t low = heartRate & 0xff;
    uint8_t heigh = (heartRate >> 8) & 0xff;
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlSportMode, 0x01, 0x00, 0x00, 0x00, SectionStartModeHeartRate, 0x00, low, heigh, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

- (NSData *)cmdSectionSportModeWatt:(int)watt {
    uint8_t low = watt & 0xff;
    uint8_t heigh = (watt >> 8) & 0xff;
    uint8_t cmd[] = {BLE_CMD_START, SectionControl, SectionControlSportMode, 0x01, 0x00, 0x00, 0x00, SectionStartModeWatt, 0x00, low, heigh, 0x00, BLE_CMD_END};
    return [self prepareSendData:cmd length:sizeof(cmd)];
}

/// 设置功能开关
- (void)carTableFunctionSwitch {
}

/// 设置程式数据
- (void)carTableProgarm {
}



#pragma mark 跑步机数据解析
#pragma mark 车表数据解析


@end
