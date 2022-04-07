
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FSFrameworkEnum.h"
@class BleModule;
@class BleCommand;
@class BleManager;
@class BleDevice;

@protocol BleDeviceDelegate <NSObject>

@optional

- (void)device:(BleDevice *_Nonnull)device didConnectedWithState:(FSConnectState)state;

- (void)device:(BleDevice *_Nonnull)device didDisconnectedWithMode:(FSDisconnectType)mode;

- (void)device:(BleDevice *_Nonnull)device didFailedSend:(BleCommand *_Nonnull)cmd;

- (void)deviceError:(BleDevice *_Nonnull)device;

- (void)deviceDidUpdateState:(FSDeviceState)newState fromState:(FSDeviceState)oldState;

/*
 210604
 MARK: 通过设备上的启动键启动设备
 通过指令不能启动设备，除了运行中、暂停、安全锁脱落已知问题，其他都要提示从设备上启动，蓝牙连接不能断，这个时候监听设备的状态变化，如果设备的状态发生变化，进入到启动中或者运行中的状态，应该做也切换
 */
- (void)deviceStartOnPhysicalKey:(BleDevice *_Nonnull)device;



@end


NS_ASSUME_NONNULL_BEGIN

@interface BleDevice : NSObject  <CBPeripheralDelegate>

// 蓝牙管理器用弱引用
@property (nonatomic,   weak) BleManager      * _Nullable manager;

@property (nonatomic,   weak) id <BleDeviceDelegate>      _Nullable  deviceDelegate;

// 蓝牙订阅特征
@property (nonatomic, strong) CBCharacteristic  * _Nullable bleNotifyChar;

// 蓝牙写入特征
@property (nonatomic, strong) CBCharacteristic  * _Nullable bleWriteChar;

@property (nonatomic, assign) FSDeviceState    oldStatus;

@property (nonatomic, assign) FSDeviceState    currentStatus;

@property (nonatomic, strong) BleModule        *module;

@property (nonatomic, assign) BOOL             isConnected;

@property (nonatomic, assign) uint             reconnect;

@property (nonatomic, assign) FSDisconnectType disconnectType;

@property (nonatomic, assign) FSConnectState    connectState;

@property (nonatomic, assign) uint cntError, cntFail;

@property (nonatomic, strong) NSMutableArray<BleCommand *> * _Nullable commands;

@property (nonatomic, assign) BOOL accidentalReconnect;

@property (nonatomic, assign) BOOL getParamSuccess;

@property (nonatomic, assign) BOOL resending; // 是否正在重发指令

@property (nonatomic, strong) NSTimer *_Nullable sendCmdTimer; // 发送指令定时

- (instancetype _Nonnull )initWithModule:(BleModule *_Nonnull)module;

- (void)sendCmdData:(CBCharacteristic *_Nonnull)character data:(NSData *_Nonnull)data;

- (void)sendCommand:(BleCommand *_Nullable)command;

- (void)connent:(id<BleDeviceDelegate>_Nonnull)delegate;

- (void)willDisconnect;

// 设备断连
- (void)disconnect;

- (void)clearSend; // 清除指令

- (void)disconnectWith:(FSDisconnectType)mode;

// CX
- (void)onDisconnected;

- (void)removeFromManager;

- (BOOL)onService;

- (void)onConnected;

- (void)onFailedSend:(BleCommand *_Nullable)cmd;

- (BOOL)onUpdateData:(BleCommand *_Nullable)cmd;

- (void)deviceInfoData;

- (BOOL)moduleInfoAgterConnented:(CBCharacteristic *)chat;

- (void)commit;

@end

NS_ASSUME_NONNULL_END
