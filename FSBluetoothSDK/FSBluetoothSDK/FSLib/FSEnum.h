
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
    BleProtocolTypeCarTable       = 1,
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

// 蓝牙命令 开始 && 结束
typedef NS_ENUM(NSInteger, BLE_CMD) {
    /* 指令帧头 */
    BLE_CMD_START   = 0x02,
    /* 指令帧尾 */
    BLE_CMD_END     = 0x03,
};

#pragma mark 跑步机
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
    readmillStartModePogram     = 5,
};

#pragma mark 车表协议
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
typedef NS_ENUM(NSInteger, CARTABLE_STATUS) { // normal  0x02 0x42 0x42 0x03
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
typedef NS_ENUM(NSInteger, CARTABLE_DATA) {
    /* 获取0x02 0x43 0x01 0x43 0x03 ：  时间W 距离W 热量W 计数W */
    SectionDataSportData      = 0x01,
    /* 获取0x02 0x43 0x02 0x41 0x03：  用户L 运动L 模式B 段数B 目标W */
    SectionDataSportInfo      = 0x02,
    /*  获取：  索引B 数据N  这个可能不会用到 */
    SectionDataProgramData    = 0x03,   //
};

// 车表控制
typedef NS_ENUM(NSInteger, CARTABLE_CONTROL) {
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
typedef NS_ENUM(NSInteger, CARTABLE_START_MODE) {
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

#endif /* FSEnum_h */
