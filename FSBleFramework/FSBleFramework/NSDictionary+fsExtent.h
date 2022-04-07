//
//  NSDictionary+fsExtent.h
//  FSBleFramework
//
//  Created by 林文圻 on 2022/4/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (fsExtent)

- (NSString *(^)(void))fstoJsonString;

@end

NS_ASSUME_NONNULL_END
