//
//  ViewController.m
//  FSBluetoothSDK
//
//  Created by zt on 2021/1/23.
//

#import "ViewController.h"
#import "ScanedDevicesCtrl.h"
#import "DisplayDataCtrl.h"
#import <FSBleFramework/FSBleFramework.h>

//#import <AddressBook/AddressBook.h>
//#import <Contacts/Contacts.h>
#import "XBContactLib.h"

static NSString *dev_device = @"FS-12345";



@interface ViewController () <FSCentralDelegate, BleDeviceDelegate>


// 设备的默认图片
@property (weak, nonatomic) IBOutlet UIImageView *deviceImg;
// 模块名称
@property (weak, nonatomic) IBOutlet UILabel *moduleName;
// 已扫描到的设备
@property (nonatomic, strong) ScanedDevicesCtrl *scanedCtl;
// 展示数据的控制器
@property (nonatomic, strong) DisplayDataCtrl   *datasCtrl;

@property (nonatomic, strong) BleManager *fsManager;

//@property (nonatomic, strong) FSBaseDevice *fsDevice;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化  中心管理器
//    self.fsManager = [FSManager managerWithDelegate:self];
    // 监听设备完全停止
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fsdeviceDidStop:) name:kFitshowHasStoped object:nil];
//    [self zx];
    [XBContactLib requestAuthorizationAddressBook];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFitshowData:) name:kUpdateFitshoData object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [XBContactLib addressBooks:^(CNAuthorizationStatus status, NSArray * _Nonnull datas) {
//        FSLog(@"5.13  数据回调完成了");
//    }];
    [fs_sport.fsDevice connent:self];
}

- (void)fsdeviceDidStop:(NSNotification *)sender {
    FSLog(@"22.4.1  设备完全停止了");
    // FIXME: 可以做一些数据统计之类的东西
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFitshowHasStoped object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateFitshoData object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)updateFitshowData:(NSNotification *)notify {
    FSLog(@"暂停测试%d", fs_sport.fsDevice.isPausing);
}

#pragma mark  按钮点击事件

- (IBAction)blescanDevice:(UIButton *)sender {
    if ([self.fsManager startScan]) {
        FSLog(@"可以扫描");
    } else {
        FSLog(@"不可以扫描");
    }
}

- (IBAction)stopScan:(UIButton *)sender {
    [self.fsManager stopScan];

}

- (IBAction)deviceHasScanned:(UIButton *)sender {
    // 所有设备
    FSLog(@"点击所有设备");
    FSLog(@"管理器的设备的个数：%lu", (unsigned long)self.fsManager.devices.count);
    if (self.fsManager.devices.count) {
//        [self.navigationController pushViewController:self.scanedCtl animated:YES];
        [self presentViewController:self.scanedCtl animated:YES completion:^{
        }];
    }
}

- (IBAction)displaySportDatas:(UIButton *)sender {
    /* 判断设备是否在运行中，如果不是在运行中，不能展示 */
    [self presentViewController:self.datasCtrl animated:YES completion:^{
    }];
}

- (IBAction)contentDevice:(UIButton *)sender {
    [self.fsManager stopScan];
    if (fs_sport.fsDevice) {
        FSLog(@"连接最近的设备");
        [fs_sport.fsDevice connent:self];
    }
}

- (IBAction)disconnectAction:(UIButton *)sender {
}

- (IBAction)startDevice:(UIButton *)sender {
    if ([fs_sport.fsDevice start]) {
        FSLog(@"运动秀的设备可以启动");
    } else {
        FSLog(@"运动秀的设备不能启动");
    }
}

- (IBAction)stopDevice:(UIButton *)sender {
    FSLog(@"设备通过指令停止");
//    [self.fsDevice stop];
    [fs_sport.fsDevice stop];
}

- (IBAction)controlSpeed:(UIButton *)sender {
    if (fs_sport.fsDevice.module.sportType == FSSportTypeTreadmill) {
        FSLog(@"控制跑步机速度");
//        [self.fsDevice targetSpeed:50 incline:self.fsDevice.incline.intValue];
        fs_sport.fsDevice.targetSpeed = @"50";
    }
}

- (IBAction)controlSpeedAndIncline:(UIButton *)sender {
    if (fs_sport.fsDevice.module.sportType == FSSportTypeTreadmill) {
        FSLog(@"控制跑步机速度与坡度");
        [fs_sport.fsDevice targetSpeed:50 incline:5];
    }
}

- (IBAction)controlIncline:(UIButton *)sender {
    if (fs_sport.fsDevice.module.sportType == FSSportTypeTreadmill) {
        FSLog(@"控制跑步机  坡度");
        [fs_sport.fsDevice targetSpeed:fs_sport.fsDevice.speed.intValue * 10 incline:5];
    }
}

- (IBAction)controlLevel:(UIButton *)sender {
}

- (IBAction)restore:(UIButton *)sender {
    /*
     MARK: 有的设备发送恢复指令无法恢复，只能通过设备的物理键恢复
     1 暂时只有跑步机才支持恢复
     2 如果设备状态不是出于暂停中，无法返回恢复
     */
}

- (IBAction)pauseAction:(UIButton *)sender {
    /*
     暂时只有跑步机，并且使用1.1协议的才有暂停指令
     设备只有在运行中发送暂停指令才被执行
     */
}

- (ScanedDevicesCtrl *)scanedCtl {
    if (!_scanedCtl) {
        _scanedCtl = (ScanedDevicesCtrl *)[self storyboardWithName:@"Main" storyboardID:NSStringFromClass([ScanedDevicesCtrl class])];
//        __weak typeof(self) weakSelf = self;
//        weakObj(self);
        _scanedCtl.selectDevice = ^(FSBaseDevice * _Nonnull device) {
            FSLog(@"选中的设备%@", device.module.name);
            fs_sport.fsDevice = device;
//            [device connent:weakself];
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

#pragma mark 蓝牙相关

- (void)manager:(BleManager * _Nonnull)manager didUpdateState:(FSCentralState)state {
    FSLog(@"22.3.24系统蓝牙状态只有为1才是可以使用的 %d", state);
}

- (void)manager:(BleManager *)manager didDiscoverDevice:(BleDevice *)device {
    FSLog(@"^^^^22.3.24...设备已经找到%@", device.module.name);
//    if ([device isKindOfClass:[FSBaseDevice class]]) {
//        FSLog(@"是运动秀的设备**");
//        FSLog(@"最近的设备是%@", device.module.name);
//    } else {
//        FSLog(@"不是运动秀的设备*****");
//    }
    if ([device.module.name isEqualToString:dev_device]) {
        FSLog(@"22.6.8 调试设备");
        fs_sport.fsDevice = (FSBaseDevice *)device;
    }
}

- (void)device:(BleDevice *)device didConnectedWithState:(FSConnectState)state {
    switch (state) {
        case FSConnectStateDisconnected: {
            FSLog(@"22.4.1  FSConnectStateDisconnected");
        }
            break;
        case FSConnectStateConnecting: {
            FSLog(@"22.4.1 FSConnectStateConnecting");
        }
            break;
        case FSConnectStateReconnecting: {
            FSLog(@"22.4.1 FSConnectStateReconnecting");
        }
            break;
        case FSConnectStateConnected: {
            FSLog(@"22.4.1 FSConnectStateConnected");
        }
            break;
        case FSConnectStateWorking: {
            FSLog(@"22.4.1 FSConnectStateWorking");
            if ([fs_sport.fsDevice start]) {
                FSLog(@"运动秀的设备可以启动");
            } else {
                FSLog(@"运动秀的设备不能启动");
            }
        }
            
        default:
            break;
    }
//    FSLog(@"22.3.29 设备连接成功：%d", state);
}

- (void)device:(BleDevice *)device didDisconnectedWithMode:(FSDisconnectType)mode {
    FSLog(@"22.3.29 设备已断开连接%d", mode);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"蓝牙断连" message:FSFM(@"%d", mode) preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        PLog(@"点击原生弹框的确定按钮");
//        commitBlock();
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
    
}

- (void)deviceError:(FSBaseDevice *)device {
    FSLog(@"22.3.29 设备故障%@", device.errorCode);
}

- (void)deviceDidUpdateState:(FSDeviceState)newState fromState:(FSDeviceState)oldState {
    FSLog(@"22.6.2 设备状态改变  旧状态%d： 新状态:%d", oldState, newState);
    if (newState == FSDeviceStateTreadmillDisable) {
        FSLog(@"22.3.29 设备 安全锁脱落");
    }
    switch (newState) {
        case FSDeviceStateTreadmillDisable: {
            FSLog(@"22.3.29 设备 安全锁脱落");
        }
            break;
        case FSDeviceStateError: {
            FSLog(@"22.3.29 设备 故障");
        }
            break;
            
        default:
            break;
    }
}

- (void)zx {
    NSArray*keysToFetch =@[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey];
    
    CNContactFetchRequest*fetchRequest = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc]init];
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact*_Nonnull contact,BOOL*_Nonnull stop) {
        NSLog(@"-------------------------------------------------------");
        
        NSString*givenName = contact.givenName;
        
        NSString*familyName = contact.familyName;
        
        NSLog(@"givenName=%@, familyName=%@", givenName, familyName);
        
        NSArray*phoneNumbers = contact.phoneNumbers;
        
        for(CNLabeledValue*labelValue in phoneNumbers) {
            NSString*label = labelValue.label;
            
            CNPhoneNumber *phoneNumber = labelValue.value;
            
            //    NSDictionary*contact =@{@"phone":phoneNumber.stringValue,@"user":FORMAT(@"%@%@",familyName,givenName)};
            //
            //    [contactArr addObject:contact];
            //
                NSLog(@"label=%@, phone=%@", label, phoneNumber.stringValue);
            FSLog(@"");
            
        }
        
        //*stop = YES;// 停止循环，相当于break；
        
    }];
}

- (BleManager *)fsManager {
    if (!_fsManager) {
        _fsManager = [FSManager managerWithDelegate:self];
        FSLog(@"22.6.2 中心地址%p", _fsManager);
    }
    return _fsManager;
}





















@end
