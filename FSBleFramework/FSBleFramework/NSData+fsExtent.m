
#import "NSData+fsExtent.h"

@implementation NSData (fsExtent)

- (NSString *(^)(void))fstoString {
    return ^ NSString * {
        NSString *s = @"";
        Byte *buf = (Byte *)self.bytes;
        for (uint i = 0; i < self.length; i++) {
            s = [s stringByAppendingFormat:@"%02X ", buf[i]];
        }
        return s;
    };
}

@end
