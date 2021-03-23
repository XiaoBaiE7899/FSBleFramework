//
//  ViewController.m
//  FSBluetoothSDK
//
//  Created by zt on 2021/1/23.
//

#import "ViewController.h"
#import "FSCentralManager.h"
#import "FSLibHelp.h"
#import "ScanedDevicesCtrl.h"

@interface ViewController () <FSCentralDelegate>

@property (nonatomic, strong) FSCentralManager *fitshowManager;

@property (nonatomic, strong) FSBleDevice *device;

// 设备的默认图片
@property (weak, nonatomic) IBOutlet UIImageView *deviceImg;
// 模块名称
@property (weak, nonatomic) IBOutlet UILabel *moduleName;

@property (nonatomic, strong) ScanedDevicesCtrl *scanedCtl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化  中心管理器
    self.fitshowManager = [FitshowManager managerWithDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark  按钮点击事件

- (IBAction)blescanDevice:(UIButton *)sender {
    FSLog(@"扫描设备");
    if ([self.fitshowManager startScan]) {
        FSLog(@"可以扫描");
    } else {
        FSLog(@"不可以扫描");
    }
}

- (IBAction)stopScan:(UIButton *)sender {
    FSLog(@"停止扫描");
    [self.fitshowManager stopScan];
}
- (IBAction)deviceHasScanned:(UIButton *)sender {
    if (!self.fitshowManager) {
        FSLog(@"中心管理器没有初始化");
        return;
    }

    if (!self.fitshowManager.devices.count) {
        FSLog(@"没有扫描到设备设备");
        return;
    }
    FSLog(@"已经扫描到的设备 有%lu个", (unsigned long)self.fitshowManager.devices.count);
    // MARK: 页面切换  停止扫描
    [self.fitshowManager stopScan];
    [self presentViewController:self.scanedCtl animated:YES completion:^{

    }];
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


- (BOOL)manager:(FSCentralManager *)manager willDiscoverDevice:(FSBleDevice *)device {
    FSLog(@"将要发现设备");
    return YES;
}

- (void)manager:(FSCentralManager *)manager didDiscoverDevice:(FSBleDevice *)device {
    FSLog(@"已经发现设备");
}

- (void)manager:(FSCentralManager *)manager didNearestDevice:(FSBleDevice *)device {
    if (self.device &&
        self.device.module.peripheral == device.module.peripheral) {
        FSLog(@"当前设备已经是信号强度最大的设备了，无需要更新设备");
        return;
    }
    FSLog(@"更新附近的设备");
    self.device = device;
}

#pragma mark setter && getter
- (void)setDevice:(FSBleDevice *)device {
    _device = device;
    self.deviceImg.image = _device.fsDefaultImage;
    self.moduleName.text = _device.module.name;
}

- (ScanedDevicesCtrl *)scanedCtl {
    if (!_scanedCtl) {
        _scanedCtl = (ScanedDevicesCtrl *)[self storyboardWithName:@"Main" storyboardID:NSStringFromClass([ScanedDevicesCtrl class])];
        weakObj(self);
        weakObj(_scanedCtl);
        weak_scanedCtl.selectDevice = ^(FSBleDevice * _Nonnull device) {
            weakself.device = device;
        };
    }
    return _scanedCtl;
}

#pragma mark  Private methods
- (UIViewController *)storyboardWithName:(NSString *)name storyboardID:(NSString *)sid {
    if (sid) {
        return [[UIStoryboard storyboardWithName:name bundle:nil] instantiateViewControllerWithIdentifier:sid];
    }
    else if (name) {
        return [[UIStoryboard storyboardWithName:name bundle:nil] instantiateInitialViewController];
    }

    return nil;
}

@end
