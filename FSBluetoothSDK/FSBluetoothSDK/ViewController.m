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
#import "DisplayDataCtrl.h"
#import "BezierCtrl.h"

@interface ViewController () <FSCentralDelegate, FSDeviceDelegate>

@property (nonatomic, strong) FSCentralManager *fitshowManager;

@property (nonatomic, strong) FSBleDevice *device;

// 设备的默认图片
@property (weak, nonatomic) IBOutlet UIImageView *deviceImg;
// 模块名称
@property (weak, nonatomic) IBOutlet UILabel *moduleName;
// 已扫描到的设备
@property (nonatomic, strong) ScanedDevicesCtrl *scanedCtl;
// 展示数据的控制器
@property (nonatomic, strong) DisplayDataCtrl   *datasCtrl;

// 贝塞尔曲线测试控制器
@property (nonatomic, strong) BezierCtrl *bezierCtrl;

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

- (IBAction)displaySportDatas:(UIButton *)sender {
    FSLog(@"展示运动数据");
    /* 判断是否有设备 */
    if (!self.device) {
        FSLog(@"设备都没有，哪来的数据");
        return;
    }
    /* 判断设备是否在运行中，如果不是在运行中，不能展示 */
    [self presentViewController:self.datasCtrl animated:YES completion:^{

    }];
}

- (IBAction)contentDevice:(UIButton *)sender {
    if (!self.device) {
        FSLog(@"没有设备，不能连接");
        return;
    }
    [self.fitshowManager stopScan];
    [self.device connent:self];
}

- (IBAction)startDevice:(UIButton *)sender {
    FSLog(@"启动设备");
    // MARK: 这里需要判断  设备是否可以启动
    if ([self.device startDevice]) {

    } else {
        FSLog(@"设备不能启动");
    }
    
}

- (IBAction)stopDevice:(UIButton *)sender {
    FSLog(@"停止设备");
    [self.device stop];
}

- (IBAction)controlSpeed:(UIButton *)sender {
    FSLog(@"控制速度");
    [self.device sendTargetSpeed:50];
}

- (IBAction)controlIncline:(UIButton *)sender {
    FSLog(@"控制坡度");
    [self.device sendTargetIncline:5];
}

- (IBAction)controlLevel:(UIButton *)sender {
    FSLog(@"控制阻力");
//    [self.device sendTargetLevel:3];
    // 测试贝塞尔曲线
    [self presentViewController:self.bezierCtrl animated:YES completion:^{

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

#pragma mark 蓝牙外设代理
// 设备断连的方法
- (void)device:(BleDevice *)device didDisconnectedWithMode:(DisconnectType)mode {
    switch (mode) {
        case DisconnectTypeNone:{}
            break;
        case DisconnectTypeService:{
            FSLog(@"代理回调___断连，因为找不到对应的服务");
        }
            break;
        case DisconnectTypeUser: {}
            break;
        case DisconnectTypeTimeout: {
            FSLog(@"代理回调___断连，连接超时");
        }
            break;
        case DisconnectTypeResponse: {}
            break;;
        case DisconnectTypePoweredOff: {}
            break;
        case DisconnectTypeAbnormal: {}
            break;
        default:
            break;
    }

}

// 设备已连接的方法
- (void)device:(BleDevice *)device didConnectedWithState:(ConnectState)state {
    switch (state) {
        case ConnectStateWorking:{
            FSLog(@"代理回调___开始工作");
        }
            break;
        case ConnectStateConnected:{
            FSLog(@"代理回调___连接成功");
        }
            break;
        case ConnectStateConnecting:{
            FSLog(@"代理回调___连接中");
        }
            break;
        default:
            break;
    }

}

#pragma mark setter && getter
- (void)setDevice:(FSBleDevice *)device {
    _device = device;
//    _device.fsDeviceDeltgate = self;
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


- (DisplayDataCtrl *)datasCtrl {
    if (!_datasCtrl) {
        _datasCtrl = (DisplayDataCtrl *)[self storyboardWithName:@"Main" storyboardID:NSStringFromClass([DisplayDataCtrl class])];

    }
    return _datasCtrl;
}

- (BezierCtrl *)bezierCtrl {
    if (!_bezierCtrl) {
        _bezierCtrl = (BezierCtrl *)[self storyboardWithName:@"Main" storyboardID:NSStringFromClass([BezierCtrl class])];

    }
    return _bezierCtrl;

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
