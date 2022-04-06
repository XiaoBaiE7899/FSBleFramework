
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Extension)
// 转字符串
- (NSString *(^)(void))toString;

// 返回图片的格式
- (NSString *)imageDataFormat;

@end

NS_ASSUME_NONNULL_END
