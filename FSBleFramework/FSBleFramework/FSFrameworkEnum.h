
#ifndef FSFrameworkEnum_h
#define FSFrameworkEnum_h

#if (DEBUG == 1)
#define FSLog(string, ...) NSLog(@"FSFramework %@ 🔥 <%d>🔥 %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(string), ##__VA_ARGS__])
#else
#define FSLog(string, ...)
#endif

#define kFSIsEmptyString(str)  ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 || [str isEqualToString:@"<null>"] || [str isEqualToString:@"(null)"] ? YES : NO )

#define FSFM(format, ...) ([NSString stringWithFormat:(format), ##__VA_ARGS__])

#define UUID(x)             [CBUUID UUIDWithString:(x)]
#define MAKELONG(a, b)      (uint)((uint)(a) | ((uint)(b) << 16))
#define MAKEWORD(a, b)      (uint)((uint)(a) | ((uint)(b) << 8))
#define FSMAKEWORD(a, b)    (uint)((uint)((uint)(b) << 8) | (a))
#define MAKEDWORD(a,b,c,d)  (uint)(MAKELONG(MAKEWORD(a, b), MAKEWORD(c, d)))


// 系统蓝牙的 状态
typedef NS_ENUM(int, FSCentralState) {
    FSCentralStatePoweredOff,  // 系统蓝牙没开
    /*
     蓝牙可以使用，PS:只有这个状态，蓝牙才可以扫描到设备
     */
    FSCentralStatePoweredOn,
    FSCentralStateUnsupported, // 设备(主要指手机)不支持
};

/*
   蓝牙协议，不同协议，指令不同，
   通过解析广播包数据，得到设备类型，具体如下：
   设备类型为： 请参考: FSSportType
     0：BleProtocolTypeTreadmill
     1、2、3、4、5：BleProtocolTypeSection
     7、9:BleProtocolTypeSlimming
     6、8、12：BleProtocolTypeRope
  特别注意：
  FSSportTypeArtificial:设备为机械跑步机：使用的是车表协议，
 */
typedef NS_ENUM(int, BleProtocolType) {
    BleProtocolTypeUnknow         = -1, // 未知
    BleProtocolTypeTreadmill      = 0,  // 跑步机
    BleProtocolTypeSection        = 1,  // 车表
    BleProtocolTypeSlimming       = 2,  // 甩脂机、筋膜枪
    BleProtocolTypeRope           = 3,  // 跳绳、健腹轮、摸高挑
};

/*
 蓝牙连接状态，连接状态发送改变是，会通过代理回调，使用设备的属性：connectState 访问
 */
typedef NS_ENUM(int, FSConnectState) {
    /*
     蓝牙断链，默认为这个状态
     */
    FSConnectStateDisconnected,
    /*
     正在连接
     */
    FSConnectStateConnecting,
    /*
     重新中
     */
    FSConnectStateReconnecting,
    /*
     蓝牙已连接成功：只有当蓝牙中心连接成功，并且发现对应的服务的UUID,才会回调这个状态
     即使回调这个状态，也补代表蓝牙通讯正常
     */
    FSConnectStateConnected,
    /*
     蓝牙连接成功，发送指令有回复，回调这个状态，回调这个状态，表示：蓝牙不仅连接成功，而且通讯正常
     */
    FSConnectStateWorking,
};

/*
 蓝牙断链的类型， 会通过回调断链的类型，使用设备的属性：disconnectType访问
 */
typedef NS_ENUM(int, FSDisconnectType) {
    /* 默认状态 */
    FSDisconnectTypeNone,
    /* 指令没响应，连接9调指令没有回复，回调 */
    FSDisconnectTypeWithoutResponse,
    /* 连接超时，每次连接2秒，连续连接3次失败，就会超时 */
    FSDisconnectTypeTimeout,
    /* 程序主动断开连接，这个状态不会回调 */
    FSDisconnectTypeUser,
    /* 蓝牙中心连接成功，但是没有找打对应服务UUID,回调这个状态 */
    FSDisconnectTypeService,
    FSDisconnectTypeAbnormal,
};

/*
 运动类型，就是设备类型，
 */
typedef NS_ENUM(int, FSSportType) {
    /* 默认设备类型 */
    FSSportTypeFree           = -1,
    /* 跑步机 */
    FSSportTypeTreadmill      = 0,
    /* 椭圆机  或者称为：交叉训练机 */
    FSSportTypeEllipse        = 1,
    /* 健身车 */
    FSSportTypeFitnessCar     = 2,
    /* 划船器 */
    FSSportTypeRowing         = 3,
    /* 骑马器 没有见过这个种设备 */
    FSSportTypeRider          = 4,
    /* 走步机，大部分工厂的走步机的类型是使用 跑步机协议，最大速度一般在6KM/H */
    FSSportTypeWalking        = 5,
    /* 跳绳 */
    FSSportTypeSkipRope       = 6,
    /* 筋膜枪 */
    FSSportTypeFasciaGun      = 7,
    /* 健腹轮 */
    FSSportTypeAbdominalWheel = 8,
    /* 甩脂机 */
    FSSportTypeSlimming       = 9,
    /* 机械跑步机 使用的车表协议 */
    FSSportTypeArtificial     = 10,
    /* 摸高跳，协议已经调通，还未实际设备测试 */
    FSSportTypeTouchHigh      = 12,
    /* 力量器械，协议已经调通，还未爱实际设备测试 */
    FSSportTypePower          = 13,
};


/*
 设备状态  SDK  根据实际设备重构了，
 */
typedef NS_ENUM(int, FSDeviceState)  {
    // 默认状态
    FSDeviceStateDefault = -1,
    // 待机  只有当设备处于正常待机状态，才能通过蓝牙指令启动设备
    FSDeviceStateNormal,
    // 启动倒计时
    FSDeviceStateStarting,
    // 设备已经运行，
    FSDeviceStateRunning,
    /*
     暂停状态，
     FS:因为很多厂家没有严格按照协议做，
     内部对这个这个做了很多兼容，建议新接入的厂家，严格按照协议对接
     */
    FSDeviceStatePaused,
    FSDeviceStateError,
    FSDeviceStateTreadmillEnd,
    FSDeviceStateTreadmillStopping,
    FSDeviceStateTreadmillDisable,
    FSDeviceStateTreadmillDisRun,
    FSDeviceStateTreadmillReady,
    FSDeviceStateSectionSleep,
};

/*
 设备失控类型  可以通过：discontrolType属性方法获取具体是哪个参数不能控制
 由于多种原因，会出现设备启动以后，
 指令下发，通过串口工具也可以抓取到数据，但是设备并没有反映，出现这种状态，理解为设备失控，
 
 具体的控制参数根据设备参数判断，
 PS: 跑步机：  速度(必须参数)、停止(必须参数)、坡度(可选参数)
     车表：    停止(必须参数)、坡度(可选参数)、阻力(可选参数)
 
 当设备下发控制指令以后，2秒后设备没有响应，就判定为失控，这个时候会发送通知：kCmdUncontrolled
 */
typedef NS_ENUM(NSInteger, FSDiscontrolType) {
    FSDiscontrolTypeNone,          // 初始化状态
    FSDiscontrolTypeSpeed,         // 速度
    FSDiscontrolTypeIncline,       // 坡度
    FSDiscontrolTypeResistance,    // 阻力
    FSDiscontrolTypeStop,          // 停止
};

// 以下是甩脂机的指令
typedef NS_ENUM(NSInteger, FSDeviceErrorCode) {
    /* 甩脂机故障  过流报警 */
    SlimmingOvercurrentAlarm,
    /* 甩脂机故障  通讯故障 */
    SlimmingCommunicationFail,
    /* 甩脂机故障  电机丢失故障 */
    SlimmingMotorLossFailure,
    /* 甩脂机故障  断线报警 */
    SlimmingDisconnectionAlarm,
    /* 甩脂机故障  接收数据失败 */
    SlimmingFailedReceiveData,
    /* 甩脂机故障  控制器故障 */
    SlimmingControllerFailure,
    /* 甩脂机故障  其它故障 */
    SlimmingOtherFailures
};


// 甩脂机 故障代码
typedef NS_ENUM(NSInteger, SlimmingError) {
    /*  过流报警  */
    SlimmingErrorO1  = 0xA1,
    /*  通讯故障  */
    SlimmingErrorO2  = 0xA2,
    /*  电机丢失故障  */
    SlimmingErrorO3  = 0xA3,
    /*  断线报警  */
    SlimmingErrorO4  = 0xA4,
    /*  接收数据失败  */
    SlimmingErrorO5  = 0xA5,
    /*  控制器故障  */
    SlimmingErrorO6  = 0xA6,
    /*  其它故障  */
    SlimmingErrorO7  = 0xA7,
};

// 手动档和自动档标志位，1为手动，0为自动。自动模式P1~P3，手动模式
typedef NS_ENUM(NSInteger, SlimmingMode) {
    /* 默认样式，几乎没使用到 */
    SlimmingModeDefault   = 0x00,
    /*  甩脂  */
    SlimmingRejectionFat  = 0x02,
    /*  平移  */
    SlimmingTranslation   = 0x04,
    /*  震动  */
    SlimmingVibration     = 0x08,
    /*  P1(自动模式)元气  */
    SlimmingModeAutoP1    = 0x10,
    /*  P2(自动模式)舒活  */
    SlimmingModeAutoP2    = 0x20,
    /*  P3(自动模式)瑜伽  */
    SlimmingModeAutoP3    = 0x30,
    /*  P1(手动模式)甩脂  */
    SlimmingModeHandP1    = 0xA1,
    /*  P2(手动模式)平移  */
    SlimmingModeHandP2    = 0xA2,
    /*  P3(手动模式)震动  */
    SlimmingModeHandP3    = 0xA3,
    /*  P4(手动模式)甩脂+平移  */
    SlimmingModeHandP4    = 0xA4,
    /*  P5(手动模式)甩脂+震动  */
    SlimmingModeHandP5    = 0xA5,
    /*  P6(手动模式)震动+平移  */
    SlimmingModeHandP6    = 0xA6,
    /*  P7(手动模式)震动+平移+甩脂  */
    SlimmingModeHandP7    = 0xA7,
};

// 甩脂机切换音乐
typedef NS_ENUM(NSInteger, SlimmingSwitchMusic) {
    /*  未操作 volume control */
    SwitchMusicNone  = 0,
    /*  上一曲  */
    SwitchMusicLast  = 1,
    /*  下一曲  */
    SwitchMusicNext  = 2,
};

// 甩脂机音量控制
typedef NS_ENUM(NSInteger, SlimmingVolumeControl) {
    /*  未操作音量，不加不减 */
    VolumeControlNone    = 0,
    /*  音量加  */
    VolumeControlAdd     = 1,
    /*  音量减  */
    VolumeControlReduce  = 2,
};

// 甩脂机音量控制
typedef NS_ENUM(NSInteger, FSCountersControlType) {
    /*  启动自由跳绳 */
    FSCountersControlTypeFree        = 1,
    /*  启动定时计时  */
    FSCountersControlTypeTime        = 2,
    /*  启动定时计数  */
    FSCountersControlTypeCount       = 3,
    /* 暂停 */
    FSCountersControlTypePause       = 4,
    /* 恢复 */
    FSCountersControlTypeRecover     = 5,
    /* 停止 */
    FSCountersControlTypeStop        = 6,
    /* 启动同步历史记录 */
    FSCountersControlTypeHistory     = 7,
    /* 结束同步历史记录 */
    FSCountersControlTypeStopHistory = 8
};



#endif
