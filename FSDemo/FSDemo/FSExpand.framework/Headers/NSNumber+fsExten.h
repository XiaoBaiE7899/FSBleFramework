// MARK: 20.12.1为了兼容旧的数据，意外后台返回的数据为 nsnumber型，实际代码运行时调用的是字符串类目的方法引起异常

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (fsExten)

- (NSString *(^)(void))fs_paceTimeFormat;

- (NSString *(^)(NSInteger))decimalPlace;

@end

NS_ASSUME_NONNULL_END
