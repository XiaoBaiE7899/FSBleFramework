
// 自定义蓝牙库的代理文件

#import <Foundation/Foundation.h>
#import "FSEnum.h"

@class FSCentralManager;
@class FSBleDevice;
@class FSBleModule;


/// 自定义中心管理器代理
@protocol FSCentralDelegate <NSObject>

@required

/// 系统蓝牙中心管理器状态发生改变
/// @param manager 中心管理器
/// @param state 状态
- (void)manager:(FSCentralManager *_Nonnull)manager didUpdateState:(FSManagerState)state;

/// 扫描得到的设备，如果子类没重写discoverModule，会执行这个代理方法，返回BLEObject 对象
- (FSBleDevice *_Nullable)manager:(FSCentralManager *_Nonnull)manager didUnknownModule:(FSBleModule *_Nonnull)modele;

/// 将要发现新设备 代理可以通过返回NO来拒绝添加当前设备
/// @param manager 蓝牙管理器
/// @param device 外设
- (BOOL)manager:(FSCentralManager *_Nonnull)manager willDiscoverDevice:(FSBleDevice *_Nonnull)device;

/// 已经发现新设备 外设已加管理器中的devices 中
/// @param manager 蓝牙管理器
/// @param device 外设
- (void)manager:(FSCentralManager *_Nonnull)manager didDiscoverDevice:(FSBleDevice *_Nonnull)device;

/// 更新最新设备 暂时只有 运动秀的设备才参与排名
/// @param manager 管理器
/// @param device 最新的设备
- (void)manager:(FSCentralManager *_Nonnull)manager didNearestDevice:(FSBleDevice *_Nonnull)device;

@optional

@end



