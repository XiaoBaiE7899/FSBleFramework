

#import "NSString+fsExtent.h"
#import "BleManager.h"

@implementation NSString (fsExtent)

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

/// 乘
- (NSString *(^)(NSString *))fsMul {
    if (kFSIsEmptyString(self)) {
        return ^NSString *(NSString *value) {
            return @"0.00";
        };
    }
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:self];
    return ^NSString *(NSString *value) {
        if (kFSIsEmptyString(value)) {
            return @"0.00";
        }
        NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:value];
        NSDecimalNumber *resultNum = [num1 decimalNumberByMultiplyingBy:num2];
        return [resultNum stringValue];
    };
}

/// 除
- (NSString *(^)(NSString *))fsDiv {
    if (kFSIsEmptyString(self)) {
        return ^NSString *(NSString *value) {
            return @"0.00";
        };
    }
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:self];
    return ^NSString *(NSString *value) {
        if (kFSIsEmptyString(value)) {
            return @"0.00";
        }
        if ([value isEqualToString:@"0"]) {
            return @"0.00";
        }
        
        if ([value isEqualToString:@"0"]) {
            return @"0.00";
        }
        
        NSDecimalNumber *num2 = [NSDecimalNumber decimalNumberWithString:value];
        NSDecimalNumber *resultNum = [num1 decimalNumberByDividingBy:num2];
        return [resultNum stringValue];
    };
}

@end
