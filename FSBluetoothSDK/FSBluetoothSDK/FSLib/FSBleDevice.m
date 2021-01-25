
#import "FSBleDevice.h"
#import "FSLibHelp.h"

@implementation FSBleModule
- (instancetype _Nonnull )initWithPeripheral:(CBPeripheral *_Nonnull)peripheral {
    if (self = [super init]) {
        _peripheral = peripheral;
        _name = peripheral.name;
        _uuid = peripheral.identifier.UUIDString;
        _advertisementData = [NSMutableDictionary dictionary];
        _isFitshow = NO;
        _type = FSDeviceTypeUnknow;
        _manufacturer = @"";
        _model = @"";
        _hardware = @"";
        _software = @"";
        _deviceID = @"";
        _serial = @"";
    }
    return self;
}

// 设置蓝牙广播包数据
- (void)setAdvertisementData:(NSDictionary * _Nonnull)advertisementData {
    _advertisementData = advertisementData;
    _manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey];
    _discover = advertisementData[CBAdvertisementDataServiceUUIDsKey];
    /*  通过广播包 判断是不是运动秀的蓝牙模块
     如果广播包的厂商细腻为空
     外设的名字为空
     广播的长度 不等于12 不是运东西就的蓝牙模块
     */
    // 蓝牙广播包、名字为空、广播包数据长度不符合要求都不是运动秀的设备
    if (!_manufacturerData ||
        kIsEmptyStr(self.name) ||
        _manufacturerData.length != 12) {
        _isFitshow = NO;
        return;
    }

    // MARK: 和之前相比，这里缺少计算校验码
    Byte *adBytes = (Byte *)self.manufacturerData.bytes;
    if (adBytes) {
        _isFitshow = YES;
        uint device = MAKEDWORD(adBytes[0], adBytes[1], adBytes[2], adBytes[3]);
        _type   = device >> 28; // 右移28位，获取高4位
        _deviceID = FSSF(@"%u", device);
        uint serialNum = MAKEDWORD(adBytes[4], adBytes[5], adBytes[6], adBytes[7]);
        _serial = FSSF(@"%u", serialNum);
    }
}

- (void)setRssi:(int)rssi {
    _rssi = rssi;
}

#pragma mark setter && getter
- (NSArray<CBService *> *)services {
    return _peripheral.services;
}

- (BleProtocolType)protocolType {
    if (self.type == FSDeviceTypeTreadmill ) return BleProtocolTypeTreadmill;
    if (self.type > FSDeviceTypeTreadmill &&
        self.type < FSDeviceTypeUnknow) return BleProtocolTypeCarTable;
    return BleProtocolTypeUnknow;
}



@end

@implementation FSCommand


@end

@implementation FSBleDevice

#pragma mark 开放方法
- (instancetype _Nonnull )initWithModule:(FSBleModule *_Nonnull)module {
    if (self = [super init]) {
        _module = module;
        // 设置外设代理
        _module.peripheral.delegate = self;
        // 重连次数
        _reconnect = 0;
        // 断连类型
        _disconnectType = DisconnectTypeNone;
        // 设置连接状态为断连
        _connectState = ConnectStateDisconnected;
        // 指令集初始化
        _commands = NSMutableArray.array;
        // 收到的执行初始化
        _receiveCmd = [FSCommand new];
    }
    return self;
}

- (void)disconnect {
    
}

- (void)willDisconnect {
    
}


#pragma mark  蓝牙外设代理方法

#pragma mark settre && geter
- (BOOL)isConnected {
    if (self.connectState == ConnectStateConnected ||
        self.connectState == ConnectStateWorking) {
        return YES;
    }
    return NO;
}

@end
