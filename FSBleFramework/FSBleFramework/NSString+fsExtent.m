//
//  NSString+fsExtent.m
//  FSBleFramework
//
//  Created by 林文圻 on 2022/4/7.
//

#import "NSString+fsExtent.h"
#import "BleManager.h"

@implementation NSString (fsExtent)

//- (NSDictionary *(^)(void))fsToDictionary {
//
//}

+ (NSString *)deviceInfoFilePath {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:FITSHOW_DEVICEINFO];
    return filePath;
}

-(NSDictionary * (^)(void))fsToDictionary {
    return ^ NSDictionary * {
        if (self == nil) {
            return @{};
        }
        NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        if(err)
        {
            NSLog(@"json解析失败：%@",err);
            return nil;
        }
        return dic;
    };
}

- (NSArray *(^)(void))fsToArray {
    return  ^ NSArray * {
        if (!self) return nil;
        id tmp = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:nil];
        if ([tmp isKindOfClass:[NSArray class]]) {
            return tmp;
        } else if([tmp isKindOfClass:[NSString class]]
                  || [tmp isKindOfClass:[NSDictionary class]]) {
            return [NSArray arrayWithObject:tmp];
        }
        return nil;
    };
}

@end
