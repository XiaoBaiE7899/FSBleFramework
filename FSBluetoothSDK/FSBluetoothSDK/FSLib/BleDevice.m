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

+ (instancetype)make:(CBCharacteristic *)object data:(NSData *)data {
    FSCommand *cmd = [FSCommand new];
    cmd.chrt = object;
    cmd.data = data;
    cmd.sendCnt = 3;
    return cmd;
}


@end

@interface BleDevice ()

/* 模块厂商 */
@property (nonatomic) NSString   * _Nullable m_manufacturer;

/* 模块机型 */
@property (nonatomic) NSString   * _Nullable m_model;

/* 硬件版本 */
@property (nonatomic) NSString   * _Nullable m_hardware;

/* 软件版本 */
@property (nonatomic) NSString   * _Nullable m_software;

// 指令错误次数，连错误3条 算一次失败
@property (nonatomic, assign) int cmdErrorCnt;
// 指令失败次数，联系失败3次， 断连
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

- (void)clearSend {
    [self.commands removeAllObjects];
    if (self.resending) {
        self.resending = NO;
    }
}



/// 发送指令
- (void)sendCommand:(FSCommand *_Nullable)command {
    if (command) { // 有指令，才会发送
        [self.commands addObject:command];
//        [self.commands insertObject:command atIndex:0];
        if (!self.resending) {
            [self onSendData];
//            [self.commands insertObject:command atIndex:1];
        } else {
//            [self.commands insertObject:command atIndex:0];
        }
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

- (void)onFailedSend:(FSCommand *_Nullable)cmd {
    //
}

- (NSString *)dataToString:(NSData *)data{
    NSString *s = @"";
    Byte *buf = (Byte *)data.bytes;
    for (uint i = 0; i < data.length; i++) {
        s = [s stringByAppendingFormat:@"%02X ", buf[i]];
    }
    return s;
}

/// 这个方法之类不需要重写
- (void)onSendData {
    if (!_centralMgr) {       //已释放
        [self willDisconnect];
        return;
    }

    FSCommand *cmd = _commands.firstObject;
    if (_commands.count && ++self.cmdErrorCnt <= cmd.sendCnt) { // 发送指令  错误次数没超过
        if (!self.resending) self.resending = YES;
        FSLog(self.cmdErrorCnt > 1 ? @"重发(%@): %@" : @"发送(%@): %@", _module.name, [self dataToString:cmd.data]);

        if (cmd.data == nil) {
            [_module.peripheral readValueForCharacteristic:cmd.chrt];
        } else if (cmd.chrt.properties & CBCharacteristicPropertyWriteWithoutResponse) {
            [_module.peripheral writeValue:cmd.data forCharacteristic:cmd.chrt type:CBCharacteristicWriteWithoutResponse];
        } else {
            [_module.peripheral writeValue:cmd.data forCharacteristic:cmd.chrt type:CBCharacteristicWriteWithResponse];

        }
//        [_sendCmdTimer invalidate];
//        _sendCmdTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onSendData) userInfo:nil repeats:NO];
//        [[NSRunLoop currentRunLoop] addTimer:_sendCmdTimer forMode:NSRunLoopCommonModes];
        // FIXME: 这个定时器没有重复，不应该写成定时器，用延迟执行可能更好
        [_cmdQueueTimer invalidate];
        _cmdQueueTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onSendData) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_cmdQueueTimer forMode:NSRunLoopCommonModes];
    } else if (_commands.count) {
        FSLog(@"指令失败次数%d", self.cmdFailCnt);

        // MARK: 特殊指令，一直发送
        [self onFailedSend:cmd];

        if (++self.cmdFailCnt == 3) {
            FSLog(@"20210322判断失败次数%d", self.cmdFailCnt);
            [self.fsDeviceDeltgate device:self didDisconnectedWithMode:DisconnectTypeTimeout];
            self.disconnectType = DisconnectTypeResponse;
            [self.centralMgr.centralManager cancelPeripheralConnection:_module.peripheral];
        } else {
            // 重新搜索
            FSLog(@"20210322判断失败次数%d", self.cmdFailCnt);
            [self commit];
        }
    }
}

- (void)commit {
    self.cmdErrorCnt = 0;
    if (_commands.count) [(NSMutableArray *)_commands removeObjectAtIndex:0];
    if (_commands.count) {
        [self onSendData];
    }  else {
        self.resending = NO;
    }
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

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    FSLog(@"收到数据");
    if (self.module.isFitshow) { // 如果是运动秀的模块 获取指定数据
        if ([self moduleInfoAgterConnented:characteristic]) {
            return;
        }
    }
}

- (BOOL)moduleInfoAgterConnented:(CBCharacteristic *)chat {
    NSArray *arr = @[CHAR_READ_MFRS, CHAR_READ_PN, CHAR_READ_HV, CHAR_READ_SV];
    NSData    *data = chat.value;
    NSUInteger  len =  data.length;
    Byte *databytes = (Byte *)[data bytes];
    NSString *string = @"";
    for (int i = 0; i < len; i++) {
        uint16_t temp = databytes[i];
        NSString *str = FSSF(@"%c", temp);
        string = [string stringByAppendingString:str];
    }
//    PLog(@"%@", string);
    if ([chat.UUID.UUIDString isEqualToString:CHAR_READ_MFRS]) {  // 厂家
        // 46495453484f57  fitshow
//        [self.module setValue:string forKey:manufacturer];
        self.m_manufacturer = string;
        FSLog(@"获取模块厂商");
        // FIXME: 2021年3月9日 增加过滤 厂商名=FITHOME || 厂商名=JIANJIA  || 模块名称=JJ-开头 || 模块名称=ZV-开头 || 模块名称=FH-开头 || 模块类型=JJ-开头
        /* 连接以后判断厂商名字 */
        FSLog(@"厂商名字%@", self.module.manufacturer);
        NSString *temp = string.uppercaseString;
        if ([temp isEqualToString:@"FITHOME"] ||
            [temp isEqualToString:@"JIANJIA"]) {
//            [EasyTextView showText:@"非运动秀蓝牙模块，无法使用Fitshow APP"];
        }
    } else if ([chat.UUID.UUIDString isEqualToString:CHAR_READ_PN]) { // 型号
//        [self.module setValue:string forKey:model];
        self.m_model = string;
    } else if ([chat.UUID.UUIDString isEqualToString:CHAR_READ_HV]) { // 硬件版本
//        [self.module setValue:string forKey:hardware];
        self.m_hardware = string;
    } else if ([chat.UUID.UUIDString isEqualToString:CHAR_READ_SV]) { // 软件版本
//        [self.module setValue:string forKey:software];
        self.m_software = string;
    }
    return [arr containsObject:chat.UUID.UUIDString];
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
