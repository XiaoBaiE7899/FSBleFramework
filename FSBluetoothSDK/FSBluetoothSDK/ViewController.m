//
//  ViewController.m
//  FSBluetoothSDK
//
//  Created by zt on 2021/1/23.
//

#import "ViewController.h"
#import "FSCentralManager.h"
#import "FSLibHelp.h"

@interface ViewController () <FSCentralDelegate>

@property (nonatomic, strong) FSCentralManager *fitshowManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fitshowManager = [FitshowManager managerWithDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.fitshowManager startScan]) {
        FSLog(@"可以扫描");
    } else {
        FSLog(@"不可以扫描");
    }
}

#pragma mark  按钮点击事件

- (IBAction)blescanDevice:(UIButton *)sender {
    FSLog(@"扫描设备");if ([self.fitshowManager startScan]) {
        FSLog(@"可以扫描");
    } else {
        FSLog(@"不可以扫描");
    }
}

#pragma mark 蓝牙中心代理
- (void)manager:(FSCentralManager *)manager didUpdateState:(FSManagerState)state {
    switch (state) {
        case FSManagerStatePoweredOn: {
            FSLog(@"蓝牙可以使用");
        }
            break;
        case FSManagerStatePoweredOff: {
            FSLog(@"蓝牙没开");
        }
            break;
        case FSManagerStateUnsupported: {
            FSLog(@"设备不支持蓝牙功能");
        }
        default:
            break;
    }
}

- (BleDevice *)manager:(FSCentralManager *)manager didUnknownModule:(BleModule *)modele {
    FSLog(@"扫描到不认识的设备");
    return nil;
}

- (BOOL)manager:(FSCentralManager *)manager willDiscoverDevice:(BleDevice *)device {
    FSLog(@"将要发现设备");
    return YES;
}

- (void)manager:(FSCentralManager *)manager didDiscoverDevice:(BleDevice *)device {
    FSLog(@"已经发现设备");
}

- (void)manager:(FSCentralManager *)manager didNearestDevice:(BleDevice *)device {
    FSLog(@"更新附近的设备");
}

#pragma mark setter & getter
//- (FSCentralManager *)fitshowManager {
//    if (!_fitshowManager) {
//        _fitshowManager = [FitshowManager managerWithDelegate:self];
//    }
//    return _fitshowManager;
//}


@end
