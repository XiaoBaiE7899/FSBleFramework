
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FSFrameworkEnum.h"


NS_ASSUME_NONNULL_BEGIN


@interface BleCommand : NSObject

@property (nonatomic, strong) CBCharacteristic * _Nonnull chrt;
@property (nonatomic, strong) NSData           * _Nullable data;
@property (nonatomic, assign) int              sendCnt;

+ (instancetype _Nullable )make:(CBCharacteristic *_Nullable)object data:(NSData *_Nonnull)data;

@end

@interface BleModule : NSObject

@property (nonatomic, readonly) CBPeripheral * _Nonnull  peripheral;
@property (nonatomic, readonly) NSString     * _Nonnull name;
@property (nonatomic, readonly) BOOL         fsNewAd;
// S
@property (nonatomic,   assign) int          rssi;
@property (nonatomic,   strong) NSDictionary * _Nonnull advertisementData;

@property (nonatomic, readonly) NSString     * _Nonnull uuid;
@property (nonatomic,   strong) NSData       * _Nullable manufacturerData;
@property (nonatomic,   strong) NSArray <CBUUID *> * _Nullable discover;
@property (nonatomic, readonly) NSArray <CBService  *> * _Nullable services; // G
// def: NO
@property (nonatomic, readonly) BOOL    isFitshow;
@property (nonatomic,     copy) NSString  * _Nullable deviceID;
@property (nonatomic,     copy) NSString  * _Nullable factory;
@property (nonatomic,     copy) NSString  * _Nullable machineCode;
@property (nonatomic, readonly) NSString  * _Nullable serial;
@property (nonatomic,   assign) FSSportType sportType;
/// G
@property (nonatomic,     copy) NSString * _Nullable typeString;
@property (nonatomic,   assign) BOOL     isTreadmillProtocol;
@property (nonatomic,   assign) BOOL     isSectionProtocol;
@property (nonatomic,   assign) BOOL     isStepsDevice;

// 指令集
@property (nonatomic,  strong) NSMutableArray<BleCommand *> * _Nullable commands;

@property (nonatomic,  assign) BleProtocolType protocolType; // G


// 运动秀的设备 && 必须连接成功 default is @""
@property (nonatomic,    copy) NSString    * _Nullable manufacturer;
// 机型
@property (nonatomic,    copy) NSString    * _Nullable model;
@property (nonatomic,    copy) NSString    * _Nullable hardware;
@property (nonatomic,    copy) NSString    * _Nullable software;

/// 初始化模块信息
+ (BleModule *_Nonnull)moduleWithType:(FSSportType)type;

- (instancetype _Nonnull )initWithPeripheral:(CBPeripheral *_Nonnull)peripheral;

@end

NS_ASSUME_NONNULL_END
