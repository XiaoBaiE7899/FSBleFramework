

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (fsExtent)

// 字段转JSON字符串
- (NSString *(^)(void))fsToJsonString;

@end

NS_ASSUME_NONNULL_END
