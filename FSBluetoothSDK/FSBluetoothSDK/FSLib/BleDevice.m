//
//  BleDevice.m
//  FSBluetoothSDK
//
//  Created by zt on 2021/2/28.
//

#import "BleDevice.h"
#import "FSLibHelp.h"
#import "FSCentralManager.h"

@implementation BleModule
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
        self.type < FSDeviceTypeUnknow) return BleProtocolTypeSection;
    return BleProtocolTypeUnknow;
}



@end

@implementation FSCommand


@end

@interface BleDevice ()

// 指令错误一次，连续发3条失败  算一次错误
@property (nonatomic, assign) int cmdErrorCnt;
// 指令失败次数， 失败3次算一次错误
@property (nonatomic, assign) int cmdFailCnt;

@end


@implementation BleDevice

#pragma mark 开放方法
- (instancetype _Nonnull )initWithModule:(BleModule *_Nonnull)module {
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

// 发起连接
- (void)connent:(id)delegate {
    // FIXME: 2021年3月9日 增加过滤 厂商名=FITHOME || 厂商名=JIANJIA  || 模块名称=JJ-开头 || 模块名称=ZV-开头 || 模块名称=FH-开头 || 模块类型=JJ-开头
    FSLog(@"蓝牙发起连接");
    // 中心管理为空，直接返回
    if (!_centralMgr) return;
    // 自定义外设有值，现在置空，在重新赋值
    if (self.fsDeviceDeltgate) {
        self.fsDeviceDeltgate = nil;
    }
    self.fsDeviceDeltgate = delegate;
    // 判断连接状态
    if (self.connectState == ConnectStateDisconnected) {
        // 为连接状态
        _reconnect = 0; // 开始连接的时候  重连接的次数为:0
        [self setValue:@(ConnectStateConnecting) forKeyPath:@"connectState"];
        // 代理回调连接中
        if (self.fsDeviceDeltgate && [self.fsDeviceDeltgate respondsToSelector:@selector(device:didConnectedWithState:)]) {
            [self.fsDeviceDeltgate device:self didConnectedWithState:ConnectStateConnecting];
        }
        self.reconnect = 1;
        [self reconnectAction];
        self.hasGetModuleInfo = NO;
        return;
    }
    // 通过代理会点连接状态
    if (self.fsDeviceDeltgate && [self.fsDeviceDeltgate respondsToSelector:@selector(device:didConnectedWithState:)]) {
        switch (self.connectState) {
            case ConnectStateWorking: {
                self.hasGetModuleInfo = YES;
                [self.fsDeviceDeltgate device:self didConnectedWithState:ConnectStateWorking];
            }
                break;
            case ConnectStateConnected: {
                self.hasGetModuleInfo = NO;
                [self.fsDeviceDeltgate device:self didConnectedWithState:ConnectStateConnected];
            }
                break;

            default:
                break;
        }

    }
    
}

- (void)disconnect {
    self.disconnectType = DisconnectTypeUser;
    FSLog(@"主动调用断连");
    [self.centralMgr.centralManager cancelPeripheralConnection:self.module.peripheral];
}

- (void)disconnect:(DisconnectType)mode {
    if (self.connectState == DisconnectTypeUser) { // 主动关闭，不做任何处理
        return;
    }
    if (self.connectState != ConnectStateConnected) {
        [self setValue:@(mode) forKeyPath:@"disconnectType"];
        FSLog(@"请求断开连接  因为::: %ld", (long)mode);
        if (self.centralMgr) {
            [self.centralMgr.centralManager cancelPeripheralConnection:_module.peripheral];
        } else {
            // 1204 MARK: 管理器为空  直接断连
//            [self disconnect];
            [self willDisconnect];
        }
        // 如果是无响应断开，做回调处理
        if (mode == DisconnectTypeResponse) {
//            SPBLOCK_EXEC(self.withoutResponse);
            // 回调以后 这回调置空, 管理器情况
        }
    }

}

- (void)willDisconnect {
    [self onDisconnected];

}

- (void)willConnect {
    // FIXME: 这个不写在这里
    self.cmdFailCnt = 0;
    self.cmdErrorCnt = 0;
    if (self.disconnectType == DisconnectTypeNone && [self onService]) {
        // 设置连接成功
        [self setValue:@(ConnectStateConnected) forKeyPath:@"connectState"];
        FSLog(@"连接成功: %@", self.module.name);
        // 取消执行连接超时的方法
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectTimeout) object:nil];
        [self onConnected];

    }

}

#pragma mark 内部方法
// 正式开始连接
- (void)reconnectAction {
    // 连接的方法
    [self performSelector:@selector(connectTimeout) withObject:nil afterDelay:3];
    // 先断连
    [self.centralMgr.centralManager cancelPeripheralConnection:self.module.peripheral];
    // 再连接
    [self.centralMgr.centralManager connectPeripheral:self.module.peripheral options:nil];
}

// 连接超时
- (void)connectTimeout {
    self.reconnect++;
    FSLog(@"连接次数%d", self.reconnect);
    if (self.reconnect > 3) {
        FSLog(@"连接超时");
        // 通过代理回调，回调断连类型
        if (self.fsDeviceDeltgate && [self.fsDeviceDeltgate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
            [self disconnect];
            [self.fsDeviceDeltgate device:self didDisconnectedWithMode:DisconnectTypeTimeout];
            // FIXME: 这个方法不需要
            [self willDisconnect];
            // 停止扫描
            [self.centralMgr.centralManager stopScan];
            // 清楚管理器的所有设备
            [self.centralMgr.devices removeAllObjects];
        }
        return;
    }
    [self reconnectAction];

}

#pragma mark 子类要重的方法

- (BOOL)onService {
    return YES;
}

- (void)onConnected {
    
}

- (void)onDisconnected {
    // 判断是什么问题断开连接
    if (self.centralMgr.mgrState == FSManagerStatePoweredOff) { // 系统开关关闭
        self.disconnectType = DisconnectTypePoweredOff;
    }

    if (self.disconnectType == DisconnectTypeNone && self.connectState != ConnectStateConnecting) {
        return;
    }

    if (self.disconnectType == DisconnectTypeUser) {
//        [self clearSend];
        return;
    }

    [self setValue:@(ConnectStateDisconnected) forKeyPath:@"connectState"];
    if (self.fsDeviceDeltgate && [self.fsDeviceDeltgate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
        FSLog(@"%ld", (long)self.disconnectType);
        // MARK: 20.12.10  注释
//        [self.fs_peripheral_delegate device:self didDisconnectedWithMode:DisconnectTypeService];
        // 重新搜索
        self.fsDeviceDeltgate = nil;
    }
    
}






#pragma mark  蓝牙外设代理方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    FSLog(@"外设发现服务，查找服务");
    if (error) return;
    [peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBService *service = obj;
        [peripheral discoverCharacteristics:nil forService:service];
    }];
}

/* 这个方法到底用来干嘛的  要去查找苹果的文档 */
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices{
    //
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    // MARK: 外设已经发现服务的特征
    if (!error && [service isEqual:peripheral.services.lastObject]) {
        if (!self.fsDeviceDeltgate) {
            [self disconnect:DisconnectTypeNone];
            [self.centralMgr.devices removeAllObjects];
        }  else {
            FSLog(@"外设代理：%@", self.fsDeviceDeltgate);
        }

        // 准备连接
        [self willConnect];
    }
}

#pragma mark settre && geter
- (BOOL)isConnected {
    if (self.connectState == ConnectStateConnected ||
        self.connectState == ConnectStateWorking) {
        return YES;
    }
    return NO;
}


@end
