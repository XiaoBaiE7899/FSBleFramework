
#import "FSBleDevice.h"
#import "FSLibHelp.h"

// 蓝牙命令 开始 && 结束
typedef NS_ENUM(NSInteger, BLE_CMD) {
    /* 指令帧头 */
    BLE_CMD_START   = 0x02,
    /* 指令帧尾 */
    BLE_CMD_END     = 0x03,
};

typedef NS_ENUM(NSInteger, TREADMILL) {
    /* 设备信息 */
    TreadmillInfo     = 0x50,
    /* 设备状态 */
    TreadmillStatus   = 0x51,
    /* 设备数据 */
    TreadmillData     = 0x52,
    /* 设备控制 */
    TreadmillControl  = 0x53,
};

// 设备信息 0x50
typedef NS_ENUM(NSInteger, TREADMILL_INFO) {
    /* 获取设备机型 */
    TreadmillInfoModel  = 0,
    /* 获取设备速度参数 */
    TeadmillInfoSpeed   = 2,
    /* 获取设备坡度参数 */
    TeadmillInfoIncline = 3,
    /* 获取设备累计里程 */
    TeadmillInfoTotal   = 4,
    /* 同步设备日期，返回版本日期1.0.5 */
    TeadmillInfoDate    = 1,
};

// 设备状态  0x51
typedef NS_ENUM(NSInteger, TREADMILL_STATUS) {
    /* 待机状态 */
    TreadmillStausNormal   = 0,
    /* 已停机状态(还未返回到待机) */
    TreadmillStausEnd      = 1,
    /* 倒计时启动状态 */
    TreadmillStausStart    = 2,
    /* 运行中状态 */
    TreadmillStausRunning  = 3,
    /* 减速停止中(完全停止后变为 PAUSED 或 END 或 NORMAL) */
    TreadmillStausStopping = 4,
    /* 设备故障状态 */
    TreadmillStausError    = 5,
    /* 禁用（安全开关或睡眠等）（1.1 修改） */
    TreadmillStausDisable  = 6,
    /* 禁止启动状态(设备处于不允许运行状态) */
    TreadmillStausDisRun   = 7,
    /* 设备就绪（1.1）CONTROL_READY 指令后应为此状态 */
    TreadmillStausReady    = 9,
    /* 设备已暂停（1.1） */
    TreadmillStausPaused   = 10,
    /* !!!: 预防表商返回0x10， 防呆不防傻*/
    TreadmillStausPauseds  = 16
};

// 设备数据  0x52
typedef NS_ENUM(NSInteger, TREADMILL_DATA) {
    /* 读取当前运动量 */
    TreadmillDataSport   = 0,
    /* 当前运动信息 */
    TreadmillDataInfo    = 1,
    /* 速度数据(程式模式) */
    TreadmillDataSpeed   = 2,
    /* 坡度数据(程式模式) */
    TreadmillDataIncline = 3,
};

// 设备控制   0x53
typedef NS_ENUM(NSInteger, TREADMILL_CONTROL) {
    /* 写入用户信息 */
    TreadmillControlUser   = 0,
    /* 准备开始（1.1）（START 前写入运动数据）*/
    TreadmillControlReady  = 1,
    /* 控制速度、坡度（用户手动操作） */
    TreadmillControlTarget = 2,
    /* 停止设备（此指令直接停止设备） */
    TreadmillControlStop   = 3,
    /* 速度数据(程式模式) */
    TreadmillControlSpeed  = 4,
    /* 坡度数据(程式模式) */
    TreadmillControlHeight = 5,
    /* 开始或恢复设备运行（1.1 正式启动） */
    TreadmillControlStart  = 9,
    /* 暂停设备（1.1） */
    TreadmillControlPause  = 10,
};

// 启动模式 SYS_MODE
typedef NS_ENUM(NSInteger, TREADMILL_START_MODE) {
    /* 正常模式，用于快速启动 */
    TreadmillStartModeNormal    = 0,
    /* 倒计时间模式 */
    TreadmillStartModeTimer     = 1,
    /* 倒计距离模式 */
    TreadmillStartModeDistance  = 2,
    /* 倒计卡路里模式 */
    TreadmillStartModeCalorises = 3,
    /* 程式模式(会发送速度及坡度数据) */
    TreadmillStartModePogram     = 5,
};

typedef NS_ENUM(NSInteger, Section) {
    /* 配置设备型号：0x02 0x50 0x00 0x50 0x03  可以获取设备品牌、机型 */
    SectionModel   = 0x50,
    /* 设备参数 */
    SectionParam   = 0x41,
    /* 设备状态 */
    SectionStatus  = 0x42,
    /* 设备数据 */
    SectionData    = 0x43,
    /* 设备控制 */
    SectionControl = 0x44,
};

// 车表设备参数信息
typedef NS_ENUM(NSInteger, Section_Param) {
    /*  获取0x02 0x41 0x02 0x40 0x03：  阻力B  坡度B  配置B  段数B */
    SectionParamInfo    = 0x02,
    /*  获取0x02 0x41 0x03 0x42 0x03：  累计值 */
    SectionParamTotal   = 0x03,
    /*  同步时间：传入数据  年月日周时分秒 年传入后2位 */
    SectionParamDate    = 0x04,
};

// 车表设备参数信息
typedef NS_ENUM(NSInteger, Section_STATUS) { // normal  0x02 0x42 0x42 0x03
    /* 待机 */
    SectionParamStatusNormal     = 0,    //
    /* 启动中 */
    SectionParamStatusStarting   = 1,    //
    /* 运行   数据：速度W 阻力B 频率W 心率B 瓦特W 坡度B 段索引B */
    SectionParamStatusRunning    = 2,
    /* 暂停   数据：速度W 阻力B 频率W 心率B 瓦特W 坡度B 段索引B */
    SectionParamStatusPause      = 3,
    /* 睡眠 !!!:  预防表商10进制， 防呆不防傻 */
    SectionParamStatusSleep      = 20,
    /* 睡眠 */
    SectionParamStatusSleeps     = 32,
    /* 故障 */
    SectionParamStatusError      = 21
};

// 车表数据
typedef NS_ENUM(NSInteger, Section_DATA) {
    /* 获取0x02 0x43 0x01 0x43 0x03 ：  时间W 距离W 热量W 计数W */
    SectionDataSportData      = 0x01,
    /* 获取0x02 0x43 0x02 0x41 0x03：  用户L 运动L 模式B 段数B 目标W */
    SectionDataSportInfo      = 0x02,
    /*  获取：  索引B 数据N  这个可能不会用到 */
    SectionDataProgramData    = 0x03,   //
};

// 车表控制
typedef NS_ENUM(NSInteger, Section_CONTROL) {
    /*app在即将开始运行设备时，最先发送此指令给设备，通知设备即将开始，设备接收到此指令后，进行运动数据重置，同事恢复相关设置值   备注：倒计值 若设备需要倒计时提示用户，返回数据为倒计秒值，若不需要返回0*/
    /* 0x02 0x44 0x01 0x45 0x03 准备就绪 */
    SectionControlReady             = 0x01,
    /* 0x02 0x44 0x02 0x46 0x03 开始继续 */
    SectionControlStart             = 0x02,
    /* 0x02 0x44 0x03 0x47 0x03 暂停 */
    SectionControlPause             = 0x03,
    /* 0x02 0x44 0x04 0x40 0x03 停止 */
    SectionControlStop              = 0x04,
    /* 设置参数  设置阻力  坡度 */
    SectionControlParam             = 0x05,
    /* 设置步进  设置阻力  坡度 */
    SectionControlStep              = 0x06,
    /* 写入用户数据 ID（L） 体重B  身高B 年龄B 性别B（0:男  1:女） */
    SectionControlUser              = 0x0A,
    /* 运动模式  运动ID（L） 模式B   段数B  目标W */
    SectionControlSportMode         = 0x0B,
    /* 功能关开 */
    SectionControlFunctionSwitch    = 0x0C,
    /* 设置程式模式 */
    SectionControlProgram           = 0x0D,
};

// 车表数据  有控制模式时候，必须有倒计模式
typedef NS_ENUM(NSInteger, Section_START_MODE) {
    /* 自由 */
    SectionStartModeFree          = 0x00,
    /* 时间 */
    SectionStartModeTime          = 0x01,
    /* 距离 */
    SectionStartModeDistance      = 0x02,
    /* 卡路里 */
    SectionStartModeCalory        = 0x03,
    /* 计数 */
    SectionStartModeCount         = 0x04,
    /* 阻力控制模式 */
    SectionStartModeResistance    = 0x10,
    /* 心率控制模式 */
    SectionStartModeHeartRate     = 0x20,
    /* 功率控制模式 */
    SectionStartModeWatt          = 0x03,
};




@interface FSBleDevice ()

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
@property (nonatomic) FSDeviceState      oldStatus;

/* 设备的新状态 初始化状态：-1 */
@property (nonatomic) FSDeviceState      currentStatus;

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

/* 阻力 */
@property (nonatomic) NSString *level;

/* 频率 */
@property (nonatomic) NSString *frequency;

/* 启动倒计时秒数 */
@property (nonatomic) NSString *countDwonSecond;

/* 功率 */
@property (nonatomic) NSString *watt;

/* 心跳包定时器 */
@property (nonatomic, strong) NSTimer *heartbeatTimer;

/* 已获取速度参数 */
@property (nonatomic) BOOL hasGetSpeedParam;

/* 已获取坡度参数 */
@property (nonatomic) BOOL hasGetInclineParma;

/* 已获取阻力参数*/
@property (nonatomic) BOOL hasGetLevelParam;

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
    /*
     数据重置---清除指令---获取状态---更新设备参数--- 写入用户数据--- 启动心跳包
     */
    [self reset];
    [self clearSend];
    [self updateState:nil];
    [self updateDeviceParams];
    // 定时发送心跳包
    [_heartbeatTimer invalidate];
    _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updateState:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_heartbeatTimer forMode:NSRunLoopCommonModes];
}

- (BOOL)onUpdateData:(FSCommand *_Nullable)cmd {
    FSLog(@"xb1007%@", self.module.name);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(readyTimeOut) object:nil];

    // !!!: 判断数据是否合法
//    if (!FSBleDataProcess.isValidDataForBleBack(cmd.data)) {
//        // FIXME: 数据不合法，直接断连  这个判断还没写  对蓝牙返回的数据做CRC校验
//        return NO;
//    }

    // 解析蓝牙返回的数据
    if (self.module.protocolType == BleProtocolTypeTreadmill) {
        [self parsingTreadmillData:cmd.data];
    } else {
//        CarTableCmd.parsingCarTableData(cmd.data, self);
        [self parsingCarTableData:cmd.data];
    }

    // MARK: 判断是不是程式模式

    if (self.connectState != ConnectStateWorking) {
        if (self.fsDeviceDeltgate &&
            [self.fsDeviceDeltgate respondsToSelector:@selector(device:didConnectedWithState:)]) {
            [self.fsDeviceDeltgate device:self didConnectedWithState:ConnectStateWorking];
        }
    }
    [self setValue:@(ConnectStateWorking) forKeyPath:@"connectState"];

    // 程式模式已完成，就不更新数据
//    if (self.programFinished) return YES;
    // 数据通过通知发送出去
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateFitshoData object:self];
    // MARK: 12.30 self  与 fs_sport.fsDevice 其实就是同一个对象
    return YES;
}

/// 处理特殊指令
- (void)onFailedSend:(FSCommand *_Nullable)cmd {
    Byte *databytes = (Byte *)[cmd.data bytes];
    Byte maincmd = databytes[1];    // 主指令
    Byte subcmd = databytes[2];     // 子指令
    if (self.module.protocolType == BleProtocolTypeTreadmill) {
        // 如果是控制开始或结束的控制指令，这条指令重新发
        if (maincmd == TreadmillControl && (subcmd == TreadmillControlStart || subcmd == TreadmillControlStop)) {
            [self sendCommand:cmd];
        }
    }
    if (self.module.protocolType == BleProtocolTypeSection) {
        // 如果是控制开始或结束的控制指令，这条指令重新发
        if (maincmd == SectionControl && (subcmd == SectionControlStart || subcmd == SectionControlStop)) {
            [self sendCommand:cmd];
        }
    }
}

- (void)onDisconnected {
    FSLog(@"执行子类onDisconnected");
    [self.cmdQueueTimer invalidate];
    self.cmdQueueTimer = nil;
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = nil;
    // 调用父类的方法，设置连接的状态为：没有连接
    [super onDisconnected];
}

//- (void)onSendData {
//    FSLog(@"执行子类 onSendData");
//}

#pragma mark 对外开放方法

- (BOOL)startDevice {

    // 跑步机
    if (self.module.protocolType == BleProtocolTypeTreadmill) {
        // 发送跑步机指令
        [self sendData:[self cmdTreadmillStart]];
        return YES;
    }

    // 车表正常待机  睡眠都可以启动
    if (self.module.protocolType == BleProtocolTypeSection) {
        if (self.currentStatus == FSDeviceStateNormal ||
            self.currentStatus == FSDeviceStateSectionSleep) {
            // 1 写入用书数据
            [self sendData:[self cmdSectionWriteUserData:0 weight:70 height:170 age:25 sexy:0]];
            // 2 获取状态
            [self sendData:[self cmdSectionStatue]];
            // 3 准备就绪
            [self sendData:[self cmdSectionReady]];
            // 4 写入用书数据
            [self sendData:[self cmdSectionWriteUserData:0 weight:70 height:170 age:25 sexy:0]];
            // 5 启动
            [self sendData:[self cmdSectionDadaStart]];
            return YES;
        }
    }
    FSLog(@"跑步机当前状态是%ld，不能启动，断连设备", (long)self.currentStatus);
    [self disconnect];
    return NO;
}

// 发送速度指令
- (void)sendTargetSpeed:(int)speed {
    /*
     控制速度
     1 只有跑步机才能控制速度，不是跑步机直接返回  MARK: 走步机应该也可以控制速度，这个需要测试
     2 如果当前速度等于目标速度，不用发送指令，直接返回
     3 判断速度上下限
     4 获取当前坡度，
     5 发送指令
     */
    if (self.module.protocolType != BleProtocolTypeTreadmill) {
        FSLog(@"不是跑步机，速度不支持控制");
        return;
    }
    if (self.speed.intValue == speed) {
        FSLog(@"当前速度与目标速度相同，不需要发送指令");
        return;
    }
    // 目标速度
    int targetSpeed = speed;
    // 当前坡度
    int currentIncline = self.incline.intValue;
    if (speed <= self.minSpeed.intValue) {
        targetSpeed = self.minSpeed.intValue;
    }

    if (speed >= self.maxSpeed.intValue) {
        targetSpeed = self.maxSpeed.intValue;
    }
    // 发送指令
    [self sendData:[self cmdTreadmillControlSpeed:targetSpeed incline:currentIncline]];
}

// 发送坡度指令
- (void)sendTargetIncline:(int)incline {
    /*
       控制坡度
     1 如果设备不支持坡度控制，或者当前设备的坡度等于要控制的坡度，直接返回
     2 过滤坡度值的上下限
     3 获取当前设备的速度和阻力
     4 根据设备类型不同，发送不停指令
     */
    if (!self.supportIncline) {
        FSLog(@"设备不支持坡度控制");
        return;
    }
    if (self.incline.intValue == incline) {
        FSLog(@"目标坡度等于当前坡度，不需要发送指令");
        return;
    }
    // 目标坡度
    int targetIncline = incline;
    // 当前速度
    int currentSpeed = self.speed.intValue;
    // 当前阻力
    int currentLevel = self.level.intValue;
    if (targetIncline <= self.minIncline.intValue) {
        targetIncline = self.minIncline.intValue;
    }
    if (targetIncline >= self.maxIncline.intValue) {
        targetIncline = self.maxIncline.intValue;
    }
    // 根据设备类型不同，发送不同指令
    if (self.module.protocolType == BleProtocolTypeTreadmill) {
        // 发送跑步机指令
        [self sendData:[self cmdTreadmillControlSpeed:currentSpeed incline:targetIncline]];
    }

    if (self.module.protocolType == BleProtocolTypeSection) {
        // 发送车表指令
        [self sendData:[self cmdSectionControlLevel:currentLevel incline:targetIncline]];
    }
}

// 同时控制设备的速度&坡度
- (void)sendTargetSpeed:(int)speed targetIncline:(int)incline {
    /*
     同时控制速度、坡度
     1 如果不是跑步机 因为速度不能控制，速度、坡度等于目标速度、目标坡度 直接返回
     2 过滤速度、坡度的上下限
     3 跑步机的速度可以控制，坡度不一定可以控制
       3.1 如果跑步的坡度不可控制，速度等于目标速度，直接返回， 否则发送执行后返回
     4 速度、坡度都是可以控制，发送指令
     */
    if (self.module.protocolType != BleProtocolTypeTreadmill) {
        FSLog(@"只有跑步机才支持速度控制");
        return;
    }
    if (self.speed.intValue == speed &&
        self.incline.intValue == incline) {
        FSLog(@"速度&坡度  等于目标速度&坡度");
        return;
    }
    int targetSpeed = speed;
    int targetIncline = incline;
    if (targetSpeed <= self.minSpeed.intValue) {
        targetSpeed = self.minSpeed.intValue;
    }
    if (targetSpeed >= self.maxSpeed.intValue) {
        targetSpeed = self.maxSpeed.intValue;
    }
    // 设备不支持坡度控制,目标速度等于当前速度，不需要发送指令
    if (!self.supportIncline) {
        // 设备不支持坡度控制
        if (targetSpeed == self.speed.intValue) {
            FSLog(@"坡度不能控制，目标速度等于当前速度，不需要发送指令");
            return;
        }
        [self sendData:[self cmdTreadmillControlSpeed:targetSpeed incline:0]];
    } else {
        // 设备支持坡度控制
        if (targetSpeed == self.speed.intValue &&
            targetIncline == self.incline.intValue) {
            FSLog(@"坡度可以控制，目标速度&坡度等于当前的速度&坡度，不需要发送指令");
            return;
        }
        [self sendData:[self cmdTreadmillControlSpeed:targetSpeed incline:targetIncline]];
    }
}

// 发送阻力指令
- (void)sendTargetLevel:(int)level {
    /*
     控制阻力
     1 设备类型不对(跑步机不支持阻力控制)，阻力不可以控制，直接返回
     2 当前阻力等于目标阻力，直接返回
     3 获取当前坡度，
     4 过滤非法数据
     5 发送指令
     */
    if (self.module.protocolType == BleProtocolTypeTreadmill) {
        FSLog(@"跑步机不支持阻力控制");
        return;
    }
    if (!self.supportLevel) {
        FSLog(@"设备不支持阻力控制");
        return;
    }
    if (level == self.level.intValue) {
        FSLog(@"当前阻力等于目标阻力，不需要发送指令");
        return;
    }
    // 目标阻力
    int targetLevel = level;
    // 当前坡度
    int currentIncline = self.incline.intValue;
    if (targetLevel <= self.minLevel.intValue) {
        targetLevel = self.minLevel.intValue;
    }
    if (targetLevel >= self.maxLevel.intValue) {
        targetLevel = self.maxLevel.intValue;
    }
    // 发送控制指令
    [self sendData:[self cmdSectionControlLevel:targetLevel incline:currentIncline]];
}

// 同时控制 设备的阻力&坡度
- (void)sendTargetLevel:(int)level targetIncline:(int)incline {
    /*
     1 设备阻力&坡度都不可以，直接返回
     2 设备阻力不可以控制，坡度可以控制，只要发送坡度指令
     3 设备坡度不可以控制，阻力可以控制，只要发送阻力指令
     4 设备的阻力&坡度都可以控制，判断目标阻力&目标坡度是否相等
     */
    if (!self.supportLevel && !self.supportIncline) {
        FSLog(@"阻力速度，都不可以控制，不用发指令");
        return;
    }
    if (!self.supportLevel && self.supportIncline) {
        [self sendTargetIncline:incline];
        return;
    }
    if (!self.supportIncline && self.supportLevel) {
        [self sendTargetLevel:level];
        return;
    }
    int targetLevel = level;
    int targetIncline = incline;
    if (targetLevel <= self.minLevel.intValue) {
        targetLevel = self.minLevel.intValue;
    }
    if (targetLevel >= self.maxLevel.intValue) {
        targetLevel = self.maxLevel.intValue;
    }
    if (targetIncline <= self.minIncline.intValue) {
        targetIncline = self.minIncline.intValue;
    }
    if (targetIncline >= self.maxIncline.intValue) {
        targetIncline = self.maxIncline.intValue;
    }

    if (targetLevel == self.level.intValue &&
        targetIncline == self.incline.intValue) {
        FSLog(@"设备阻力&坡度，都可以控制，但是目标阻力&坡度  等于  设备当前的阻力&坡度");
        return;
    }
    // 发送控制阻力和坡度的指令
    [self sendData:[self cmdSectionControlLevel:targetLevel incline:targetIncline]];
//    [self sendData:CarTableCmd.carTableControlParam(targetLevel, currentIncline)];
}

// 暂停设备
- (void)pause {
    /*
     如果设备不支持暂停  直接返回
     根据不同设备类型不同，发送不同指令
     */
    if (!self.supportPause) {
        FSLog(@"设备不支持暂停");
        return;
    }
    if (self.module.protocolType == BleProtocolTypeTreadmill) {
        FSLog(@"跑步机发送暂停指令");
        return;
    }

    if (self.module.protocolType == BleProtocolTypeSection) {
        FSLog(@"车表发送暂停指令");
        return;
    }
}

// 停止设备
- (void)stop {
    /*
     设备不同，发送的指令不同
     */
    if (self.module.protocolType == BleProtocolTypeTreadmill) {
        // 发送跑步机停止指令
        [self sendData:[self cmdTreadmillStop]];
    }

    if (self.module.protocolType == BleProtocolTypeSection) {
        [self sendData:[self cmdSectionStop]];
    }
}

// 恢复设备
- (void)resume {
    /*
     1 如果不是跑步机，直接返回
     2 如果设备不是在暂停中，直接返回
     3 发送跑步机  恢复指令
     */
    if (self.module.protocolType == BleProtocolTypeSection) {
        FSLog(@"不是跑步机，直接返回");
        return;
    }

    if (!self.isPausing) {
        FSLog(@"设备不是正在暂停中，直接返回");
        return;
    }
    // 发送恢复指令 以后3秒判断设备是否有回复
    [self sendData:[self cmdTreadmillResume]];
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



- (BOOL)hasStoped {
    if (self.oldStatus == FSDeviceStateNone || self.currentStatus == FSDeviceStateNone) {
        return NO;
    }
//    FSLog(@"设备是否完全停止");
    // 车表是否完全停止
    if (self.module.protocolType == BleProtocolTypeSection) {
        if (self.oldStatus == FSDeviceStateRunning &&
            self.currentStatus == FSDeviceStateNormal) {
            return YES;
        }
        if (self.oldStatus == FSDeviceStatePaused &&
            self.currentStatus == FSDeviceStateNormal) {
            return YES;
        }
        return NO;
    }
    /*
     2021.02.19 MARK: 判断设备是否完成停止，只要判断设备不是初始化状态，旧状态不为0，新状态为0就是完全停止
    */
    //
    if (self.oldStatus == FSDeviceStateTreadmillStopping &&
        self.currentStatus == FSDeviceStateNormal) {
        FSLog(@"0322 不支持暂停 的设备");
        return YES;
    }
    // MARK: 9.14 脉动工厂参加体博会设备 不会进入4状态，状态3&&速度0即为暂停，再发停止，就停止
    if (self.oldStatus == FSDeviceStateRunning &&
        self.currentStatus == FSDeviceStateNormal) {
        FSLog(@"0322 脉动工厂参加体博会设备");
        return YES;
    }
    // MARK: 2021.02.19 康乐佳 发送停止指令以后  3-1-0
    if (self.oldStatus == FSDeviceStateTreadmillEnd &&
        self.currentStatus == FSDeviceStateNormal) {
        FSLog(@"0322 脉动工厂参加体博会设备");
        return YES;
    }
    // 暂停到待机
    if (self.oldStatus == FSDeviceStatePaused &&
        self.currentStatus == FSDeviceStateNormal) {
        FSLog(@"0322 脉动工厂参加体博会设备");
        return YES;
    }
    return NO;
}

- (BOOL)isPausing {
    // 车表是否暂停
    if (self.module.protocolType == BleProtocolTypeSection) {
        return self.currentStatus == FSDeviceStatePaused ? YES : NO;
    }
    /*
     正常的暂停 状态为 TreadmillStausPauseds || TreadmillStausPaused
     20.09.14 迈动工厂测试 暂停的时候设备还在运行中，但是速度为0
     */
    /*  9.29 迈动展厅测试，通过指令让设备从设备暂停状态恢复运行的结果
     1. TA860K 可以恢复，这种情况不需要处理，直接恢复就好
     2. 体博会参展的设备，设备状态一直都是3，点击app上的恢复，也是3，速度为0.
     3. 跑客（白色跑步机），从app恢复的状态一直为10.
     */

    // 判断跑步机是否整处于暂停状态
    if (self.currentStatus == FSDeviceStatePaused || (self.currentStatus == FSDeviceStateRunning && self.speed.intValue == 0)) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark 蓝牙指令公用方法
// 重置数据
- (void)reset {
    self.oldStatus = FSDeviceStateNone;
    self.currentStatus = FSDeviceStateNone;
    self.speed = @"0";
    self.incline = @"0";
    self.eElapsedTime = @"0";
    self.distance = @"0";
    self.steps = @"0";
    self.counts = @"0";
    self.heartRate = @"0";
    self.paragraph = @"0";
    self.errorCode = @"";
//    self.uid = @"0";
//    self.weight = @"0";
//    self.height = @"0";
//    self.age = @"0";
//    self.gender = @"";
//    self.adjustSlope = @"";
//    self.adjustSpeed = @"";
    self.level = @"0";
    self.frequency = @"0";
    self.countDwonSecond = @"0";
    self.watt = @"0";
    self.isPausing = NO;
    self.hasStoped = NO;
    self.hasGetLevelParam = NO;
    self.hasGetSpeedParam = NO;
    self.hasGetInclineParma = NO;
}

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
    //FSBleDataProcess.calculateCheckNum(data + 1, len - 3);
    UInt8 crc = [self checkCrcCode:data + 1 length:len - 3];
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

// 两个字节转int
- (unsigned int)readUShort:(Byte *)bytes {
    unsigned int temp = (bytes[0] | bytes[1] << 8);
    return temp;
}

// 四个字节转int
- (unsigned int)readUInt:(Byte *)bytes {
    unsigned int temp = (bytes[0] | bytes[1] << 8 | bytes[2] << 16 | bytes[3] << 24);
    return temp;
}

- (NSString *)getBinaryByDecimal:(NSInteger)decimal {
    FSLog(@"配置信息%ld", (long)decimal);

    NSString *binary = @"";
    while (decimal) {
        binary = [[NSString stringWithFormat:@"%ld", (long)decimal % 2] stringByAppendingString:binary];
        if (decimal / 2 < 1) {

            break;
        }
        decimal = decimal / 2 ;
    }
    if (binary.length % 4 != 0) {

        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {

            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    return binary;
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

// 发送数据
- (void)sendData:(NSData *)data {
    // 如果发送数据 4秒没返回数据，就是超时了
    [self performSelector:@selector(readyTimeOut) withObject:nil afterDelay:4];
    FSCommand *cmd = [FSCommand make:self.bleWriteChar data:data];
    [self sendCommand:cmd];
}



- (void)readyTimeOut {
    
}

// 更新设备参数
- (void)updateDeviceParams {
    // 获取跑步机的设备参数
    if (self.module.protocolType == BleProtocolTypeTreadmill) {
        [self sendData:[self cmdTreadmillSpeedParam]];
        // MARK: 延迟1秒获取设备坡度信息，
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendData:[self cmdTreadmillInclineParam]];
        });
    }

    // 获取车表的设备参数
    if (self.module.protocolType == BleProtocolTypeSection) {
        [self sendData:[self cmdSectionParamInfo]];
    }
}

- (BOOL)getParamSuccess {
    if (self.module.protocolType == BleProtocolTypeTreadmill) {
        if (self.hasGetSpeedParam && self.hasGetInclineParma) {
            return YES;
        }
    }

    if (self.module.protocolType == BleProtocolTypeSection) {
        if (self.hasGetLevelParam && self.hasGetInclineParma) {
            return YES;
        }
    }

    return NO;
}

// 更新状态
- (void)updateState:(NSTimer *)sender {
    // 这里要判断设备类型
    if (self.module.protocolType == BleProtocolTypeTreadmill) {
        // 如果指令集合小于2条就加入一条状态指令
        if (self.commands.count < 2) {
            // 如果有定时器，但是控制参数没有获取，先去获取控制参数
            if (sender && ![self getParamSuccess]) {
                [self updateDeviceParams];
            }
            // 再获取  设备状态
            [self sendData:[self cmdTreadmillStatus]];
        }
        return;
    }

    if (self.commands.count < 3) {
        // 如果指令集合小于3条就加入一条状态指令
        if (sender && ![self getParamSuccess]) {
            [self updateDeviceParams];
        }
        [self sendData:[self cmdSectionStatue]];
        [self sendData:[self cmdSectionSportDada]];
    }
}

// 写入用户数据 !!!: 中阳系统运动ID只能传0  特别注意
- (void)sendUserInfo {
    // 这里要判断设备类型
    if (self.module.protocolType == BleProtocolTypeTreadmill) {
        // FIXME: 跑步机写入用户数据  指令没发送
    }

    if (self.module.protocolType ==  BleProtocolTypeSection) {
        [self sendData:[self cmdSectionWriteUserData:0 weight:70 height:170 age:25 sexy: 0]];
    }
}


/// 重置设备的状态
- (void)fsResetDeviceState {
    /* 跑步机、车表都有的状态  待机、启动中、运行、暂停、故障
     TreadmillStausEnd      = 1,   已停机状态(还未返回到待机)
     TreadmillStausStopping = 4,  减速停止中(完全停止后变为 PAUSED 或 END 或 NORMAL)
     TreadmillStausDisable  = 6,   禁用（安全开关或睡眠等）（1.1 修改）
     TreadmillStausDisRun   = 7,   禁止启动状态(设备处于不允许运行状态)
     TreadmillStausReady    = 9,  设备就绪（1.1）CONTROL_READY 指令后应为此状态
     SectionParamStatusSleep      = 20,    睡眠 !!!:  预防表商10进制， 防呆不防傻
     SectionParamStatusSleeps     = 32,    睡眠
     */
    /*
    typedef NS_ENUM(NSInteger, FSDeviceState) {
        FSDeviceStateNormal,             待机
        FSDeviceStateStarting,           启动中
        FSDeviceStateRunning,            运行中
        FSDeviceStatePaused,            已暂停
        FSDeviceStateError,              故障
        FSDeviceStateTreadmillEnd,       跑步机 已停机状态(还未返回到待机)
        FSDeviceStateTreadmillStopping,  跑步机 减速停止中(完全停止后变为 PAUSED 或 END 或 NORMAL)
        FSDeviceStateTreadmillDisable,   跑步机 禁用（安全开关或睡眠等）（1.1 修改）
        FSDeviceStateTreadmillDisRun,    跑步机  禁止启动状态(设备处于不允许运行状态)
        FSDeviceStateTreadmillReady,     设备就绪（1.1）CONTROL_READY 指令后应为此状态
        FSDeviceStateSectionSleep,      车表  睡眠
    }*/

    if (self.module.protocolType == BleProtocolTypeTreadmill) {
        // 跑步机状态
        switch (self.currentStatus) {
            case TreadmillStausNormal:{
                self.currentStatus = FSDeviceStateNormal;
            }
                break;
            case TreadmillStausEnd: {
                self.currentStatus = FSDeviceStateTreadmillEnd;
            }
                break;
            case TreadmillStausStart: {
                self.currentStatus = FSDeviceStateStarting;
            }
                break;
            case TreadmillStausRunning: {
                self.currentStatus = FSDeviceStateRunning;
            }
                break;
            case TreadmillStausStopping: {
                self.currentStatus = FSDeviceStateTreadmillStopping;
            }
                break;
            case TreadmillStausError: {
                self.currentStatus = FSDeviceStateError;
            }
                break;
            case TreadmillStausDisable: {
                self.currentStatus = FSDeviceStateTreadmillDisable;
            }
                break;
            case TreadmillStausDisRun: {
                self.currentStatus = FSDeviceStateTreadmillDisRun;
            }
                break;
            case TreadmillStausReady: {
                self.currentStatus = FSDeviceStateTreadmillReady;
            }
                break;
            case TreadmillStausPaused:
            case TreadmillStausPauseds: {
                self.currentStatus = FSDeviceStatePaused;
            }

            default:
                break;
        }
        return;
    }
    if (self.module.protocolType == BleProtocolTypeSection) {
        // 车表的状态封装
        switch (self.currentStatus) {
            case SectionParamStatusNormal: {
                self.currentStatus = FSDeviceStateNormal;
            }
                break;
            case SectionParamStatusStarting: {
                self.currentStatus = FSDeviceStateStarting;
            }
                break;
            case SectionParamStatusRunning: {
                self.currentStatus = FSDeviceStateRunning;
            }
                break;
            case SectionParamStatusPause:{
                self.currentStatus = FSDeviceStatePaused;
            }
                break;
            case SectionParamStatusSleep:
            case SectionParamStatusSleeps: {
                self.currentStatus = FSDeviceStateSectionSleep;
                
            }
                break;
            case SectionParamStatusError: {
                self.currentStatus = FSDeviceStateError;
            }
            default:
                break;
        }
    }
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
- (NSData *)cmdTreadmillControlSpeed:(int)v incline:(int)p {
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
- (NSData *)cmdSectionSportDada {
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
- (void)parsingTreadmillData:(NSData *)data {
    // 数据格式的合法性独立一个方法判断
    Byte *databytes = (Byte *)[data bytes];
    Byte cmd = databytes[1];
    Byte subcmd = databytes[2];
    switch (cmd) {
        case TreadmillInfo: {
            if (subcmd == TreadmillInfoModel) {
                // 获取设备机型  这个地方要修改
//                self.manufacturer = FSSF(@"%d", [self readUShort:databytes + 3]);
//                self.model = FSSF(@"%d", [self readUShort:databytes + 5]);
//                FSLog(@"厂家：%@ 型号：%@", self.manufacturer, self.model);
            } else if (subcmd == TeadmillInfoSpeed) { // 获取设备速度参数
                unsigned int max_Speed = databytes[3];
                unsigned int min_Speed = databytes[4];
                unsigned int control = max_Speed - min_Speed;
                // 这里也有设置单位，要仔细看看蓝牙协议的介绍
                self.maxSpeed = FSSF(@"%u", max_Speed);
                self.minSpeed = FSSF(@"%u", min_Speed);
                self.supportSpeed = control > 0 ? YES : NO;
                // issues#484  如果设备是英制单位，返回来的值就是英制单位
                FSLog(@"最大速度%@  最小速度%@  控制%d", self.maxSpeed, self.minSpeed, self.supportSpeed);
                self.hasGetSpeedParam = YES;
            } else if (subcmd == TeadmillInfoIncline) { // 获取设备坡度参数
                unsigned int maxIncline = databytes[3];
                unsigned int minIncline = databytes[4];
                /*
                  这个指令的  设备的配置信息可以拿不到 可以根据返回的数据长度去判断信息是否完整。
                 不响应返回  返回5个字节：  02 53 03 53 03
                 没有配置信息 返回7个字节： 02 53 03 16  00 ** 03
                 有配置信息   返回8个字节：  02 53 03 16 00 90 ** 03
                 */
                FSLog(@"%lu", (unsigned long)data.length);
                switch (data.length) {
                    case 5: { // 坡度数据没下发 最大坡度 最小坡度 是否英制单位，暂停，坡度是否可以控制
                        FSLog(@"公英制测试：获取坡度信息的指令无数据返回");
                        self.maxIncline = @"0";
                        self.minIncline = @"0";
                        self.imperial = NO;
                        self.supportPause = NO;
                        self.supportIncline = NO;
                    }
                        break;
                    case 7: { // 没有发配信息 英制单位、支持暂停设置为0， 最大、最小坡度、坡度是否可以控制可以赋值
                        FSLog(@"公英制测试：999999配置信息没上报");
                        self.maxIncline = FSSF(@"%d", maxIncline);
                        self.minIncline = FSSF(@"%d", minIncline);
                        self.imperial = NO;
                        self.supportPause = NO;
                        self.supportIncline = maxIncline - minIncline > 0 ? YES : NO;
                    }
                        break;
                    case 8: { // 有发配置信息，所有信息都要配置
                        // !!!: 距离单位 && 是否支持暂停
                        unsigned int imperial = databytes[5] & 0x01;
                        unsigned int pause = databytes[5] & 0x02;
                        // 配置信息 转为2进制  输出为字符串
                        FSLog(@"公英制测试：%@", [self getBinaryByDecimal:databytes[5]]);
                        FSLog(@"0310公英制测试  暂停%d  英制%d", pause, imperial);
                        unsigned int control = maxIncline - minIncline;
                        self.maxIncline = FSSF(@"%d", maxIncline);
                        self.minIncline = FSSF(@"%d", minIncline);
                        self.imperial = imperial;
                        self.supportPause = pause;
                        self.supportIncline = control > 0 ? YES : NO;
                    }
                        break;

                    default:
                        break;
                }
                self.hasGetInclineParma = YES;
            } else if (subcmd == TeadmillInfoTotal) { // 获取设备总里程
                unsigned int total_Distance = [self readUInt:databytes + 3];
                self.totalDistance = FSSF(@"%d", total_Distance);
            }
        }
            break;
        case TreadmillStatus: {
            // 设置跑步机旧状态
            self.oldStatus = self.currentStatus;
            // 设置跑步机的当前状态
            self.currentStatus = subcmd;
            // 状态统一处理
            [self fsResetDeviceState];
            // MARK: 新旧状态都不是初始化状态 并且新旧状态不一致  通过代理回调状态改变
            if (self.currentStatus != FSDeviceStateNone &&
                self.oldStatus != FSDeviceStateNone &&
                self.currentStatus != self.oldStatus) {
                if (self.fsDeviceDeltgate &&
                    [self.fsDeviceDeltgate respondsToSelector:@selector(device:currentState:oldState:)]) {
                    [self.fsDeviceDeltgate device:self currentState:self.currentStatus oldState:self.oldStatus];
                }
            }

            // 输入出
            FSLog(@"原始  当前状态%hu", subcmd);
            // FIXME:  状态改变 通过代理回调 在这里增加代码

            // MARK: 2021年，康乐佳  发送停止指令以后  状态的变化是3-1-0 这里要做兼容
            // 添加停止中
            if (self.oldStatus == FSDeviceStateRunning &&
                self.currentStatus == FSDeviceStateTreadmillStopping) {
                FSLog(@"添加loading   停止中的加载框");
            }

            // 去掉停止中
            if (self.oldStatus == FSDeviceStateTreadmillStopping &&
                self.currentStatus != FSDeviceStateTreadmillStopping) {
                FSLog(@"去掉loading  停止中的加载框");
            }

            /*
             设备完成一次运动，状态的变化过程
             1 不支持暂停 0-2-3-4-0
             2 支持暂停
               2.1 正常流程 0-2-3-4-10-0
               2.2 9月14日 迈动工厂测试（参加体博会） 0-2-3------0
                   MARK: 设备支持暂停，但不会进入4、10两种状态 当状态为3&&速度为0，设备就进入暂停状态
             !!!: 通过app发送恢复指令，设备从暂停恢复到运行的状态变化过程
               1. 正常恢复 10月30日 迈动展厅测试 TA860K 10-1-3
               2. 不能通过app 蓝牙指令恢复：
                  1 跑客白色跑步机&A10： 指令发送之后，蓝牙有返回，设备没恢复，返回状态为10
                  2 迈动体博会设备：指令发送之后，蓝牙有返回，设备没恢复，状态为3&&速度为0
                  MARK: 处理逻辑，满足条件1：设备为跑步机， 2：设备处于暂停状态， 发送恢复指令，延迟4秒判断设备是否还是处于暂停中，如果处于暂停中，弹框告诉用户通过设备的屋里键恢复设备运行。
            !!!: 测试版  A10 FS-711636的问题描述
                 1 连接-启动-停止-停止的状态变化： 0-2-3-10-10-0
                 2 连接-启动-控制速度-停止: 0-2-3-4-10-0
                 3 连接-启动-控制坡度-停止: 0-2-3-10-10-0
                 4 这个设备  一开始步数就是错了
                 MARK: 10.30  测试暂停恢复功能，A10有时候回进入10状态，有的时候不会进入10的状态
                 1 暂停状态返回10，发送恢复指令，返回的数据与跑客相同
                 2 不暂停状态返回4，速度为0， 返回0， 这个现象跟不支持暂停的设备一致
             */
            // 12.7 保存连接
            if (self.hasStoped) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kFitshowHasStoped object:self];
                FSLog(@"设备已经完全停止了");
                [self disconnect];
            }
            
            if (subcmd == TreadmillStausNormal) { // 待机状态 完全停止 返回这个状态
            } else if (subcmd == TreadmillStausEnd) { // 减速已停止状态，还未返回待机
            } else if (subcmd == TreadmillStausStart) { // 开始启动状态
                unsigned int count_down = databytes[3];
                self.countDwonSecond = FSSF(@"%d", count_down);
            } else if (subcmd == TreadmillStausRunning) { // 运行中
                /*
                 MARK: 3月10日  迈动工厂拿回表头跑步机  返回的数据与解析
                 V:速度 P:坡度 T:时间 D:距离 C:热量 S:步数 H:心率 G:段数 R:检验
                          V  P  T     D     C     S     H  G  R
                 02 51 03 14 00 AD 02 3A 00 41 00 53 00 00 00 C1 03
                 表显:     2           0.05
                 02 51 03 14 00 C2 03 3E 00 46 00 59 00 00 00 A6 03
                 表显:     2           0.06
                 */
                unsigned int _speed = databytes[3];
                unsigned int _incline = databytes[4];
                unsigned int _time = [self readUShort:databytes + 5];
                unsigned int _distance = [self readUShort:databytes + 7];
                unsigned int _calory = [self readUShort:databytes + 9];
                unsigned int _steps = [self readUShort:databytes + 11];
                unsigned int _heartrate = databytes[13];
                unsigned int _paragraph = databytes[14];
                self.incline = FSSF(@"%d", _incline);
                self.eElapsedTime = FSSF(@"%d", _time);
                FSLog(@"0329上报的距离%d  上报的速度%d", _distance, _speed);
                // 设备上报的距离
                NSString *device_dist = FSSF(@"%d", _distance);
                // 设备上报的速度
                NSString *device_speed = FSSF(@"%d", _speed);
                self.distance = device_dist;
                self.speed = device_speed;
                self.calory = FSSF(@"%d", _calory);
                self.steps = FSSF(@"%d", _steps);
                self.heartRate = FSSF(@"%d", _heartrate);
                self.paragraph = FSSF(@"%d", _paragraph);

            } else if (subcmd == TreadmillStausStopping) { // 减速度停止中
                //减速停止中状态
                unsigned int _speed = databytes[3];
                unsigned int _incline = databytes[4];
                unsigned int _time = [self readUShort:databytes + 5];
                unsigned int _distance = [self readUShort:databytes + 7];
                unsigned int _calory = [self readUShort:databytes + 9];
                unsigned int _steps = [self readUShort:databytes + 11];

                unsigned int _heartrate = databytes[13];
                unsigned int _paragraph = databytes[14];
                self.incline = FSSF(@"%d", _incline);
                self.eElapsedTime = FSSF(@"%d", _time);
                // 设备上报的距离
                NSString *device_dist = FSSF(@"%d", _distance);
                // 设备上报的速度
                NSString *device_speed = FSSF(@"%d", _speed);
                self.distance = device_dist;
                self.speed = device_speed;
                self.calory = FSSF(@"%d", _calory);
                self.steps = FSSF(@"%d", _steps);
                self.heartRate = FSSF(@"%d", _heartrate);
                self.paragraph = FSSF(@"%d", _paragraph);
            } else if (subcmd == TreadmillStausError) { // 设备故障状态
                unsigned int code = databytes[3];
                self.errorCode = FSSF(@"%d", code);
                FSLog(@"设备故障，故障码： %u",code);
                // 不显示加载框
                // 代理回调
                if ([self.fsDeviceDeltgate respondsToSelector:@selector(deviceError:)]) {
                    [self.fsDeviceDeltgate deviceError:self];
                }
                [self disconnect];
            } else if (subcmd == TreadmillStausDisable) { // 禁用
                // 断连
                [self disconnect];
                // 代理回调
                if ([self.fsDeviceDeltgate respondsToSelector:@selector(deviceError:)]) {
                    [self.fsDeviceDeltgate deviceError:self];
                }
                // 这个需要重新写
                unsigned int distubcode = databytes[3];
                FSLog(@"禁止启动状态（1.0.5）,禁止码： %u",distubcode);
            } else if (subcmd == TreadmillStausReady) {
                FSLog(@"设备就绪（1.1）CONTROL_READY 指令后应为此状态");
            } else if (subcmd == TreadmillStausPaused ||
                       subcmd == TreadmillStausPauseds) { // 暂停
            }
        }
            break;
        case TreadmillControl: {
            if (subcmd == TreadmillControlUser) { // // 写入用户信息
                unsigned int useruid = [self readUInt:databytes + 3];
                unsigned int w = databytes[7];
                unsigned int h = databytes[8];
                FSLog(@"uid = %d  体重 = %d 身高：%d", useruid, w, h);
//                self.uid = FSSF(@"%d", useruid);
//                self.weight = FSSF(@"%d", w);
//                self.height = FSSF(@"%d", h);
            } else if (subcmd == TreadmillControlStop) { // 停止设备（此指令直接停止设备）
//                PLog(@"停止命令发送成功");
            } else if (subcmd == TreadmillControlPause) { // 暂停
                // 这个指令不做处理  其实暂停就是停止
            } else if (subcmd == TreadmillControlReady) { // 准备开始（1.1）（START 前写入运动数据）
                unsigned int startsecond = databytes[3];
                // MARK: 这里只会进来一次
                self.countDwonSecond = FSSF(@"%d", startsecond) ;
            } else if (subcmd == TreadmillControlSpeed) { // 速度数据(程式模式)
               //  没有程式模式，这个指令不做处理
            } else if (subcmd == TreadmillControlStart) { // 开始或恢复设备运行（1.1 正式启动）
                // 这个指令不做处理  重新调用启动程序
            } else if (subcmd == TreadmillControlHeight) { // 坡度数据(程式模式)
                // 没有程式模式，这个指令不做处理
            } else if (subcmd == TreadmillControlTarget) { // 控制速度、坡度（用户手动操作）
                unsigned int speed = databytes[3];
                unsigned int incline = databytes[4];
//                self.adjustSpeed = FSSF(@"%d", speed);
//                self.adjustSlope = FSSF(@"%d", incline);
                FSLog(@"收到调整速度与坡度：speed = %u incline = %u",speed ,incline);
            }
        }
            break;
        case TreadmillData: {
            if (subcmd == TreadmillDataSport) { // 读取跑步机运动信息
                unsigned int time = [self readUShort:databytes + 3];
                unsigned int distance = [self readUShort:databytes + 5];
                unsigned int calory = [self readUShort:databytes + 7];
                unsigned int step = [self readUShort:databytes + 9];
                FSLog(@"读到运动数据： 时间 %D 距离 %D 卡落里 %D 步数 %D",time,distance,calory,step);
            } else if (subcmd == TreadmillDataInfo) { // 读取跑步机信息
//                PLog(@"读取跑步机信息的数据，数据解析还没写");
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark 车表数据解析

- (void)parsingCarTableData:(NSData *)data {
    // 数据合法性独立一个方法判断
    Byte *databytes = (Byte *)[data bytes];
    Byte cmd = databytes[1];    // 一级指令
    Byte subcmd = databytes[2]; // 二级指令
    switch (cmd) { // 判断一级指令
        // MARK: CarTableModel(品牌机型通过服务器获取) CarTableParamTotal(总里程) CarTableParamDate(同步设备时间)  这几个指令不会发送
        case SectionParam: {
            // 判断二级指令
            if (subcmd == SectionParamInfo) { // 获取阻力、坡度、配置、段数
                uint max_resistance    = databytes[3];
                uint max_incline       = databytes[4];
                /// !!!: FS 最小阻力、单位、是否支持暂停的赋值 协议里面写的时候配置信息
                uint min_level         = (databytes[5] & 0x04) ? 1 : 0;
                uint unit = databytes[5] & 0x01;
                uint pause = databytes[5] & 0x02;
                uint device_config     = databytes[5];
                uint device_paragraph  = databytes[6];
                FSLog(@"最小阻力%d、是否为英制单位%d、是否支持暂停%d", min_level, unit, pause);
                FSLog(@"最大阻力%d、最大坡度坡度%d、配置%d、段数%d", max_resistance, max_incline, device_config, device_paragraph);
                self.maxLevel  = FSSF(@"%d", max_resistance);
                self.maxIncline = FSSF(@"%d", max_incline);
                self.imperial = unit;
                self.paragraphs = FSSF(@"%d", device_paragraph);
                self.supportLevel = max_resistance > 0 ? YES : NO;
                self.supportIncline = max_incline > 0 ? YES :  NO;
                self.hasGetLevelParam = YES;
                self.hasGetInclineParma = YES;
            }
        }
            break;
        case SectionStatus: {
            // 设置旧状态
            self.oldStatus = self.currentStatus;
            // 设置新状态
            self.currentStatus = subcmd;
            [self fsResetDeviceState];
            FSLog(@"原始  当前状态%ld", (long)subcmd);
            // MARK: 新旧状态都不是初始化状态 并且新旧状态不一致  通过代理回调状态改变
            if (self.currentStatus != FSDeviceStateNone &&
                self.oldStatus != FSDeviceStateNone &&
                self.currentStatus != self.oldStatus) {
                if (self.fsDeviceDeltgate &&
                    [self.fsDeviceDeltgate respondsToSelector:@selector(device:currentState:oldState:)]) {
                    [self.fsDeviceDeltgate device:self currentState:self.currentStatus oldState:self.oldStatus];
                }
            }

            if (self.hasStoped) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kFitshowHasStoped object:self];
            }

            // ???: 这有个问题， 车表停止正常情况，状态应该由运行中到待机，但是君斯达的会先从运行中变成启动中，在变到待机状态
//                if (device.oldStatus.intValue == CarTableParamStatusRunning &&
//                    device.currentStatus.intValue == CarTableParamStatusNormal) {
//                    [device disconnect];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:kFitshowHasStoped object:self];
//                    return;
//                }
            // !!!: 这里对君斯大的设备做特殊处理,理论上来讲，这个设备还么量产，应该有厂家修改，app严格执行对外的开放协议就好
            // 12.7 保存连接 不断开连接
            if (self.oldStatus == FSDeviceStateStarting &&
                self.currentStatus == FSDeviceStateNormal) {
                [self disconnect];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFitshowHasStoped object:self];
                return;
            }

            // 判断二级指令
            if (subcmd == SectionParamStatusNormal) { // 待机
                FSLog(@"待机………………………………………………");
            } else if (subcmd == SectionParamStatusError) { // 故障
                FSLog(@"0226 设备故障");
                // 断连
                [self disconnect];
                // 代理回调
                if ([self.fsDeviceDeltgate respondsToSelector:@selector(deviceError:)]) {
                    [self.fsDeviceDeltgate deviceError:self];
                }

            } else if (subcmd == SectionParamStatusPause) { // 暂停
                uint spd   = [self readUShort:databytes + 3];
                uint resistance    = databytes[5];
                uint frequency   = [self readUShort:databytes + 6];
                uint heart_Rate   = databytes[8];
                uint watt    = [self readUShort:databytes + 9];
                uint slope  = databytes[11];
                uint duanshu = databytes[12];
                FSLog(@"0305速度%d 阻力%d 频率%d 心率%d 瓦特%d 坡度%d 段数%d", spd, resistance, frequency, heart_Rate, watt, slope, duanshu);
                self.speed = FSSF(@"%d", spd);
                self.level = FSSF(@"%d", resistance);
                self.frequency = FSSF(@"%d", frequency);
                self.heartRate = FSSF(@"%d", heart_Rate);
                self.watt = FSSF(@"%d", watt);
                self.incline = FSSF(@"%d", slope);
                self.paragraph = FSSF(@"%d", duanshu);
            } else if (subcmd == SectionParamStatusSleep) { // 睡眠
                FSLog(@"睡眠");
            } else if (subcmd == SectionParamStatusRunning) { // 运行中
                FSLog(@"运行中"); // 02 42 02 0000 00 0000 79 0000 00 02 3b 03
// 开始02 状态42 运行02 速度0000 阻力00 频率0000 心率79 瓦特0000 坡度00  段数02 检验3b 结束03
                uint spd   = [self readUShort:databytes + 3];
                uint resistance    = databytes[5];
                uint frequency   = [self readUShort:databytes + 6];
                uint heart_Rate   = databytes[8];
                uint watt    = [self readUShort:databytes + 9];

                uint slope  = databytes[11];
                uint duanshu = databytes[12];
                FSLog(@"0305 速度%d 阻力%d 频率%d 心率%d 瓦特%d 坡度%d 段数%d", spd, resistance, frequency, heart_Rate, watt, slope, duanshu);
                self.speed = FSSF(@"%d", spd);
                self.level = FSSF(@"%d", resistance);
                self.frequency = FSSF(@"%d", frequency);
                self.heartRate = FSSF(@"%d", heart_Rate);
                self.watt = FSSF(@"%d", watt);
                self.incline = FSSF(@"%d", slope);
                self.paragraph = FSSF(@"%d", duanshu);

            } else if (subcmd == SectionParamStatusStarting) { // 启动中
                FSLog(@"启动中");
            }
        }
            break;
        case SectionData: {
            // 判断二级指令
            if (subcmd == SectionDataSportData) { // 获取运动信息
                uint runtime     = [self readUShort:databytes + 3];
                uint distance = [self readUShort:databytes + 3];
                uint calory = [self readUShort:databytes + 7];
                uint count    = [self readUShort:databytes + 9];
                // !!!: 距离赋值的地方
                if (databytes[6] & 0x80) { // 判断是不是以10米为单位的
                    FSLog(@"距离单位:::10米");
                    distance = MAKEWORD(databytes[5], databytes[6] & 0x7f) * 10;
                } else {
                    FSLog(@"距离单位:::米");
                    distance = MAKEWORD(databytes[5], databytes[6]);
                }
                self.eElapsedTime = FSSF(@"%d", runtime);
                self.distance = FSSF(@"%d", distance);
                self.calory = FSSF(@"%d", calory);
                self.counts = FSSF(@"%d", count);
                FSLog(@"0305 时间%d 距离%d 卡路里%d  计数%d", runtime, distance, calory, count);
            } else if (subcmd == SectionDataSportInfo) { // 获取用户信息

            } else if (subcmd == SectionDataProgramData) { // 获取程式信息

            }
        }
            break;
        case SectionControl: {
            // 判断二级指令
            if (subcmd == SectionControlStart) { // 开始、继续
//                    PLog(@"控制指令.....开始、继续");

            } else if (subcmd == SectionControlStep) { // 设置步进  设置阻力  坡度
//                    PLog(@"控制指令.....设置步进  设置阻力  坡度");

            } else if (subcmd == SectionControlStop) { // 停止
//                    PLog(@"控制指令.....停止");

            } else if (subcmd == SectionControlUser) { // 写入用户信息
//                    PLog(@"控制指令.....写入用户信息");

            } else if (subcmd == SectionControlPause) { // 暂停
//                    PLog(@"控制指令.....暂停");

            } else if (subcmd == SectionControlReady) { // 准备就绪
//                    PLog(@"控制指令.....准备就绪");

            } else if (subcmd == SectionControlProgram) { // 设置程式模式
//                    PLog(@"控制指令.....设置程式模式");

            }  else if (subcmd == SectionControlSportMode) { // 运动模式
//                    PLog(@"控制指令.....运动模式");

            } else if (subcmd == SectionControlFunctionSwitch) { // 功能开关
//                    PLog(@"控制指令.....功能开关");

            } else if (subcmd == SectionControlParam) { // 设置参数  阻力、坡度
//                    PLog(@"控制指令.....设置参数  阻力、坡度");
            }
        }
            break;
        default:
            break;
    }
}


@end
