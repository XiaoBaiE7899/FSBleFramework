
#import "FSCentralManager.h"
#import "FSLibHelp.h"


static NSMutableDictionary  *manager = nil;



@interface FSCentralManager ()

@property (nonatomic) FSManagerState  mgrState;

@property (nonatomic) BOOL isScaning;

@property (nonatomic) CBCentralManager    *fsCentralManager;

@end

@implementation FSCentralManager

- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        if (delegate) {
            self.centralDelegate = delegate;
            _fsCentralManager  = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
            _services = NSMutableArray.array;
//            [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            [self initialize];
        }
    }
    return self;
}

+ (FSCentralManager *)managerWithDelegate:(id <FSCentralDelegate>)delegate {
    if (!manager) manager = [NSMutableDictionary dictionary];
    FSCentralManager *ble = manager[NSStringFromClass([self class])];
    if (!ble) {
        ble = [[[self class] alloc] initWithDelegate:delegate];
        manager[NSStringFromClass([self class])] = ble;
    }
    else if (ble.mgrState == FSManagerStatePoweredOff) {
        ble.centralDelegate = delegate;
        ble.fsCentralManager  = [[CBCentralManager alloc] initWithDelegate:ble queue:nil];
    } else if (!ble.isScaning) {
        ble.centralDelegate = delegate;
        [ble centralManagerDidUpdateState:ble.fsCentralManager];
    }
    return ble;
}

+ (FSCentralManager *)manager {
    return manager[NSStringFromClass([self class])];
}

- (BOOL)startScan {
    /*
     可以扫描的逻辑
     1 如果没有授权，不能扫描
     2 如果系统蓝牙不知道正常可以扫描的状态  不能扫描
     3 如果蓝牙正在扫描  不能扫描
     MARK: 这里看看是否需要增加过滤调教，如果需要增加过滤条件，增加过滤条件
     */
    if (!self.hasAuthorized) return NO;
    if (self.mgrState != FSManagerStatePoweredOn) return NO;
    if (self.isScaning) return NO;

    // 如果有指定扫描服务，扫描指定服务，如果没有，扫描全部设备
    [self.fsCentralManager scanForPeripheralsWithServices:self.services.count ? self.services : nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    return YES;
}

- (void)stopScan {
    self.isScaning = NO;
    [self.fsCentralManager stopScan];
}

- (void)cleanManager {
    [manager removeObjectForKey:NSStringFromClass([self class])];
    _centralDelegate = nil;
}

- (void)disconnectAllDevicesInManager {
    for (BleDevice *device in self.devices) {
        [device disconnect];
    }
}

#pragma mark 蓝牙中心代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn: {
            // 只有这个状态才可以使用
            self.mgrState = FSManagerStatePoweredOn;
        }
            break;
        case CBManagerStatePoweredOff: {
            // 蓝牙未开启  至于要不要开启蓝牙开关，这个要使用者自己决定
            self.mgrState = FSManagerStatePoweredOff;
        }
            break;

        default: {
            // 其他状态都返回蓝牙不支持，省事
            self.mgrState = FSManagerStateUnsupported;
        }
            break;
    }
    // 代理回调管理器的状态
    [self.centralDelegate manager:self didUpdateState:self.mgrState];
}

/* !!!: 蓝牙广播包数据构成
广播包的数据12字节
前面4个字节：设备id  一个字节8位，一共32位，高4位是设备类型，接下来12位是品牌代码，剩余16位是机型代码
中间4个字节：系列号  这是一个长整形数字
后面4个字节没有用
*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    /*
     扫描得到的设备 的判断逻辑
     1 扫描得到的外设名字为空， 直接返回
     */
    if (kIsEmptyStr(peripheral.name)) return;

    /*
     基本错误已过滤 先通过 peripheral 初始化一个蓝牙模块对象
     重写 设置广播包的的数据 和 更新信号量
     */

    BleModule *module = [[BleModule alloc] initWithPeripheral:peripheral];
    [module setAdvertisementData:advertisementData];
    [module setRssi:RSSI.intValue];

    // 在管理器的数组中查找 设备， 判断设备是不是已经被扫描到了
    BleDevice *device = [self objectForPeripheral:peripheral];

    if (!device) { // 设备还没找到
        device = [self discoverModule:module];
        if (!device) return;  // 没设备直接返回
        // 有设备 设置设备的管理器
        [device setValue:self forKey:@"centralMgr"];
        // 是否添加设备，默认是添加设备的，带可以通过实现willDiscoverDevice 不然设备添加到管理器中
        BOOL add = YES;
        if (self.centralDelegate &&
            [self.centralDelegate respondsToSelector:@selector(manager:willDiscoverDevice:)]) {
            add = [self.centralDelegate manager:self willDiscoverDevice:device];
        }

        // 代理没有拒绝，或者没有实现代理方法，加入设备
        if (add) {
            // 添加设备
            [self.devices addObject:device];
            if (self.centralDelegate &&
                [self.centralDelegate respondsToSelector:@selector(manager:didDiscoverDevice:)]) {
                [self.centralDelegate manager:self didDiscoverDevice:device];
                return;
            }
        }

        return;
    }
    // 设备已经找了 更新设备信息，主要是主要是更新设备的信号量，因为最近的设备是通过信号量计算得到的
    [device.module setAdvertisementData:advertisementData];
    [device.module setRssi:RSSI.intValue];
    // 子类需要重写这个方法，因为不同子类的信号量偏差可能存在不同
    [self findNearestDevice];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    /*成功连接*/
    // 先找到设备，在去找服务
    BleDevice *device = [self objectForPeripheral:peripheral];
    if (device) {
        FSLog(@"外设与中心建立连接，开始查找外设的服务，运动秀的设备到这里不能算是连接成功，要找到FFF1,FFF2 后才算连接成功");
        [peripheral discoverServices:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    BleDevice *device = [self objectForPeripheral:peripheral];
    if (device) { // 连接失败就重连
        FSLog(@"断开重连^^^重连");
        [device willDisconnect];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    // 先找到设备，在去找服务
    BleDevice *device = [self objectForPeripheral:peripheral];
    if (device) { // 连接失败就重连
        FSLog(@"连接失败^^^重连");
        [device willDisconnect];
    }
}

#pragma mark 子类需要重写的方法
- (void)initialize {}

- (void)findNearestDevice {}

- (void)sortRssiForDevice {}

- (BleDevice *)newDevice:(BleModule * _Nonnull)module {
    return [[BleDevice alloc] initWithModule:module];
}

- (BleDevice *)discoverModule:(BleModule *)module {
    if ([_centralDelegate respondsToSelector:@selector(manager:didUnknownModule:)])
        return [_centralDelegate manager:self didUnknownModule:module];
    return nil;
}



#pragma mark settet && geter
- (BOOL)hasAuthorized {
    if (@available(iOS 13.1, *)) {
        return CBManager.authorization == CBManagerAuthorizationDenied ? NO : YES;
    } else {
        return YES;
    }
}

- (NSMutableArray *)devices {
    if (!_devices) {
        _devices = NSMutableArray.array;
    }
    return _devices;
}

#pragma mark 内部方法
- (BleDevice *)objectForPeripheral:(CBPeripheral *)peripheral {
    for (BleDevice *obj in self.devices) {
        if ([obj.module.peripheral isEqual:peripheral])
            return obj;
    }
    return nil;
}



@end


@implementation FitshowManager

/// 初始化的时候指定扫描指定服务
- (void)initialize {
    // !!!: 1826  的服务是运动器材特有的uuid
    [self.services addObject:UUID(SERVICES_UUID)];
}

- (BleDevice *)newDevice:(BleModule * _Nonnull)module {
    return [[FSBleDevice alloc] initWithModule:module];
}

- (BleDevice *)discoverModule:(BleModule *)module {
    BleDevice *device = nil;
    NSData *data = module.manufacturerData;
    /* !!!: 蓝牙广播包数据构成
    广播包的数据12字节
    前面4个字节：设备id  一个字节8位，一共32位，高4位是设备类型，接下来12位是品牌代码，剩余16位是机型代码
    中间4个字节：系列号  这是一个长整形数字
    后面4个字节没有用
    */
    // 因此如果小于8位， 应该直接返回nil
    if (data.length >= 8) {
        device = [self newDevice:module];
    } else {   //外部处理兼容旧设备
        device = [super discoverModule:module];
    }
    return device;

    FSLog(@"子类发现模块  %@", module.name);

}



- (void)findNearestDevice {
    // 确保蓝牙可以使用才有用
    if (self.mgrState != FSManagerStatePoweredOn) return;

    BleDevice *dev = nil;
    if (self.devices.count == 1) {

        if ([self.centralDelegate respondsToSelector:@selector(manager:didNearestDevice:)])
            [self.centralDelegate manager:self didNearestDevice:[self.devices firstObject]];
        return;
    }
    for (BleDevice *obj in self.devices) {
        if (obj.isConnected) [obj.module.peripheral readRSSI];
        if (!dev || dev.module.rssi < obj.module.rssi) dev = obj;
    }

    int rssi = dev ? dev.module.rssi : -100;
    int last = self.nearest ? self.nearest.module.rssi : -100;
    if (last < -95)  {
        self.nearest = nil;
    }

    if ((dev != self.nearest) && (rssi - last > 7 && rssi > -80)) {
        self.nearest = dev;
//            PLog(@"设备名字%@ 设备信号：%d", dev.module.name, dev.module.rssi);
        if ([self.centralDelegate respondsToSelector:@selector(manager:didNearestDevice:)])
            [self.centralDelegate manager:self didNearestDevice:dev];
    } else { // MARK: 如果没有改变，回调上次信号最前的那台设备
        if ([self.centralDelegate respondsToSelector:@selector(manager:didNearestDevice:)])
            [self.centralDelegate manager:self didNearestDevice:self.nearest];
    }
}

@end




