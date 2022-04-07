
#import "NSDictionary+fsExtent.h"

@implementation NSDictionary (fsExtent)

- (NSString *(^)(void))fsToJsonString {
    return ^ NSString * {
        NSAssert(self,@"数据不能为空!");
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&parseError];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    };
}

@end
