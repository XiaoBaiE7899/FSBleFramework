


#import "FSCentralManager.h"
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
    // FIXME: 这个不能注释
//    for (BleDevice *device in self.devices) {
//        [device disconnect];
//    }
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
