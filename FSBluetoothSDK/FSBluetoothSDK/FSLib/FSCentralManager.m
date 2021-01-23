
#import "FSCentralManager.h"
#import "FSLibHelp.h"

static NSMutableDictionary  *manager = nil;



@interface FSCentralManager ()

@property (nonatomic) FSManagerState  mgrState;

@property (nonatomic) BOOL isScaning;


@end

@implementation FSCentralManager

- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        if (delegate) {
            self.centralDelegate = delegate;
            _centralManager  = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
            _services = [NSMutableArray new];
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
        ble.centralManager  = [[CBCentralManager alloc] initWithDelegate:ble queue:nil];
    } else if (!ble.isScaning) {
        ble.centralDelegate = delegate;
        [ble centralManagerDidUpdateState:ble.centralManager];
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
    [self.centralManager scanForPeripheralsWithServices:self.services.count ? self.services : nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    return YES;
}

- (void)stopScan {
    self.isScaning = NO;
    [self.centralManager stopScan];
}

- (void)cleanManager {
    [manager removeObjectForKey:NSStringFromClass([self class])];
    _centralDelegate = nil;
}

- (void)sortRssiForDevice {

}

- (void)disconnectAllDevicesInManager {
    for (FSBleDevice *device in self.devices) {
        [device disconnect];
    }
}

- (void)findNearestDevice {

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

    FSBleModule *module = [[FSBleModule alloc] initWithPeripheral:peripheral];
    [module setAdvertisementData:advertisementData];
    [module setRssi:RSSI.intValue];

    // 在管理器的数组中查找 设备， 判断设备是不是已经被扫描到了
    FSBleDevice *device = [self objectForPeripheral:peripheral];

    if (!device) { // 设备还没找到
        return;
    }
    // 设备已经找了 更新设备信息，主要是主要是更新设备的信号量，因为最近的设备是通过信号量计算得到的
    [device.module setAdvertisementData:advertisementData];
    [device.module setRssi:RSSI.intValue];
    // 子类需要重写这个方法，因为不同子类的信号量偏差可能存在不同
    [self findNearestDevice];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 先找到设备，在去找服务
    FSBleDevice *device = [self objectForPeripheral:peripheral];
    if (device) {
        [peripheral discoverServices:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    FSBleDevice *device = [self objectForPeripheral:peripheral];
    if (device) { // 连接失败就重连
        FSLog(@"断开重连^^^重连");
        [device willDisconnect];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    // 先找到设备，在去找服务
    FSBleDevice *device = [self objectForPeripheral:peripheral];
    if (device) { // 连接失败就重连
        FSLog(@"连接失败^^^重连");
        [device willDisconnect];
    }
}

#pragma mark 子类需要重写的方法
- (void)initialize {
}



#pragma mark settet && geter
- (BOOL)hasAuthorized {
    if (@available(iOS 13.0, *)) {
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
- (FSBleDevice *)objectForPeripheral:(CBPeripheral *)peripheral {
    for (FSBleDevice *obj in self.devices) {
        if ([obj.module.peripheral isEqual:peripheral])
            return obj;
    }
    return nil;
}

@end


// MARK: 大件中心管理器，
@implementation FSLargeManager

@end

// MARK: 心率设备管理器
@implementation FSHeartRateManager
@end

// MARK: 跳绳管理器
@implementation FSRopeManager

@end
