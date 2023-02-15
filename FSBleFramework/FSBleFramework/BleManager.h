

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BleDevice.h"
#import "FSFrameworkEnum.h"

// 运动指定的UUID
extern NSString *_Nonnull const FITSHOW_UUID;
// FTMS的UUID: FTMS协议还没对接
extern NSString *_Nonnull const FTMS_UUID;
// 本地缓存设备的信息的文件
extern NSString *_Nonnull const FITSHOW_DEVICEINFO;



// 通知-------
// 蓝牙模块上报数据，完成数据解析后，通过这个通知发出去
extern NSString *_Nonnull const kUpdateFitshoData;
// 当设备完全停止，会发出这个通知
extern NSString *_Nonnull const kFitshowHasStoped;
// 已下发控制指令，但是设备无响应，发通知
extern NSString *_Nonnull const kCmdUncontrolled;
// 意外断连
extern NSString *_Nonnull const kBleDisconnect;

@class BleManager;

// 蓝牙中心代理回调
@protocol FSCentralDelegate <NSObject>

@required

// 系统蓝牙状态发生改变，扫描设备之前，只有FSCentralStatePoweredOn 才可能扫描到设备
- (void)manager:(BleManager *_Nonnull)manager didUpdateState:(FSCentralState)state;

@optional

// 指定扫描UUID, 如果运动秀的设备，不需要实现这个代理方法，内部已经做了处理
- (void)manager:(BleManager *_Nonnull)manager willScanWithServices:(NSMutableArray <CBUUID *> *_Nullable)services;

// 将要发现设备，可以通过返回NO,限制扫描到的设备加入管理的设备数组
- (BOOL)manager:(BleManager *_Nonnull)manager willDiscoverDevice:(BleDevice *_Nonnull)device;

// 当已扫描的设备已加入管理的设备数组，回调这个方法
- (void)manager:(BleManager *_Nonnull)manager didDiscoverDevice:(BleDevice *_Nonnull)device;

// 发现最近的设备，目前只有在运动秀的app上使用，22.1 以后对因为需求变更，这个也不需要调用
- (void)manager:(BleManager *_Nonnull)manager didNearestDevice:(BleDevice *_Nonnull)device;

// 发现未知模块，正常通过子类扫描，不需要实现这个方法，
- (BleDevice *_Nullable)manager:(BleManager *_Nonnull)manager didUnknownModule:(BleModule *_Nonnull)modele;

@end

NS_ASSUME_NONNULL_BEGIN


// 蓝牙中心管理器，建议使用子类(扫描指定UUID)扫描，逻辑比较简单， 判断比较少，比如扫描运动秀的设备是使用FSManager实例对象扫描
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

// 获取管理器，调用此方法不会初始化管理，因为无法通过代理把扫描的数据传处理
+ (BleManager *)manager;

/*
 是否授权
 iOS 13 以前，可以直接使用系统扫描设备，
 iOS 13 以后，调用系统蓝牙扫描时，必须选授权，如果没有授权，直接调用扫描程序会闪退
 PS:
 
 iOS 13, 调用startScan返回NO，应该先判断系统蓝牙是否授权，没有授权是不可能扫描到设备的
 
 */
+ (BOOL)HasAuthorized;

/*
 开始扫描:
 只有返回YES，表示当前可以扫描，
 当时中心正在扫描，或者 中心管理的在状态为FSCentralStatePoweredOn，就会返回NO， iOS 13 以上系统，没有授权也扫描不到设备
 */
- (BOOL)startScan;

/*
 停止扫描
 因为蓝牙扫描比较耗性能，每次扫描的时间为10秒，在蓝牙通讯范围之类，10秒足够把附近设备扫描出来
 SDK内部已经对这方面做了优化，
 
 为了业务逻辑需要，在调用startScan之前，先停止扫描，确保不会因为蓝牙中心正在扫描到时而返回NO
 */
- (void)stopScan;

/// 清除管理器  执行这个方法以后，蓝牙中心会被置空，需要扫描的必须重新初始化
- (void)cleanManager;

/// 断连所有设备
- (void)disconnectAllDevicesInManager;


/*
 发现蓝牙模块，这个方法在SDK  扫描到外设的时候内部使用，
 子类通过实现这个方式，可以做到使用不同实例对象扫描可以得到不同设备，如：使用运动秀的FSManager实例可以得到运动型的设备，确保不同协议返回不同设备，业务逻辑完全解耦， 不会因为协议不同，导致内部逻辑混乱
 */
- (BleDevice *)discoverModule:(BleModule *)module;


// 发现最近的设备，如果业务需要，管理需要实现这个方法，具体逻辑有需要子类具体实现
- (void)findNearestDevice;

@end

NS_ASSUME_NONNULL_END
