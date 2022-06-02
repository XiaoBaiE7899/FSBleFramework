

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

// 保留多少位小数
- (NSString *(^)(NSInteger))decimalPlace {
    return ^NSString *(NSInteger place) {
        if (!self) {
            return @"";
        }
        if (kFSIsEmptyString(self)) {
            return @"";
        }
        NSArray *array = [self componentsSeparatedByString:@"."];
        if (place == 0) { // 不保留小数，直接把小数部分舍去
            return [array firstObject];
        }
        switch (array.count) {
            case 1:{
//                [NSString stringWithFormat:@"%@.0", self]
                return place == 1 ? FSFM(@"%@.0", self) : FSFM(@"%@.00", self);
            }
                break;
            case 2:{
                NSString *str1  = [array firstObject];
                NSString *str2 = [array lastObject];
                // 小数部分后面添加几个0，然后取对应的位数
                NSString *temp = FSFM(@"%@00000000000000", str2);
                return FSFM(@"%@.%@", str1, [temp substringToIndex:place]);
            }
                break;

            default:{
                return @"";
            }
                break;
        }
    };
}

@end
