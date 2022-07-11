
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (fsExtent)

// nsdata 实例对象转成字符串，用于指令调试，
- (NSString *(^)(void))fsToString;

@end

NS_ASSUME_NONNULL_END
