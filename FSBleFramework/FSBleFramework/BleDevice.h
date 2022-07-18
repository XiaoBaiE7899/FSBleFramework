
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FSFrameworkEnum.h"
@class BleModule;
@class BleCommand;
@class BleManager;
@class BleDevice;

// 自定义 设备代理
@protocol BleDeviceDelegate <NSObject>

@optional

/*
 外设连接回调
 选中一台设备连接，此方法会多次回调，只有当状态为:FSConnectStateWorking, 表示指令通讯正常
 */
- (void)device:(BleDevice *_Nonnull)device didConnectedWithState:(FSConnectState)state;

/*
 外设断链回调 device如果为空不会回调
 蓝牙连接过程中，所有非主动断链，都会通过这个方法回调是什么问题断链
 */
- (void)device:(BleDevice *_Nonnull)device didDisconnectedWithMode:(FSDisconnectType)mode;

/*
 指令失败：一条指令连续发送3次，设备没响应，这个指令将会从队列中删除，并且通过这个方法把数据回调出来
 */
- (void)device:(BleDevice *_Nonnull)device didFailedSend:(BleCommand *_Nonnull)cmd;

/*
 设备故障，模块通信正常，但是查询状态的时候，有故障码，则SDK内部会先做断链处理，然通过这个回调处理
 比如：下控通讯失败，一般收到这个回调，提示用户设备故障就行，
 */
- (void)deviceError:(BleDevice *_Nonnull)device;

/*
 设备状态改变
 在连接过程中，因为不同协议，需要做不同状态处理，这里把模块当成单片机处理，初始状态为:-1,当状态切换的时候，通过此回调把蓝牙的新旧状态数据传出来
 */
- (void)deviceDidUpdateState:(FSDeviceState)newState fromState:(FSDeviceState)oldState;

/*
 210604
 MARK: 通过设备上的启动键启动设备, 新的SDK 不会执行该回调，可以忽略
 通过指令不能启动设备，除了运行中、暂停、安全锁脱落已知问题，其他都要提示从设备上启动，蓝牙连接不能断，这个时候监听设备的状态变化，如果设备的状态发生变化，进入到启动中或者运行中的状态，应该做也切换
 */
- (void)deviceStartOnPhysicalKey:(BleDevice *_Nonnull)device;



@end


NS_ASSUME_NONNULL_BEGIN

@interface BleDevice : NSObject  <CBPeripheralDelegate>

// 中心管理
@property (nonatomic,   weak) BleManager      * _Nullable manager;

// 自定设备代理
@property (nonatomic,   weak) id <BleDeviceDelegate>      _Nullable  deviceDelegate;

// 蓝牙订阅特征
@property (nonatomic, strong) CBCharacteristic  * _Nullable bleNotifyChar;

// 蓝牙写入特征
@property (nonatomic, strong) CBCharacteristic  * _Nullable bleWriteChar;

// 旧状态
@property (nonatomic, assign) FSDeviceState    oldStatus;

// 新状态
@property (nonatomic, assign) FSDeviceState    currentStatus;

// 模块信息
@property (nonatomic, strong) BleModule        *module;

// 是否已连接
@property (nonatomic, assign) BOOL             isConnected;

// 重连次数
@property (nonatomic, assign) uint             reconnect;

// 断链类型
@property (nonatomic, assign) FSDisconnectType disconnectType;

// 连接类型
@property (nonatomic, assign) FSConnectState    connectState;

// 错误与失败次数
@property (nonatomic, assign) uint cntError, cntFail;

// 指令队列
@property (nonatomic, strong) NSMutableArray<BleCommand *> * _Nullable commands;

// 是否为意外重新，连接中突然，车表比较容易出现
@property (nonatomic, assign) BOOL accidentalReconnect;

// 获取设备参数成功
@property (nonatomic, assign) BOOL getParamSuccess;

// 指令是否重发
@property (nonatomic, assign) BOOL resending;

// 发送指令的定时器  发送频率500ms一条
@property (nonatomic, strong) NSTimer *_Nullable sendCmdTimer;

// 通过模块信息初始化  设备
- (instancetype _Nonnull )initWithModule:(BleModule *_Nonnull)module;


/// 指令发送  测试指令使用，不推荐使用
/// @param character 特征
/// @param data 指令数据
- (void)sendCmdData:(CBCharacteristic *_Nonnull)character data:(NSData *_Nonnull)data;


/// 指令发送，
/// @param command 抽象指令实例，具体请阅读BleCommand类 相关介绍
- (void)sendCommand:(BleCommand *_Nullable)command;


/// 统一连接方法
/// @param delegate 外设代理，必须有实参并且不能为空
- (void)connent:(id<BleDeviceDelegate>_Nonnull)delegate;

// 将要断链，这连接过程中，SDK内部调用，
- (void)willDisconnect;

// 设备断连
- (void)disconnect;

// 清除指令
- (void)clearSend;

// 带类型的断连，运动秀模块不会执行这个方法，这个类通过代理回调或者断连的类型属性访问
- (void)disconnectWith:(FSDisconnectType)mode;

// ------CX!!----------

// 设备已经断连，如果是运动型的模块断链， 停止定时器:1发送指令定时器，2心跳包的定时器
- (void)onDisconnected;

// 把该设备从管理中删除  这个方法不不需要
- (void)removeFromManager;

/*
 查找必要的服务，运动秀的模块，必须找到FFF1、FFF2两个通道，通讯才有可能成功，
 SDK内部已经做了处理，外部调用关心代理的回调就行
 */
- (BOOL)onService;

/*
 中心已连接成功  执行的方法
 */
- (void)onConnected;


/// 指令返送失败  特殊指令处理
/// @param cmd 失败的指令
- (void)onFailedSend:(BleCommand *_Nullable)cmd;


/// 更新模块上报数据  SDK使用中，不需要关系这些写方法的调用与处理，内部把数据处理完以后会发送通知
/// @param cmd 上报指令
- (BOOL)onUpdateData:(BleCommand *_Nullable)cmd;

// 获取设备信息
- (void)deviceInfoData;

// 连接以后需要获取的数据，只有运动秀的模块，中心连接成功以后才需要获取数据(模块厂商、模块机型、软件版本、硬件版本)
- (BOOL)moduleInfoAgterConnented:(CBCharacteristic *)chat;

// 提交指令，
- (void)commit;

@end

NS_ASSUME_NONNULL_END
