
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FSEnum.h"

NS_ASSUME_NONNULL_BEGIN

// 蓝牙模块
@interface FSBleModule : NSObject

/* 蓝牙外设 */
@property (nonatomic, readonly) CBPeripheral  * _Nonnull  peripheral;

/* 模块的名字 */
@property (nonatomic, readonly) NSString      * _Nonnull  name;

/* 蓝牙信号量 调用setRssi 更新信号量 */
@property (nonatomic, readonly) int               rssi;

/* 蓝牙外设的服务标识 */
@property (nonatomic, readonly) NSString      * _Nonnull uuid;

/* 蓝牙广播包 */
@property (nonatomic, readonly) NSDictionary  * _Nonnull advertisementData;

/* 通过广播包的数据获取的蓝牙厂商信息 */
@property (nonatomic, readonly) NSData        * _Nullable manufacturerData;

/* 通过广播包的数据获取的 服务UUID 设置广播包数据的同事设置了 */
@property (nonatomic, readonly) NSArray <CBUUID *>     * _Nullable discover;

/* 通过广播包的数据获取 重写getter方法 */
@property (nonatomic, readonly) NSArray <CBService *>  * _Nullable services;

/* 是不是运动秀的蓝牙模块 */
@property (nonatomic, readonly) BOOL    isFitshow;

/* 设备id 通过广播包的12个字节解析得到的 */
@property (nonatomic, readonly) NSString               * _Nullable deviceID;

/* 设备系列号 通过广播的12个字节解析得到的 */
@property (nonatomic, readonly) NSString               * _Nullable serial;

/* 设备类型 通过广播的12个字节解析得到的 */
@property (nonatomic, readonly) FSDeviceType   type;

// 设备类型的字符串 重写getter方法 FIXME: 这个属性不需要开放给被人使用
@property (nonatomic, copy) NSString * _Nullable typeString;

/* 蓝牙协议类型 重写getter方法 */
@property (nonatomic, assign) BleProtocolType protocolType;

// FIXME: 蓝牙协议 可能有多中协议，旧的SDK 只有跑步机和车表， 跳绳可能不一样，筋膜枪也可以不一样，改为用枚举来处理
//@property (nonatomic, assign) BOOL isTreadmillProtocol;

/* 判断是不是步数设备  只有跑步机和椭圆机是 步数设备, 重写了getter方法，内部通过type判断返回 */
@property (nonatomic, assign) BOOL isStepsDevice;

// MARK: 以下几个属性必须满意2个条件，1：必须是运动秀的设备  2：必须连接成功 default is @""
/* 模块厂商 */
@property (nonatomic, readonly) NSString               * _Nullable manufacturer;

/* 模块机型 */
@property (nonatomic, readonly) NSString               * _Nullable model;

/* 硬件版本 */
@property (nonatomic, readonly) NSString               * _Nullable hardware;

/* 软件版本 */
@property (nonatomic, readonly) NSString               * _Nullable software;

// MARK: 初始化的时候设置peripheral、name、uuid
- (instancetype _Nonnull )initWithPeripheral:(CBPeripheral *_Nonnull)peripheral;

/// 设置广播包，manufacturerData、discover、services 一起设置
- (void)setAdvertisementData:(NSDictionary * _Nonnull)advertisementData;

/// 更新蓝牙信号量
- (void)setRssi:(int)rssi;

@end

@interface FSBleDevice : NSObject

@property (nonatomic, strong) FSBleModule *module;

- (void)disconnect;

/// 将要断连
- (void)willDisconnect;

@end

NS_ASSUME_NONNULL_END
