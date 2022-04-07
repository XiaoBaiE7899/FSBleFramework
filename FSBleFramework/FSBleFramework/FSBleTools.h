
#import <Foundation/Foundation.h>
//#import "BleManager.h"
@class BleManager;
@class FSBaseDevice;
@class FSDeviceInfo;

NS_ASSUME_NONNULL_BEGIN

@interface FSBleTools : NSObject

+ (void)createDeviceInfoPlistFileWith:(NSArray *)array;

// 从本地的plist文件中读取设备信息，本地没保持，返回nil
+ (FSDeviceInfo *)readDeviceInfoFromPlistFile:(FSBaseDevice *)device;

@end

NS_ASSUME_NONNULL_END
