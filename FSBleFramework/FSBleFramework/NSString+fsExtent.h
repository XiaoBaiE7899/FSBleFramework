

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (fsExtent)

// 设备信息的保持路径，使用plist文件格式存储，扫描设备，
+ (NSString *)deviceInfoFilePath;

// JSON字符串转字典
- (NSDictionary *(^)(void))fsToDictionary;

// 转发才转数组
- (NSArray *(^)(void))fsToArray;

// 乘  例如： 5 * 5  调用方式：@"5".fsMul(@"5")  返回 @"25"
- (NSString *(^)(NSString *))fsMul; // *

// 除  例如： 5 / 5  调用方式：@"5".fsDiv(@"5")  返回@"1"
- (NSString *(^)(NSString *))fsDiv; // /

// 保留多少位小数  调用方式: @"3.14159".decimalPlace(2) 返回：3.14
- (NSString *(^)(NSInteger))decimalPlace;

@end

NS_ASSUME_NONNULL_END
