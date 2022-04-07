
#import <Foundation/Foundation.h>
//#import "BleManager.h"
@class BleManager;
@class FSBaseDevice;
@class FSDeviceInfo;

NS_ASSUME_NONNULL_BEGIN

@interface FSBleTools : NSObject

// 字典转json字符串
//+ (NSString*)ditionaryToJsonSting:(NSDictionary *)dic;

// json字符串 转 字典
//+ (NSDictionary *)jsonStingToDictionary:(NSString *)string;

// json字符串 转 数组
//+ (NSArray *)jsonStingToArray:(NSString *)string;

// data 转 字符串
//+ (NSString *)dataToString:(NSData *)data;

// 设备信息的缓存文件，如果文件存在返回文件路径，否则返回:@""
//+ (NSString *)deviceInfoFilePath;

+ (void)createDeviceInfoPlistFileWith:(NSArray *)array;

// 从本地的plist文件中读取设备信息，本地没保持，返回nil
+ (FSDeviceInfo *)readDeviceInfoFromPlistFile:(FSBaseDevice *)device;

@end

NS_ASSUME_NONNULL_END
