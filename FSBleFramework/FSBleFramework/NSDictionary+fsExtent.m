//
//  NSDictionary+fsExtent.m
//  FSBleFramework
//
//  Created by 林文圻 on 2022/4/7.
//

#import "NSDictionary+fsExtent.h"

@implementation NSDictionary (fsExtent)

- (NSString *(^)(void))fstoJsonString {
    return ^ NSString * {
        NSAssert(self,@"数据不能为空!");
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&parseError];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    };
}

@end
