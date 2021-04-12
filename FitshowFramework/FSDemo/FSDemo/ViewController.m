//
//  ViewController.m
//  FSBluetoothSDK
//
//  Created by zt on 2021/1/23.
//

#import "ViewController.h"
#import <FSFramework/FSFramework.h>
#import "ScanedDevicesCtrl.h"
#import "DisplayDataCtrl.h"

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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化  中心管理器
    self.fitshowManager = [FitshowManager managerWithDelegate:self];
    // 监听设备完全停止
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceStop) name:kFitshowHasStoped object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)deviceStop {
    FSLog(@"设备已经停止，这里可以做数据统计&分析");
}

#pragma mark  按钮点击事件

- (IBAction)blescanDevice:(UIButton *)sender {
    [self.fitshowManager.devices removeAllObjects];
    if ([self.fitshowManager startScan]) {
        FSLog(@"可以扫描");
    } else {
        FSLog(@"不可以扫描");
    }
}

- (IBAction)stopScan:(UIButton *)sender {
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
//    if (self.device.disconnect == ) {
//
//    }
//    self.connectState == ConnectStateDisconnected
//    FSLog(@"调用连接 连接状态%ld", (long)self.device.connectState);
//    [self.device setValue:@(0) forKey:@"connectState"];
    [self.device connent:self];
}
- (IBAction)disconnectAction:(UIButton *)sender {
    if (self.device) {
        [self.device disconnect];
    }
}

- (IBAction)startDevice:(UIButton *)sender {
    FSLog(@"启动设备");
    if (self.device.connectState != ConnectStateWorking) {
        FSLog(@"设备没连接成功");
        return;
    }

    // MARK: 这里需要判断  设备是否可以启动
    if ([self.device startDevice]) {
        FSLog(@"可以启动");
    } else {
        FSLog(@"设备不能启动");
    }
    
}

- (IBAction)stopDevice:(UIButton *)sender {
    FSLog(@"停止设备");
    if (!self.device) {
        FSLog(@"设备都没有，何来停止");
        return;
    }
    if (self.device.isConnected) {
        // 设备只有有连接就可以停止
        FSLog(@"发送停止指令");
        [self.device stop];
    }

//    if (self.device.currentStatus == FSDeviceStateRunning ||
//        self.device.currentStatus == FSDeviceStatePaused) {
//        [self.device stop];
//        return;
//    }

//    FSLog(@"只有运行中&暂停中的状态才能  发送停止");

}

- (IBAction)controlSpeed:(UIButton *)sender {
    FSLog(@"控制速度");
    if (!self.device) {
        FSLog(@"设备都没有，何来控制速度");
        return;
    }
    if (self.device.currentStatus != FSDeviceStateRunning) {
        FSLog(@"设备不是在运行中，不能调整速度");
        return;
    }
    [self.device sendTargetSpeed:50];
}
- (IBAction)controlSpeedAndIncline:(UIButton *)sender {
    if (!self.device) {
        FSLog(@"设备都没有，何来控制坡度&速度");
        return;
    }
    if (self.device.currentStatus != FSDeviceStateRunning) {
        FSLog(@"设备不是在运行中，不能调整坡度&速度");
        return;
    }
    [self.device sendTargetSpeed:50 targetIncline:5];
}

- (IBAction)controlIncline:(UIButton *)sender {
    FSLog(@"控制坡度");
    if (!self.device) {
        FSLog(@"设备都没有，何来控制坡度");
        return;
    }
    if (self.device.currentStatus != FSDeviceStateRunning) {
        FSLog(@"设备不是在运行中，不能调整坡度");
        return;
    }
    [self.device sendTargetIncline:5];
}

- (IBAction)controlLevel:(UIButton *)sender {
    FSLog(@"控制阻力");
    if (!self.device) {
        FSLog(@"设备都没有，何来控制阻力");
        return;
    }
    if (self.device.currentStatus != FSDeviceStateRunning) {
        FSLog(@"设备不是在运行中，不能调整阻力");
        return;
    }
    [self.device sendTargetLevel:3];
}

- (IBAction)restore:(UIButton *)sender {
    /*
     MARK: 有的设备发送恢复指令无法恢复，只能通过设备的物理键恢复
     1 暂时只有跑步机才支持恢复
     2 如果设备状态不是出于暂停中，无法返回恢复
     */
    if (!self.device) return;
    if (self.device.module.protocolType != BleProtocolTypeTreadmill) return;
    if (self.device.currentStatus != FSDeviceStatePaused) return;
    [self.device resume];
}

- (IBAction)pauseAction:(UIButton *)sender {
    /*
     暂时只有跑步机，并且使用1.1协议的才有暂停指令
     设备只有在运行中发送暂停指令才被执行
     */
    if (!self.device) return;
    if (self.device.module.protocolType != BleProtocolTypeTreadmill) return;
    [self.device pause];

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
//    if (self.device &&
//        self.device.module.peripheral == device.module.peripheral) {
//        FSLog(@"当前设备已经是信号强度最大的设备了，无需要更新设备");
//        return;
//    }
//    FSLog(@"更新附近的设备");
    self.device = device;
}

#pragma mark 蓝牙外设代理
// 设备断连的方法
- (void)device:(FSBleDevice *)device didDisconnectedWithMode:(DisconnectType)mode {
    switch (mode) {
        case DisconnectTypeNone:{}
            break;
        case DisconnectTypeService:{
            FSLog(@"外设代理回调___断连，因为找不到对应的服务");
        }
            break;
        case DisconnectTypeUser: {}
            break;
        case DisconnectTypeTimeout: {
            FSLog(@"外设代理回调___断连，连接超时");
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
- (void)device:(FSBleDevice *)device didConnectedWithState:(ConnectState)state {
    switch (state) {
        case ConnectStateWorking:{
            FSLog(@"外设代理回调___开始工作");
        }
            break;
        case ConnectStateConnected:{
            FSLog(@"外设代理回调___连接成功");
        }
            break;
        case ConnectStateConnecting:{
            FSLog(@"外设代理回调___连接中");
        }
            break;
        default:
            break;
    }
}

- (void)deviceError:(FSBleDevice *)device {
    FSLog(@"外设代理回调___设备故障 当前状态 %ld", (long)device.currentStatus);
}

- (void)device:(FSBleDevice *)device currentState:(FSDeviceState)newState oldState:(FSDeviceState)oldState {
    FSLog(@"外设代理回调___新状态%ld  旧状态%ld", (long)newState, (long)oldState);
    if (newState == FSDeviceStateStarting) {
        FSLog(@"外设代理回调___启动中  倒计时%@秒", device.countDwonSecond);
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
