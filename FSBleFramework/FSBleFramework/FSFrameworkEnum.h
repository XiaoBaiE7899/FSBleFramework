
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

typedef NS_ENUM(int, FSCentralState) {
    FSCentralStatePoweredOff,  // 系统蓝牙没开
    FSCentralStatePoweredOn,   // 蓝牙可以使用
    FSCentralStateUnsupported, // 设备不支持
};

typedef NS_ENUM(int, BleProtocolType) {
    BleProtocolTypeUnknow         = -1, // 未知
    BleProtocolTypeTreadmill      = 0,  // 跑步机
    BleProtocolTypeSection        = 1,  // 车表
    BleProtocolTypeSlimming       = 2,  // 甩脂机、筋膜枪
    BleProtocolTypeRope           = 3,  // 跳绳、健腹轮、摸高挑
};

typedef NS_ENUM(int, FSConnectState) {
    FSConnectStateDisconnected,
    FSConnectStateConnecting,
    FSConnectStateReconnecting,
    FSConnectStateConnected,
    FSConnectStateWorking,     // 数据收发正常才能进入这个状态
};

typedef NS_ENUM(int, FSDisconnectType) {
    FSDisconnectTypeNone,
    FSDisconnectTypeWithoutResponse,
    FSDisconnectTypeTimeout,
    FSDisconnectTypeUser,
    FSDisconnectTypeService,
    FSDisconnectTypeAbnormal,
};

typedef NS_ENUM(int, FSSportType) {
    FSSportTypeFree           = -1,
    FSSportTypeTreadmill      = 0,
    FSSportTypeEllipse        = 1,
    FSSportTypeFitnessCar     = 2,
    FSSportTypeRowing         = 3,
    FSSportTypeRider          = 4,
    FSSportTypeWalking        = 5,
    FSSportTypeSkipRope       = 6,
    FSSportTypeFasciaGun      = 7,
    FSSportTypeAbdominalWheel = 8,
    FSSportTypeSlimming       = 9,
    FSSportTypeArtificial     = 10,
    FSSportTypeTouchHigh      = 12,
    FSSportTypePower          = 13,
};


// 设备状态
typedef NS_ENUM(int, FSDeviceState)  {
    FSDeviceStateDefault = -1,
    FSDeviceStateNormal,
    FSDeviceStateStarting,
    FSDeviceStateRunning,
    FSDeviceStatePaused,
    FSDeviceStateError,
    FSDeviceStateTreadmillEnd,
    FSDeviceStateTreadmillStopping,
    FSDeviceStateTreadmillDisable,
    FSDeviceStateTreadmillDisRun,
    FSDeviceStateTreadmillReady,
    FSDeviceStateSectionSleep,
};

typedef NS_ENUM(NSInteger, FSDiscontrolType) {
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


// 故障代码
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
