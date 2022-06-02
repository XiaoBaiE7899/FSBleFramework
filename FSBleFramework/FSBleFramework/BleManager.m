
#import "BleManager.h"
#import "BleModule.h"

NSString * _Nonnull const FITSHOW_UUID        = @"FFF0";  // 运动秀扫描的UUID
NSString * _Nonnull const FTMS_UUID           = @"1826";  // 运动器材的UUID
NSString * _Nonnull const FITSHOW_DEVICEINFO  = @"deviceInfo"; // 设备类别的plist列表
NSString * _Nonnull const kUpdateFitshoData   = @"kUpdateFitshoData";
NSString * _Nonnull const kFitshowHasStoped   = @"kFitshowHasStoped";
NSString * _Nonnull const kCmdUncontrolled    = @"kCmdUncontrolled"; // 设备失控


static NSMutableDictionary  *manager = nil;

@interface BleManager ()

@property (nonatomic, strong) NSMutableArray <CBUUID *> *filterServices;

@end

@implementation BleManager

- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        if (delegate) {
            self.delegate = delegate;
            _centralManager  = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
            _scanUUIDs = [NSMutableArray new];
            [self initialize];
        }
    }
    return self;
}

#pragma mark 对外开放的方法
+(BleManager *)managerWithDelegate:(id<FSCentralDelegate>)delegate {
    if (!manager) manager = [NSMutableDictionary dictionary];
    BleManager *ble = manager[NSStringFromClass([self class])];
    if (!ble) {
        ble = [[[self class] alloc] initWithDelegate:delegate];
        manager[NSStringFromClass([self class])] = ble;
    } else if (ble.CentralState == FSCentralStatePoweredOff) {
//        ble.delegate = delegate;
        ble.centralManager  = [[CBCentralManager alloc] initWithDelegate:ble queue:nil];
    } else if (!ble.isScaning) {
//        ble.delegate = delegate;
        [ble centralManagerDidUpdateState:ble.centralManager];
    }
    ble.delegate = delegate;
    return ble;
}

+ (BleManager *)manager {
    return manager[NSStringFromClass([self class])];
}

+ (BOOL)HasAuthorized {
    if (@available(iOS 13.1, *)) {
        return CBManager.authorization == CBManagerAuthorizationDenied ? NO : YES;
    }
    return YES;
}

- (BOOL)startScan {
    if (self.CentralState != FSCentralStatePoweredOn ||
           self.isScaning) {
        self.isScaning = NO;
        return NO;
    }
    self.isScaning = YES;
    // 询问代理是否有需要过滤服务
    if (self.delegate && [self.delegate respondsToSelector:@selector(manager:willScanWithServices:)]) {
        [self.delegate manager:self willScanWithServices:self.filterServices];
        [self.centralManager scanForPeripheralsWithServices:self.filterServices options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    } else {
        [self.centralManager scanForPeripheralsWithServices:self.scanUUIDs.count ? self.scanUUIDs : nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    }
    return YES;
}

/// 停止扫描
- (void)stopScan {
    self.isScaning = NO;
    [self.centralManager stopScan];
}

/// 清除管理
- (void)cleanManager {
    _delegate = nil;
    [manager removeObjectForKey:NSStringFromClass([self class])];
}

- (void)disconnectAllDevicesInManager {
    for (BleDevice *device in self.devices) {
        [device disconnect];
    }
}

#pragma mark 蓝牙中心代理
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn: {
            // 只有这个状态才可以使用
            self.CentralState = FSCentralStatePoweredOn;
            [self.delegate manager:self didUpdateState:FSCentralStatePoweredOn];
        }
            break;
        case CBManagerStatePoweredOff: {
            // 蓝牙未开启  至于要不要开启蓝牙开关，这个要使用者自己决定
            self.CentralState = FSCentralStatePoweredOff;
            [self.delegate manager:self didUpdateState:FSCentralStatePoweredOff];
        }
            break;
        default: {
            // 其他状态都返回蓝牙不支持，省事
            self.CentralState = FSCentralStateUnsupported;
            [self.delegate manager:self didUpdateState:FSCentralStateUnsupported];
        }
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {

    if (!peripheral.name || RSSI.integerValue < -80) {
        return;
    }
    /* !!!: 蓝牙广播包数据构成
    广播包的数据12字节
    前面4个字节：设备id  一个字节8位，一共32位，高4位是设备类型，接下来12位是品牌代码，剩余16位是机型代码
    中间4个字节：系列号  这是一个长整形数字
    后面4个字节没有用
     1206^广播包^旧^FS-13B770 设备类型:3  设备id:812779580  厂商码:114  机型码:2108  系列号:437499760
    */

    /*
     FTMS 广播包数据结构
     VendorId(固定)   设备类型  品牌码   机型码   系列号
     0xCB90          2字节     2字节   2字节   4个字节
     */
    BleModule *module = [[BleModule alloc] initWithPeripheral:peripheral];
    module.advertisementData = advertisementData;
    module.rssi = RSSI.intValue;

    BleDevice *device = [self objectForPeripheral:peripheral];

    if (device) { // 设备已经扫描到了
        device.module.advertisementData = advertisementData;
        device.module.rssi = RSSI.intValue;
        [self findNearestDevice];
        return;
    }

    // 设备没有找到
    device = [self discoverModule:module];
    if (!device) return;  // 没设备直接返回
    device.manager = self;
    BOOL add = YES;
    if (device && [self.delegate respondsToSelector:@selector(manager:willDiscoverDevice:)]) {
        add = [self.delegate manager:self willDiscoverDevice:device];
    }

    if (add && device) {
        // 添加设备
        [self.devices addObject:device];
        if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didDiscoverDevice:)]) {
            [self.delegate manager:self didDiscoverDevice:device];
            return;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
//    FSLog(@"蓝牙中心连接成功%@", peripheral.name);
    BleDevice *device = [self objectForPeripheral:peripheral];
    if (device) {
        FSLog(@"蓝牙中心连接成功%@", device.module.name);
        [peripheral discoverServices:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    FSLog(@"蓝牙中心断开连接");
    BleDevice *device = [self objectForPeripheral:peripheral];
    if (!device) return;
    if (device.reconnect == 3 &&
        device.deviceDelegate &&
        [device.deviceDelegate respondsToSelector:@selector(device:didDisconnectedWithMode:)]) {
        [device.deviceDelegate device:device didDisconnectedWithMode:FSDisconnectTypeWithoutResponse];
    }

    if (device.connectState == FSConnectStateConnecting ||
        device.connectState == FSConnectStateReconnecting) {
        return;
    }

    if (device.module.sportType == FSSportTypeSkipRope) {
        [device onDisconnected];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFitshowHasStoped object:self];
        return;
    }

    if (device) {
        [device willDisconnect];
    }


}

#pragma mark 子类需要重写的方法
- (void)initialize {}

- (void)findNearestDevice {}

- (BleDevice *)discoverModule:(BleModule *)module {
    if ([_delegate respondsToSelector:@selector(manager:didUnknownModule:)])
        return [_delegate manager:self didUnknownModule:module];
    return nil;
}

#pragma mark 内部方法

- (BleDevice *)objectForPeripheral:(CBPeripheral *)peripheral {
    for (BleDevice *obj in self.devices) {
        if ([obj.module.peripheral isEqual:peripheral])
            return obj;
    }
    return nil;
}

#pragma mark setter && getter
- (NSMutableArray<CBUUID *> *)filterServices {
    if (!_filterServices) {
        _filterServices = NSMutableArray.array;
    }
    return _filterServices;
}

- (NSMutableArray *)devices {
    if (!_devices) {
        _devices = NSMutableArray.array;
    }
    return _devices;
}

@end
