
#import "FSManager.h"
#import "BleModule.h"
#import "FSDevice.h"
#import "FSSport.h"

@implementation FSManager

- (void)initialize {
    [self.scanUUIDs addObjectsFromArray:@[UUID(FITSHOW_UUID), UUID(FTMS_UUID)]];
}

// 发现最近的设备
- (void)findNearestDevice {
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        BleDevice *dev = nil;
        if (self.devices.count == 1) {
            if ([self.delegate respondsToSelector:@selector(manager:didNearestDevice:)])
                [self.delegate manager:self didNearestDevice:[self.devices firstObject]];
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
            if ([self.delegate respondsToSelector:@selector(manager:didNearestDevice:)])
                [self.delegate manager:self didNearestDevice:dev];
        } else {
            if ([self.delegate respondsToSelector:@selector(manager:didNearestDevice:)])
                [self.delegate manager:self didNearestDevice:self.nearest];
        }
    }
}

- (BleDevice *)newDevice:(BleModule *)module {
    switch (module.sportType) {
        case FSSportTypeTreadmill:{
            return [[FSTreadmill alloc] initWithModule:module] ;
        }
            break;
        case FSSportTypeEllipse:
        case FSSportTypeFitnessCar:
        case FSSportTypeRowing:
        case FSSportTypeWalking:
        case FSSportTypeRider:
        // MARK: 210719  纯机械跑步机也是使用大件类初始化设备
        case FSSportTypeArtificial: {
            return [[FSSection alloc] initWithModule:module];
        }
            break;
        case FSSportTypeSlimming: {
            return [[FSSlimming alloc] initWithModule:module];
        }
            break;
        case FSSportTypeSkipRope: {
            return [[FSRope alloc] initWithModule:module];
        }
            break;
        case FSSportTypeAbdominalWheel: {
            return [[FSRope alloc] initWithModule:module];
        }
            break;
        case FSSportTypeTouchHigh: {
            return [[FSRope alloc] initWithModule:module];
        }
            break;
        case FSSportTypePower: {
            return [[FSPower alloc] initWithModule:module];
        }
            break;
        default:
            break;
    }
    return nil;
}

- (BleDevice *)discoverModule:(BleModule *)module {
    BleDevice *device = nil;
    // MARK:  22.4.8  如果不是运动秀的摸先过滤掉
    if (!module.isFitshow) return device;
    NSData *data = module.manufacturerData;
    if (data.length >= /*8 MARK: 20211027 跳绳、健腹轮的广播是7个字节*/ 7 ) {
        device = [self newDevice:module];
    } else {   //外部处理兼容旧设备
        device = [super discoverModule:module];
    }
    return device;
}

- (NSMutableArray *)findTargetDevices:(FSSportType)targetType {
    NSMutableArray *datas = NSMutableArray.array;
    for (BleDevice *device in self.devices) {
        FSSportType type = device.module.sportType;
        if (type == FSSportTypeArtificial) {
            type = FSSportTypeTreadmill;
        }
        if (targetType == type) {
            [datas addObject:device];
        }
    }
    return datas.count ? datas : nil;
}

- (FSBaseDevice *)didbindedDevice:(NSString *)localName {
    for (FSBaseDevice *obj in self.devices) {
        if ([obj.module.name isEqualToString:localName]) {
            // FIEME: 这里可以对全局设备赋值
            fs_sport.fsDevice = obj;
            return obj;
        }
    }
    return nil;
}

@end
