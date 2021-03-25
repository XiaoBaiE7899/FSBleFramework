
// 自定义蓝牙库的代理文件

#import <Foundation/Foundation.h>
#import "FSEnum.h"

@class FSCentralManager;
@class BleDevice;
@class BleModule;


/// 自定义中心管理器代理
@protocol FSCentralDelegate <NSObject>

@required

/// 系统蓝牙中心管理器状态发生改变
/// @param manager 中心管理器
/// @param state 状态
- (void)manager:(FSCentralManager *_Nonnull)manager didUpdateState:(FSManagerState)state;

@optional
/// 扫描得到的设备，如果子类没重写discoverModule，会执行这个代理方法，返回BLEObject 对象
- (BleDevice *_Nullable)manager:(FSCentralManager *_Nonnull)manager didUnknownModule:(BleModule *_Nonnull)modele;

/// 将要发现新设备 代理可以通过返回NO来拒绝添加当前设备
/// @param manager 蓝牙管理器
/// @param device 外设
- (BOOL)manager:(FSCentralManager *_Nonnull)manager willDiscoverDevice:(BleDevice *_Nonnull)device;

/// 已经发现新设备 外设已加管理器中的devices 中
/// @param manager 蓝牙管理器
/// @param device 外设
- (void)manager:(FSCentralManager *_Nonnull)manager didDiscoverDevice:(BleDevice *_Nonnull)device;

/// 更新最新设备 暂时只有 运动秀的设备才参与排名
/// @param manager 管理器
/// @param device 最新的设备
- (void)manager:(FSCentralManager *_Nonnull)manager didNearestDevice:(BleDevice *_Nonnull)device;

@end

@protocol FSDeviceDelegate <NSObject>

@optional
/// 蓝牙设备 连接成功
/// @param device 成功的设备
/// @param state 状态
- (void)device:(BleDevice *_Nonnull)device didConnectedWithState:(ConnectState)state;


/// 蓝牙设备断开连接
/// @param device 断连的设备
/// @param mode 断连类型
- (void)device:(BleDevice *_Nonnull)device didDisconnectedWithMode:(DisconnectType)mode;

/// 设备故障
- (void)deviceError:(BleDevice *_Nonnull)device;



/// 设备状态改变
/// @param device 连接的设备
/// @param newState 当前状态
/// @param oldState 就状态
- (void)device:(BleDevice *_Nonnull)device currentState:(FSDeviceState)newState oldState:(FSDeviceState)oldState;


@end



