
#import "BleDevice.h"
#import "BleModule.h"
#import "BleManager.h"
#import "NSData+fsExtent.h"
#import "FSSport.h"
#import "FSBleTools.h"

@interface BleDevice ()

@property (nonatomic, readonly) BleCommand *receiveCmd;

@end

@implementation BleDevice

- (instancetype _Nonnull )initWithModule:(BleModule *_Nonnull)module {
    if (self = [super init]) {
        _module                     = module;
        _module.peripheral.delegate = self;
        _reconnect                  = 0;
        _accidentalReconnect        = NO;
        _disconnectType             = FSDisconnectTypeNone;
        _connectState               = FSConnectStateDisconnected;
//        FSLog(@"指令队列初始化");
        _commands                   = [NSMutableArray new];
        _receiveCmd                 = [BleCommand new];
        _getParamSuccess            = NO;
    }
    return self;
}

- (void)connent:(id<BleDeviceDelegate>)delegate {
//    FSLog(@"调用连接");
    // 已经开始连接，就停止扫描
    [self.manager stopScan];
    // FIXME: 甩脂机需要重写设置
    if (self.module.sportType == FSSportTypeSlimming) {
        // MARK: 甩脂机需要从后台获取电机模式才能连接，不然连接无效，速度无法调整
        return;
        // 数据库是否有数据
//        FSDeviceInfo *info = [self deviceInfoFromLocalDataBase];
//        if (!info || kIsEmptyStr(info.paramString)) {
//            return;
//        }
    }

    if (!_manager && !delegate) return;
    self.accidentalReconnect = NO;
    if (self.deviceDelegate) {
        self.deviceDelegate = nil;
    }
    
    self.deviceDelegate = delegate;

    if (self.connectState == FSConnectStateDisconnected) {
        // 开始连接的时候  重连接的次数为:0
        self.reconnect = 0;
        self.connectState = FSConnectStateConnecting;
        // 22.4.1 回调正在连接
        [self.deviceDelegate device:self didConnectedWithState:FSConnectStateConnecting];
        self.reconnect = 1;
        [self reconnectAction];
        return;
    }

    if (self.deviceDelegate &&
        [self.deviceDelegate respondsToSelector:@selector(device:didConnectedWithState:)]) {
        if (self.connectState == FSConnectStateWorking) {
            [self.deviceDelegate device:self didConnectedWithState:FSConnectStateWorking];
        } else if (self.connectState == FSConnectStateConnected) {
            [self onConnected];
            [self.deviceDelegate device:self didConnectedWithState:FSConnectStateConnected];
        }
    }

}


- (void)sendCmdData:(CBCharacteristic *_Nonnull)character data:(NSData *_Nonnull)data {}

- (void)sendCommand:(BleCommand *_Nullable)command {
    if (command) {
//        FSLog(@"指令队列   添加指令");
        [self.commands addObject:command];
//        for (BleCommand *cmd in self.commands) {
//            FSLog(@"指令: %@", cmd.data.fsToString());
//        }
        if (!self.resending) {
            [self onSendData];
        }
    }
}

- (void)disconnect {
    self.disconnectType = FSDisconnectTypeUser;
    self.connectState = FSConnectStateDisconnected;
    [self.manager.centralManager cancelPeripheralConnection:self.module.peripheral];
    self.connectState = FSConnectStateDisconnected;
    self.deviceDelegate = nil;
}

- (void)disconnectWith:(FSDisconnectType)mode {
    if (self.connectState == FSDisconnectTypeUser) {
        return;
    }

    if (self.connectState != FSConnectStateDisconnected) {
//        [self setValue:@(mode) forKeyPath:@"disconnectType"];
        self.disconnectType = mode;
        if (_manager) {
            [_manager.centralManager cancelPeripheralConnection:_module.peripheral];
        } else {
            [self willDisconnect];
        }

        if (mode == FSDisconnectTypeWithoutResponse) {
//            SPBLOCK_EXEC(self.withoutResponse);
            // 回调无响应断开
            if (self.deviceDelegate &&
                [self.deviceDelegate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
//                FSLog(@"33.6.6 代理回调断链 FSDisconnectTypeWithoutResponse");
                [self.deviceDelegate device:self didDisconnectedWithMode:FSDisconnectTypeWithoutResponse];
            }
        }
    }
    
}

- (void)clearSend {
//    FSLog(@"指令队列   移除所有指令");
    [self.commands removeAllObjects];
    if (self.resending) self.resending = NO;
}

- (void)commit {
    _cntError = 0;
//    FSLog(@"指令队列   移除第一条指令");
    if (self.commands.count) [self.commands removeObjectAtIndex:0];
    if (self.commands.count) {
        [self onSendData];
    } else {
        self.resending = NO;
    }
}

- (void)willDisconnect {
    // 断连
    [self onDisconnected];
    // 主动断连不错任何处理
    if (self.disconnectType == FSDisconnectTypeUser) {
        [self clearSend];
        return;
    }

    // 判断连接次数是否超过3次
    if (self.reconnect > 4) {
        return;
    }

    // 判断是什么问题断开连接
    if (_manager.CentralState == FSCentralStatePoweredOff) { // 系统开关关闭
        self.disconnectType = FSDisconnectTypeNone;
    }

    if (!self.accidentalReconnect) {
        self.reconnect = 1;
    }

    // MARK:210421  意外：DisconnectTypeNone， 无响应：DisconnectTypeResponse
    if (self.disconnectType == FSDisconnectTypeNone) {
        if (self.connectState != FSConnectStateConnecting) {
            // 设置重连
            self.reconnect = 1;
            // 意外断开重连
            self.accidentalReconnect = YES;
            self.connectState        = FSConnectStateConnecting;
            [self reconnectAction];
            return;
        }
    }

    self.connectState = FSConnectStateDisconnected;
    if ([self.deviceDelegate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
        // 重新搜索
        self.deviceDelegate = nil;
    }
}


// CX
- (void)deviceInfoData {}

- (void)onDisconnected {
//    FSLog(@"指令队列   所有指令");
    [self.commands removeAllObjects];
    self.connectState = FSConnectStateDisconnected;
}

- (BOOL)onService {
    return YES;
}

- (void)onFailedSend:(BleCommand *)cmd {}

- (void)onConnected {
    // 回调连接成功
}

- (void)removeFromManager {
    [self.manager stopScan];
    [self.manager.devices removeAllObjects];
    [self.manager startScan];
}

- (BOOL)onUpdateData:(BleCommand *)cmd {
    return YES;
}

- (void)onSendData {
    if (!_manager) {       //已释放
        [self willDisconnect];
        return;
    }
    BleCommand *cmd = _commands.firstObject;
//    if (_commands.count) {
//        FSLog(@"第一条指令：%@", cmd.data.fsToString());
//    }
    
    if (_commands.count && ++_cntError <= cmd.sendCnt) { // 发送指令  错误次数没超过
        // 重发
        if (_cntError > 1) {
            // 02 53 00 00 00 00 00 3C AA 19 00 DC 03
            // 跑步机  写入用户信息，  不需要重发
            if (self.module.isFitshow &&
                self.module.isTreadmillProtocol &&
                [/*[FSBleTools dataToString:cmd.data]*/cmd.data.fsToString() hasPrefix:@"02 53 00"]
                /*[cmd.data.fstoString() hasPrefix:@"02 53 00"]*/) {
                // MARK: AB 测试黑色跑步机，连接成功一直滴滴响，因为是控制指令，设备接收控制指令会滴滴响，刚好这条发送失败，一直重发，要求改成只要写入一次，不敢成功还是失败。
                [self commit];
                return;
            }
            self.resending = YES;
        } else {
            self.resending = NO;
//            FSLog(@"发送(%@): %@", _module.name, cmd.data.fstoString());
            FSLog(@"发送(%@): %@", _module.name, /*[FSBleTools dataToString:cmd.data]*/cmd.data.fsToString());

        }

        // MARK: 210616 判断设备是否已经断连，如断链就不发送了;
        if (self.module.peripheral.state != CBPeripheralStateConnected) {
            return;
        }

        if (cmd.data == nil) {
            [_module.peripheral readValueForCharacteristic:cmd.chrt];
        } else if (cmd.chrt.properties & CBCharacteristicPropertyWriteWithoutResponse) {
            [_module.peripheral writeValue:cmd.data forCharacteristic:cmd.chrt type:CBCharacteristicWriteWithoutResponse]; // 不用返回发送的结果
        } else {
            [_module.peripheral writeValue:cmd.data forCharacteristic:cmd.chrt type:CBCharacteristicWriteWithResponse];
        }
        [_sendCmdTimer invalidate];
//        FSLog(@"停止定时器 sendCmdTimer");
        _sendCmdTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onSendData) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_sendCmdTimer forMode:NSRunLoopCommonModes];
    } else if (_commands.count) {
//        [EasyLoadingView hidenLoading];
        _cntFail++;
//        FSLog(@"意外断连 联系失败 失败次数%d", _cntFail);
        // S_CMD
        [self onFailedSend:cmd];
        if (_cntFail == 3) {
            if (self.deviceDelegate && [self.deviceDelegate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
//                FSLog(@"33.6.6 代理回调断链 FSDisconnectTypeAbnormal");
                [self.deviceDelegate device:self didDisconnectedWithMode:FSDisconnectTypeAbnormal];
                [self removeFromManager];
            }
            // MARK:210423 弹出无响应断开连接
//            SPBLOCK_EXEC(self.withoutResponse);
        } else {
            [self commit];
        }
    }

}



#pragma mark 外设代理方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) return;
    [peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBService *service = obj;
        [peripheral discoverCharacteristics:nil forService:service];
    }];
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if ([service.UUID.UUIDString isEqualToString:FITSHOW_UUID]) {
        [self findCharacteristics];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
}

- (void)writeToPeripheral:(CBPeripheral *)peripheral Character:(CBCharacteristic *)characteristic data:(UInt8 *)bytes length:(int)length {
    NSData * data = [NSData dataWithBytes:bytes length: length];
    if (peripheral) {
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

    if (error) return;

    if ([self moduleInfoAgterConnented:characteristic]) {
        return;
    }
    FSLog(@"接收(%@): %@", _module.name, /*[FSBleTools dataToString:characteristic.value]*/characteristic.value.fsToString());
    _receiveCmd.chrt = characteristic;
    _receiveCmd.data = characteristic.value;
    // MARK: 20220111  健腹轮  上报的数据可能为空
    if (kFSIsEmptyString(/*[FSBleTools dataToString:characteristic.value]*/characteristic.value.fsToString())) {
        return;
    }

    // 蓝牙上报数据解析
    if ([self onUpdateData:_receiveCmd]) {
        _cntFail = 0;
        _cntError = 0;
        [self commit];
    }

    // MARK: 210421这个是蓝牙已经在工作中， 设备蓝牙的状态 22.34.1 子类各自判断
//    if (self.connectState != FSConnectStateWorking) {
//        // MARK: 如果是意外断开重连的，不需要回调
//        if (!self.accidentalReconnect &&
//            self.deviceDelegate &&
//            [self.deviceDelegate respondsToSelector:@selector(device:didConnectedWithState:)]) {
//            /* !!!: 210923  重构蓝牙正在工作中
//             原因：康乐佳的设备，test03  模块T4, 如果没有获取设备控制参数，蓝牙可以发送启动指令以后，设备进入倒计时，倒计时到1秒数的时候，设备再也没有上报数据了
//             1 跑步机：获取设备控制参数成功&&当前状态不为初始化状态
//             2 车表：  状态指令有返回再执行回调
//             3 其他设备： 直接回调就行了
//             */
//            self.connectState = FSConnectStateWorking;
//            if (self.module.isTreadmillProtocol) {
//                if (self.getParamSuccess &&
//                    self.currentStatus != -1) {
//                    [self.deviceDelegate device:self didConnectedWithState:FSConnectStateWorking];
//                }
//            } else if (self.module.isSectionProtocol){
//                Byte *databytes = (Byte *)[_receiveCmd.data bytes];
//                Byte maindCmd = databytes[1];
//                if (maindCmd == /*FSMainCmdSectionStatus*/0x42) {
//                    [self.deviceDelegate device:self didConnectedWithState:FSConnectStateWorking];
//                }
//            } else {
//                [self.deviceDelegate device:self didConnectedWithState:FSConnectStateWorking];
//            }
//        }
//    }
}


#pragma mark 内部方法
- (void)findCharacteristics {
    _reconnect = 1;
    _cntFail = 0;
    _cntError = 0;
    // MARK: 子类重写了onService 判断服务是不是fffo， 特征是不是fff1和fff2
//    if (self.disconnectType == FSDisconnectTypeNone &&
//        [self onService]) {
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectTimeout) object:nil];
//        [self onConnected];
//        if (self.deviceDelegate &&
//            [self.deviceDelegate respondsToSelector:@selector(device:didConnectedWithState:)]) {
//            if (!self.accidentalReconnect) {
//                [self onConnected];
//                [self.deviceDelegate device:self didConnectedWithState:FSConnectStateDisconnected];
//
//            }
//        }
//    } else if (self.disconnectType == FSDisconnectTypeNone && ![self onService]) {
//        self.disconnectType = FSDisconnectTypeService;
//        if (self.deviceDelegate &&
//            [self.deviceDelegate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
//            [self.deviceDelegate device:self didDisconnectedWithMode:FSDisconnectTypeService];
//            [self removeFromManager];
//        }
//    }
    if (self.disconnectType == FSDisconnectTypeNone) {
        if ([self onService]) {
            // 清楚指令指令队列
            [self clearSend];
            [self.deviceDelegate device:self didConnectedWithState:FSConnectStateConnected];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectTimeout) object:nil];
            self.connectState = FSConnectStateConnected;
            [self onConnected];
            
            if (self.deviceDelegate &&
                [self.deviceDelegate respondsToSelector:@selector(device:didConnectedWithState:)]) {
                if (!self.accidentalReconnect) {
                    [self onConnected];
                }
            }
            
        } else {
            // 22.3.29 这句不需要
//            self.disconnectType = FSDisconnectTypeService;
            if (self.deviceDelegate &&[self.deviceDelegate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
                [self.deviceDelegate device:self didDisconnectedWithMode:FSDisconnectTypeService];
                [self removeFromManager];
            }
            
        }
    }

    if (self.disconnectType != FSDisconnectTypeNone) {
//        FSLog(@"connect ERROR: %@  code: %d", self.module.name, self.disconnectType);
        if (self.deviceDelegate &&
            [self.deviceDelegate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
//            FSLog(@"33.6.6 代理回调断链 FSDisconnectTypeAbnormal，disconnectType=%d", self.disconnectType);
            [self.deviceDelegate device:self didDisconnectedWithMode:FSDisconnectTypeAbnormal];
            [self removeFromManager];
            // 重新搜索
            self.deviceDelegate = nil;
        }
        [_manager.centralManager cancelPeripheralConnection:_module.peripheral];
    } else if (_commands.count && !self.resending) {
        [self onSendData];
    }

}

- (BOOL)moduleInfoAgterConnented:(CBCharacteristic *)chat {
    return YES;
}

- (void)connectTimeout {
    self.reconnect++;
    if (self.reconnect > 3) {
        if (self.deviceDelegate &&
            [self.deviceDelegate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
            [self.deviceDelegate device:self didDisconnectedWithMode:FSDisconnectTypeTimeout];
            self.deviceDelegate = nil;
            [self removeFromManager];
            return;
        }
    }
    [self reconnectAction];
}

- (void)reconnectAction {
    self.disconnectType = FSDisconnectTypeNone;
    [self performSelector:@selector(connectTimeout) withObject:nil afterDelay:3];
    [_manager.centralManager cancelPeripheralConnection:self.module.peripheral];
    [_manager.centralManager connectPeripheral:self.module.peripheral options:nil];
}

- (BOOL)isConnected {
    if (self.connectState == FSConnectStateConnected ||
        self.connectState == FSConnectStateWorking) {
        return YES;
    }
    return NO;
}

@end
