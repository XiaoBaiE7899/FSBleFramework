//
//  NSString+fsExtent.h
//  FSBleFramework
//
//  Created by 林文圻 on 2022/4/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (fsExtent)

+ (NSString *)deviceInfoFilePath;

- (NSDictionary *(^)(void))fsToDictionary;

- (NSArray *(^)(void))fsToArray;

@end

NS_ASSUME_NONNULL_END
