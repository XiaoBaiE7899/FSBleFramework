
#import "FSBleTools.h"
#import "BleManager.h"
#import "FSBleDeice.h"
#import "BleModule.h"
#import "NSString+fsExtent.h"

@implementation FSBleTools

+ (void)createDeviceInfoPlistFileWith:(NSArray *)array {
    // 数据安全过滤
    if (!array || array.count == 0) {
        return;
    }
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:FITSHOW_DEVICEINFO];
    // 读取缓存文件
    NSArray *didCache = [NSArray arrayWithContentsOfFile:filePath];
    // 判断缓存文件是否已经存在
    FSDeviceInfo *info = [FSDeviceInfo modelWithDictionary:[array firstObject]];
    for (NSDictionary *dic in didCache) {
        FSDeviceInfo *obj = [FSDeviceInfo modelWithDictionary:dic];
        // 判断是否相等
        if (obj.type.intValue == info.type.intValue &&
            obj.factory.intValue == info.factory.intValue &&
            obj.model.intValue == info.model.intValue) {
            // 保持过了 直接返回
            return;
        }
    }
    // MARK: 22.3.30 必须这么做，否则，会把的所有的数据覆盖掉
    NSMutableArray *m_cache = [NSMutableArray arrayWithArray:didCache];
    [m_cache addObjectsFromArray:array];
    // FIXME: 这个需要测试是不是会直接覆盖原来的文件
    [m_cache writeToFile:filePath atomically:YES];
}

+ (FSDeviceInfo *)readDeviceInfoFromPlistFile:(FSBaseDevice *)device {
    // 先判断文件上是否存在，如果文件存在，在去便利，如果文件
    NSString *path = [NSString deviceInfoFilePath];
    if (kFSIsEmptyString(path)) {
        FSLog(@"设备信息的plist文件不存在，直接返回");
        return nil;
    }
    // 能走到这里，说明文件已经存在，直接读取就可以
    NSArray *devices = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *dic in devices) {
        NSNumber *type = dic[@"type"];
        NSNumber *factory = dic[@"factory"];
        NSNumber *model = dic[@"model"];
        // 设备类型，厂商码，机型码  全部一致才能返回信息
        if (type.intValue == device.module.sportType &&
            factory.intValue == device.module.factory.intValue &&
            model.intValue == device.module.machineCode.intValue) {
            //  找到设备了，直接赋值
            FSDeviceInfo *info = [FSDeviceInfo modelWithDictionary:dic];
            device.deviceInfo = info;
            return info;
        }
    }
    return nil;
}

@end
