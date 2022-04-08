
#import "BleModule.h"
#import "FSFrameworkEnum.h"
#import "BleManager.h"


@implementation BleCommand

+ (instancetype)make:(CBCharacteristic *)object data:(NSData *)data {
    BleCommand *cmd = [BleCommand new];
    cmd.chrt        = object;
    cmd.data        = data;
    cmd.sendCnt     = 3;
    return cmd;
}

@end

@interface BleModule ()

@end

@implementation BleModule

#pragma mark 对外开放的方法
- (instancetype _Nonnull )initWithPeripheral:(CBPeripheral *_Nonnull)peripheral {
    if (self = [super init]) {
        _peripheral        = peripheral;
        _name              = peripheral.name;
        _uuid              = peripheral.identifier.UUIDString;
        _advertisementData = NSMutableDictionary.dictionary;
        _isFitshow         = NO;
        _manufacturer      = @"";
        _model             = @"";
        _hardware          = @"";
        _software          = @"";
        _deviceID          = @"";
        _serial            = @"";
        _protocolType      = BleProtocolTypeUnknow;
        _sportType         = FSSportTypeFree;
    }
    return self;
}

+ (BleModule *)moduleWithType:(FSSportType)type {
    BleModule *module = [BleModule new];
    module.sportType  = type;
    return module;
}

- (void)setAdvertisementData:(NSDictionary *)advertisementData {
    // FIXME: XB 重写属性的方法  分析广播包
//    FSLog(@"重写ad_Data.setter方法，模块名称:%@", self.name);
    _advertisementData = advertisementData;
    _manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey];
    _discover = advertisementData[CBAdvertisementDataServiceUUIDsKey];

    if (!_manufacturerData ||
        kFSIsEmptyString(self.name)) {
        _isFitshow = NO;
        return;
    }
    // 没有FFF0: FitShow-2DF91E
    // 包含FFF0与1826  
    if ([self.name isEqualToString:@"FitShow-386EE3"]) {
        FSLog(@"测试设备");
    }

    Byte *adBytes = (Byte *)self.manufacturerData.bytes;

    if (_manufacturerData.length == 12) {
        uint device = MAKEDWORD(adBytes[0], adBytes[1], adBytes[2], adBytes[3]);
        _sportType   = device >> 28; // 右移28位，获取高4位
        if (_sportType == FSSportTypeTreadmill ||
            _sportType == FSSportTypeEllipse   ||
            _sportType == FSSportTypeFitnessCar ||
            _sportType == FSSportTypeRowing     ||
            _sportType == FSSportTypeRider      ||
            _sportType == FSSportTypeWalking ||
            _sportType == FSSportTypeArtificial
            ) {
            [self fsOldAdvertisement:adBytes];
        }
    }

    // MARK: 20211215 新广播包是8位
    if (_manufacturerData.length == 8) {
        [self fsNewAdvertisement:adBytes];
    }

    // 华为的  跳绳  广播包 是7位
//    if (_manufacturerData.length == 7) {
//        [self hw_ropeAdvertisement:adBytes];
//    }
    // 华为的  7D02  开头  && FFF0
    [self hw_testAdType:adBytes];
}

//- (void)setRssi:(int)rssi {
//    FSLog(@"重写rssi.setter方法，看看能不能进来");
//}

#pragma mark 广播包解析
- (void)fsOldAdvertisement:(Byte *)data {
    uint device = MAKEDWORD(data[0], data[1], data[2], data[3]);
    _fsNewAd    = NO;
    _isFitshow  = YES;
    _deviceID   = [NSString stringWithFormat:@"%u", device];
    _factory    = [NSString stringWithFormat:@"%u", device >> 16 & 0x0fff];
    _machineCode = [NSString stringWithFormat:@"%u", device & 0xffff];
    uint serialNum = MAKEDWORD(data[4], data[5], data[6], data[7]);
    _serial = [NSString stringWithFormat:@"%u", serialNum];
//    FSLog(@"AD旧：设备类型：%d, 设备id:%@, 厂商码%@, 机型码：%@, 序列号：%@",_sportType, _deviceID, _factory, _machineCode, _serial);
}

// 新的广播包解析
- (void)fsNewAdvertisement:(Byte *)data {
    /* !!!: 20211103
     7D 02: 华为的，固定的  跳绳名字：HL022E6CDE
     90 CB: 运动秀，固定的
     uint8_t vendorID[] = {0x7D, 0x02};
     uint8_t vendorID[] = {0xCB, 0x90};
     */
    // MARK: 20211203 AB确认，没出过货的全局使用新的广播包解析
    uint8_t FS_ID[] = {0x90, 0xCB};
    if (MAKEWORD(FS_ID[0], FS_ID[1]) == MAKEWORD(data[0], data[1])) {
        _fsNewAd         = YES;
        _isFitshow       = YES;
        _sportType       = MAKEWORD(data[2], data[3]);
        int factory_code = MAKEWORD(data[4], data[5]);
        _factory         = [NSString stringWithFormat:@"%d", factory_code];//SF(@"%d", factory_code);
        int machine_Code = MAKEWORD(data[6], data[7]);
        _machineCode     = [NSString stringWithFormat:@"%d", machine_Code];//SF(@"%d", machine_Code);
        _deviceID        = @"0";
        _serial          = @"0";
//        FSLog(@"AD旧：设备类型：%d, 设备id:%@, 厂商码%@, 机型码：%@, 序列号：%@",_sportType, _deviceID, _factory, _machineCode, _serial);
        return;
    }
}

- (void)hw_ropeAdvertisement:(Byte *)data {
    uint8_t HUAWEI[] = {0x7D, 0x02};
    if (MAKEWORD(HUAWEI[0], HUAWEI[1]) == MAKEWORD(data[0], data[1])) {
        _fsNewAd     = YES;
        _isFitshow   = YES;
        _sportType   = data[2];
        _factory     = @"0";
        _machineCode = @"0";;
        _deviceID    = @"0";
        _serial      = @"0";
//        FSLog(@"AD_HW：设备类型：%d, 设备id:%@, 厂商码%@, 机型码：%@, 序列号：%@",_sportType, _deviceID, _factory, _machineCode, _serial);
    }
}

// 测试华为广播包
- (void)hw_testAdType:(Byte *)data {
    uint8_t HUAWEI[] = {0x7D, 0x02};
    if (MAKEWORD(HUAWEI[0], HUAWEI[1]) == MAKEWORD(data[0], data[1]) &&
        [self includeFitshowUUid]) {
        _fsNewAd     = YES;
        _isFitshow   = YES;
        // MARK: 22.4.8  设备类型先写死跑步机
        _sportType   = FSSportTypeTreadmill;
        _factory     = @"0";
        _machineCode = @"0";;
        _deviceID    = @"0";
        _serial      = @"0";
    }
}

- (BOOL)includeFitshowUUid {
    BOOL rst = NO;
    for (CBUUID *obj in self.discover) {
        if ([obj.UUIDString isEqualToString:FITSHOW_UUID]) {
            FSLog(@"包含运动秀的UUID  %@", obj.UUIDString);
            return YES;
        }
    }
    return rst;
}

// FTMS 广播包
- (void)fs_ftmsAdtype:(Byte *)data {

}

#pragma mark setter && getter
- (NSArray<CBService *> *)services {
    return _peripheral.services;
}

- (BOOL)isTreadmillProtocol {
    if (self.sportType == FSSportTypeTreadmill ) {
        return YES;
    }
    return NO;
}

- (BOOL)isSectionProtocol {
    switch (self.sportType) {
        case FSSportTypeEllipse:
        case FSSportTypeFitnessCar:
        case FSSportTypeRowing:
        case FSSportTypeRider:
        case FSSportTypeWalking:
        case FSSportTypeArtificial: {
            return YES;
        }
            break;

        default: {
            return NO;
        }
            break;
    }
}

- (BOOL)isMinDevice {
    // !!!: 根据协议类型判断是不是小件 22.4.1
    if (self.protocolType == BleProtocolTypeTreadmill ||
        self.protocolType == BleProtocolTypeSection) {
        return NO;
    }
    return YES;
}

- (BleProtocolType)protocolType {
    switch (self.sportType) {
        case FSSportTypeTreadmill: {
            return BleProtocolTypeTreadmill;
        }
            break;
        case FSSportTypeEllipse:
        case FSSportTypeFitnessCar:
        case FSSportTypeRowing:
        case FSSportTypeRider:
        case FSSportTypeWalking:
        case FSSportTypeArtificial: {
            return BleProtocolTypeSection;
        }
            break;
        case FSSportTypeSkipRope:
        case FSSportTypeAbdominalWheel:
        case FSSportTypeTouchHigh: {
            return BleProtocolTypeRope;
        }
            break;
        case FSSportTypeFasciaGun:
        case FSSportTypeSlimming: {
            return BleProtocolTypeSlimming;
        }
            
        default:
            return BleProtocolTypeUnknow;
            break;
    }
}



// FIXME: 这个不需要重写 getter方法，应该重写sportType的setter方法逻辑更好
- (NSString *)typeString {
    _typeString = @"";
    switch (self.sportType) {
        case FSSportTypeTreadmill:
        case FSSportTypeArtificial:{
            _typeString = @"k_treadmill";
        }
            break;
        case FSSportTypeEllipse:{
            _typeString = @"k_elliptical";
        }
            break;
        case FSSportTypeRowing: {
            _typeString = @"k_rowing";
        }
            break;
        case FSSportTypeRider: {
            _typeString = @"k_riding";
        }
            break;;
        case FSSportTypeWalking:{
            _typeString = @"k_walk_step";
        }
            break;
        case FSSportTypeFitnessCar:{
            _typeString = @"k_bike";
        }
            break;
        case FSSportTypeSlimming:{
            _typeString = @"k_slimming";
        }
            break;
        case FSSportTypeSkipRope:{
            _typeString = @"k_rope_skipping";
        }
            break;
        case FSSportTypeAbdominalWheel: {
            _typeString = @"k_wheel";
        }
            break;
        case FSSportTypePower: {
            _typeString = @"k_power_device";
        }
            break;
        default:
            _typeString = @"k_undefined_type";
            break;
    }
    return _typeString;
}

@end
