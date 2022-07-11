
#import <Foundation/Foundation.h>
//#import "BleManager.h"
@class BleManager;
@class FSBaseDevice;
@class FSDeviceInfo;

NS_ASSUME_NONNULL_BEGIN

@interface FSBleTools : NSObject

/*
 可以通过后台返回设备信息，保存到到Document做本地缓存，
 下一次扫描到该设备，直接重本地缓存获取，不需要到后台拉取数据
 */
+ (void)createDeviceInfoPlistFileWith:(NSArray *)array;

// 从本地的plist文件中读取设备信息，本地没保持，返回nil
+ (FSDeviceInfo *)readDeviceInfoFromPlistFile:(FSBaseDevice *)device;

@end

NS_ASSUME_NONNULL_END
