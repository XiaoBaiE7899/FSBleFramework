

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BleDevice.h"
#import "FSFrameworkEnum.h"

extern NSString *_Nonnull const FITSHOW_UUID;
extern NSString *_Nonnull const FTMS_UUID;
extern NSString *_Nonnull const FITSHOW_DEVICEINFO;
extern NSString *_Nonnull const kUpdateFitshoData;
extern NSString *_Nonnull const kFitshowHasStoped;
extern NSString *_Nonnull const kCmdUncontrolled;

@class BleManager;

@protocol FSCentralDelegate <NSObject>

@required

- (void)manager:(BleManager *_Nonnull)manager didUpdateState:(FSCentralState)state;

@optional

- (void)manager:(BleManager *_Nonnull)manager willScanWithServices:(NSMutableArray <CBUUID *> *_Nullable)services;

- (BOOL)manager:(BleManager *_Nonnull)manager willDiscoverDevice:(BleDevice *_Nonnull)device;

- (void)manager:(BleManager *_Nonnull)manager didDiscoverDevice:(BleDevice *_Nonnull)device;

- (void)manager:(BleManager *_Nonnull)manager didNearestDevice:(BleDevice *_Nonnull)device;

- (BleDevice *_Nullable)manager:(BleManager *_Nonnull)manager didUnknownModule:(BleModule *_Nonnull)modele;

@end

NS_ASSUME_NONNULL_BEGIN



@interface BleManager : NSObject <CBCentralManagerDelegate>

// 中心代理
@property (nonatomic,   weak) id<FSCentralDelegate>  delegate;

// 中心状态
@property (nonatomic, assign) FSCentralState   CentralState;

// 管理器的设备
@property (nonatomic, strong) NSMutableArray   *devices;

// 是否正在扫描
@property (nonatomic, assign) BOOL             isScaning;

// 执行扫描的的uuids
@property (nonatomic, strong) NSMutableArray   *scanUUIDs;

// 中心管理器
@property (nonatomic, strong) CBCentralManager *centralManager;

// 最近的设备
@property (nonatomic, strong) BleDevice  *_Nullable nearest;

// 初始化方法
+ (BleManager *)managerWithDelegate:(id <FSCentralDelegate>)delegate;

// 获取管理器，不能使用这个方法初始化管理器实例
+ (BleManager *)manager;

// 是否授权
+ (BOOL)HasAuthorized;

// 开始扫描
- (BOOL)startScan;

// 停止扫描
- (void)stopScan;

/// 清除管理器
- (void)cleanManager;

/// 断连所有设备
- (void)disconnectAllDevicesInManager;


// CX
- (BleDevice *)discoverModule:(BleModule *)module;

- (void)findNearestDevice;

@end

NS_ASSUME_NONNULL_END
