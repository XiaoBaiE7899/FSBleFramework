
// FS 蓝牙库的枚举文件

#ifndef FSEnum_h
#define FSEnum_h

// 系统蓝牙的 状态，只有FSManagerStatePoweredOn 可以使用
typedef NS_ENUM(NSInteger, FSManagerState) {
    /* 蓝牙电源已关闭 */
    FSManagerStatePoweredOff,
    /* 正常可用状态 */
    FSManagerStatePoweredOn,
    /* 设备不支持蓝牙功能 */
    FSManagerStateUnsupported,
};


/*
 蓝牙协议类型
 */
typedef NS_ENUM(NSInteger, BleProtocolType) {
    /* 未知*/
    BleProtocolTypeUnknow         = -1,
    /* 跑步机 */
    BleProtocolTypeTreadmill      = 0,
    /* 椭圆机 */
    BleProtocolTypeSection       = 1,
};


// MARK: 设备连接状态
typedef NS_ENUM(NSInteger, ConnectState) {
    /* 设备未连接 */
    ConnectStateDisconnected,
    /* 正在连接中 */
    ConnectStateConnecting,
    /* 重新连接中 */
    ConnectStateReconnecting,
    /* 已连接 */
    ConnectStateConnected,
    /* 已经工作 */
    ConnectStateWorking,
};

// MARK: 设备断连类型
typedef NS_ENUM(NSInteger, DisconnectType) {
    /* 初始状态  设备还没开始连接 */
    DisconnectTypeNone,
    /* 用户主动断连 */
    DisconnectTypeUser,
    /* 连接超时断连 */
    DisconnectTypeTimeout,
    /* 开关关闭断连 */
    DisconnectTypePoweredOff,
    /* 没有找到服务断连 */
    DisconnectTypeService,
    /* 无响应断连 */
    DisconnectTypeResponse,
    /* 连接异常 */
    DisconnectTypeAbnormal,
};

/*
 设备类型
 通过蓝牙扫描得到的广播包 解析得到的
 */
typedef NS_ENUM(NSInteger, FSDeviceType) {
    /* 跑步机 */
    FSDeviceTypeTreadmill      = 0,
    /* 椭圆机 */
    FSDeviceTypeEllipse        = 1,
    /* 健身车 */
    FSDeviceTypeFitnessCar     = 2,
    /* 划船器 */
    FSDeviceTypeRowing         = 3,
    /* 骑马器 */
    FSDeviceTypeRider          = 4,
    /* 走步机 */
    FSDeviceTypeWalking        = 5,
    /* 跳绳  这个协议还没增加进来 */
    FSDeviceTypeUnknow
};

// 运动秀  蓝牙设备的状态
typedef NS_ENUM(NSInteger, FSDeviceState) {
    /* MARK: 一个未知状态 开始连接的时候，初始化就是这个状态 */
    FSDeviceStateNone = -1,
    /* 待机 */
    FSDeviceStateNormal,
    /* 启动中 */
    FSDeviceStateStarting,
    /* 运行中 */
    FSDeviceStateRunning,
    /* 已暂停 */
    FSDeviceStatePaused,
    /* 故障 */
    FSDeviceStateError,
    /* 跑步机 已停机状态(还未返回到待机) */
    FSDeviceStateTreadmillEnd,
    /* 跑步机 减速停止中(完全停止后变为 PAUSED 或 END 或 NORMAL) */
    FSDeviceStateTreadmillStopping,
    /* 跑步机 禁用（安全开关或睡眠等）（1.1 修改） */
    FSDeviceStateTreadmillDisable,
    /* 跑步机  禁止启动状态(设备处于不允许运行状态) */
    FSDeviceStateTreadmillDisRun,
    /* 设备就绪（1.1）CONTROL_READY 指令后应为此状态 */
    FSDeviceStateTreadmillReady,
    /* 车表  睡眠*/
    FSDeviceStateSectionSleep,
};

#endif /* FSEnum_h */
