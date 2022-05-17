

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (fsExtent)

+ (NSString *)deviceInfoFilePath;

- (NSDictionary *(^)(void))fsToDictionary;

- (NSArray *(^)(void))fsToArray;

- (NSString *(^)(NSString *))fsMul; // *

- (NSString *(^)(NSString *))fsDiv; // /

@end

NS_ASSUME_NONNULL_END
