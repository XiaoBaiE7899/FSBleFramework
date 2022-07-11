
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FSFrameworkEnum.h"


NS_ASSUME_NONNULL_BEGIN

/*
 指令 实例， 在SDK实际集成中，指令都在SDK内部处理，外部调用不会使用到此类
 */
@interface BleCommand : NSObject

// 可写特征
@property (nonatomic, strong) CBCharacteristic * _Nonnull chrt;
// 指令数据
@property (nonatomic, strong) NSData           * _Nullable data;
// 发送次数
@property (nonatomic, assign) int              sendCnt;

// 创建指令
+ (instancetype _Nullable )make:(CBCharacteristic *_Nullable)object data:(NSData *_Nonnull)data;

@end

/*
 蓝牙模块
 最基础的蓝牙设备，中心扫描外设，可以得到外设实例peripheral和广播包，
 协议类型、运动类类型(设备类型)都是通过广播包数据得到的
 */
@interface BleModule : NSObject

// 外设
@property (nonatomic, readonly) CBPeripheral * _Nonnull  peripheral;

// 名字
@property (nonatomic, readonly) NSString     * _Nonnull name;

// 是不是为新的广播包， 默认是NO
@property (nonatomic, readonly) BOOL         fsNewAd;

// 蓝牙信号，在扫描中实时更新
@property (nonatomic,   assign) int          rssi;

// 最原始的蓝牙广播包数据
@property (nonatomic,   strong) NSDictionary * _Nonnull advertisementData;

// 外设的UUID，
@property (nonatomic, readonly) NSString     * _Nonnull uuid;

// 广播包中的厂商数据
@property (nonatomic,   strong) NSData       * _Nullable manufacturerData;

// 广播包中的UUIDS
@property (nonatomic,   strong) NSArray <CBUUID *> * _Nullable discover;

// 外设的服务
@property (nonatomic, readonly) NSArray <CBService  *> * _Nullable services;

// 是否为运动秀的模块，def: NO  符合运动秀广播包是解析规则，才会为YES
@property (nonatomic, readonly) BOOL    isFitshow;

// 设备id，def：@"0"
@property (nonatomic,     copy) NSString  * _Nullable deviceID;

// 厂商码， def:@"0"
@property (nonatomic,     copy) NSString  * _Nullable factory;

// 机型码， def:@"0"
@property (nonatomic,     copy) NSString  * _Nullable machineCode;

// 系列号， def:@"0"
@property (nonatomic, readonly) NSString  * _Nullable serial;

// 设备类型，通过解析广播包数据得到,def:FSSportTypeFree
@property (nonatomic,   assign) FSSportType sportType;
/*
 设备类型的字符串，适配多语音使用的key，
 跑步机：k_treadmill
 椭圆机：k_elliptical
 划船器：k_rowing
 骑马器：k_riding
 走步机：k_walk_step
 健身车：k_bike
 甩脂机：k_slimming
 跳绳：  k_rope_skipping
 健腹轮：k_wheel
 理疗器械：k_power_device
 */
@property (nonatomic,     copy) NSString * _Nullable typeString;

// 是否为 跑步机协议
@property (nonatomic,   assign) BOOL     isTreadmillProtocol;

// 是否为 车表协议
@property (nonatomic,   assign) BOOL     isSectionProtocol;

// 是否为计步设备
@property (nonatomic,   assign) BOOL     isStepsDevice;

// 指令集
@property (nonatomic,  strong) NSMutableArray<BleCommand *> * _Nullable commands;

// 类写类型
@property (nonatomic,  assign) BleProtocolType protocolType;

/*
 以下的属性的默认值：@""
 只有当模块是运动秀的模块，连接成功才能有修改其值
 */
// 模块厂商
@property (nonatomic,    copy) NSString    * _Nullable manufacturer;

// 模块机型
@property (nonatomic,    copy) NSString    * _Nullable model;

// 软件版本
@property (nonatomic,    copy) NSString    * _Nullable hardware;

// 硬件版本
@property (nonatomic,    copy) NSString    * _Nullable software;

/// 初始化模块信息
+ (BleModule *_Nonnull)moduleWithType:(FSSportType)type;

// 根据扫描到的外设，初始化模块信息
- (instancetype _Nonnull )initWithPeripheral:(CBPeripheral *_Nonnull)peripheral;

@end

NS_ASSUME_NONNULL_END
