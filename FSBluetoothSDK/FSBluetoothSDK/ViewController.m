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

@property (nonatomic, strong) FSBleDevice *device;

// 设备的默认图片
@property (weak, nonatomic) IBOutlet UIImageView *deviceImg;
// 模块名称
@property (weak, nonatomic) IBOutlet UILabel *moduleName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"FSDeiveceDefImg" ofType:@"bundle"];
    UIImage *iconImage = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"device_deficon_0.png"]];
    // 初始化  中心管理器
    self.fitshowManager = [FitshowManager managerWithDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    
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

@end
