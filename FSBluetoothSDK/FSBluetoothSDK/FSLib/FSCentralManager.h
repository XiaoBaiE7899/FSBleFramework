// 蓝牙中心管理器
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "FSEnum.h"
#import "FSDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSCentralManager : NSObject <CBCentralManagerDelegate>

/// iOS 13以后，调用系统蓝牙库需要系统授权
@property (nonatomic, assign) BOOL hasAuthorized;

/// 蓝牙管理的的状态
@property (nonatomic, assign, readonly) FSManagerState  mgrState;

/// 蓝牙是否正在扫描
@property (nonatomic, assign, readonly) BOOL isScaning;

/// 自定义代理
@property (nonatomic, assign) id <FSCentralDelegate> centralDelegate;

// 蓝牙中心 FIXME: 这个属性不需要开放出去
@property (nonatomic, strong) CBCentralManager    *centralManager;

/// 扫描指定的 服务 当前类初始化的同时初始化
@property (nonatomic, strong) NSMutableArray       *services;

/// 管理器的设备 lazy loading
@property (nonatomic, strong) NSMutableArray       *devices;

/// 初始化方法
+ (FSCentralManager *)managerWithDelegate:(id <FSCentralDelegate>)delegate;

// 这个方法只是为了获取蓝牙中心对象，初始化不能用这个方法 FIXME: 这个方法是否真的需要开放
+ (FSCentralManager *)manager;

/// 扫描外设，蓝牙未开启返回NO
- (BOOL)startScan;

/// 停止扫描
- (void)stopScan;







@end

NS_ASSUME_NONNULL_END
