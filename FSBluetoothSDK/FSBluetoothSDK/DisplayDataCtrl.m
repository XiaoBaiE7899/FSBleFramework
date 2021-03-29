
#import "DisplayDataCtrl.h"
#import "FSLibHelp.h"
#import "FSBleDevice.h"

@interface DisplayDataCtrl ()
// 是否为英制设备
@property (weak, nonatomic) IBOutlet UILabel *imperial;
@property (weak, nonatomic) IBOutlet UILabel *oldState;
@property (weak, nonatomic) IBOutlet UILabel *currentState;
@property (weak, nonatomic) IBOutlet UILabel *speed;
@property (weak, nonatomic) IBOutlet UILabel *incline;
@property (weak, nonatomic) IBOutlet UILabel *level;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *calory;
@property (weak, nonatomic) IBOutlet UILabel *steps;
@property (weak, nonatomic) IBOutlet UILabel *counts;
@property (weak, nonatomic) IBOutlet UILabel *hearRate;
@property (weak, nonatomic) IBOutlet UILabel *freq;
@property (weak, nonatomic) IBOutlet UILabel *power;
@property (weak, nonatomic) IBOutlet UILabel *errorcode;
@property (weak, nonatomic) IBOutlet UILabel *maxSpeed;
@property (weak, nonatomic) IBOutlet UILabel *minSpeed;
@property (weak, nonatomic) IBOutlet UILabel *maxIncline;
@property (weak, nonatomic) IBOutlet UILabel *minIncline;
@property (weak, nonatomic) IBOutlet UILabel *maxLevel;
@property (weak, nonatomic) IBOutlet UILabel *minLevel;
@property (weak, nonatomic) IBOutlet UILabel *supportSpeed;
@property (weak, nonatomic) IBOutlet UILabel *supportIncline;
@property (weak, nonatomic) IBOutlet UILabel *supporLevel;
@property (weak, nonatomic) IBOutlet UILabel *supportPause;
@property (weak, nonatomic) IBOutlet UILabel *isRunning;
@property (weak, nonatomic) IBOutlet UILabel *isPaused;
@property (weak, nonatomic) IBOutlet UILabel *isStoped;
@property (weak, nonatomic) IBOutlet UILabel *supportControl;

// 重写setter方法，对模块上报的数据解析赋值
@property (nonatomic, strong) FSBleDevice *device;




@end

@implementation DisplayDataCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // 1 更新运动秀蓝牙返回的数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFitshowData:) name:kUpdateFitshoData object:nil];
    // 2 设备完全停止了
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceStoped:) name:kFitshowHasStoped object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)dealloc {
    // 1
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateFitshoData object:nil];
    // 2
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFitshowHasStoped object:nil];
}

#pragma mark 通知方法
// 监听运动秀返回数据的方法
- (void)updateFitshowData:(NSNotification *)notify {
    self.device = notify.object;
}

// 设备停止
- (void)deviceStoped:(NSNotification *)notify {
    FSLog(@"设备已经完全停止了，这里断连");
    [self.device disconnect];

}

- (void)setDevice:(FSBleDevice *)device {
    if (!device) {
        return;
    }
    _device = device;
    self.imperial.text = _device.imperial ? @"是" : @"否";
    self.oldState.text = FSSF(@"%ld", (long)_device.oldStatus);
    self.currentState.text = FSSF(@"%ld", (long)_device.currentStatus);
    if (self.device.module.protocolType == BleProtocolTypeTreadmill) {
        self.speed.text = FSSF(@"%.1f", [_device.speed intValue]  / 10.0);
    } else if (self.device.module.protocolType == BleProtocolTypeSection) {
        self.speed.text = FSSF(@"%.1f", [_device.speed intValue] / 100.0);
    }
    self.incline.text = _device.incline;
    self.level.text = _device.level;
    self.time.text = _device.eElapsedTime;
    self.distance.text = FSSF(@"%.1f", [_device.distance intValue] / 100.0);
    self.calory.text = _device.calory;
    self.steps.text = _device.steps;
    self.counts.text = _device.counts;
    self.hearRate.text = _device.heartRate;
    self.freq.text = _device.frequency;
    self.power.text = _device.watt;
    self.errorcode.text = _device.errorCode;
    self.maxSpeed.text = _device.maxSpeed;
    self.minSpeed.text = _device.minSpeed;
    self.maxIncline.text = _device.maxIncline;
    self.minIncline.text = _device.minIncline;
    self.maxLevel.text = _device.maxLevel;
    self.minLevel.text = _device.minLevel;
    self.supportSpeed.text = _device.supportSpeed ? @"是" : @"否";
    self.supportIncline.text = _device.supportIncline ? @"是" : @"否";
    self.supporLevel.text = _device.supportLevel ? @"是" : @"否";
    self.supportPause.text = _device.supportPause ? @"是" : @"否";
    self.isRunning.text = _device.currentStatus == FSDeviceStateRunning ? @"是" : @"否";
    self.isPaused.text = _device.currentStatus == FSDeviceStatePaused ? @"是" : @"否";
    self.isStoped.text = _device.hasStoped ? @"是" : @"否";
    self.supportControl.text = _device.supportControl ? @"是" : @"否";
}

#pragma mark 绑定数据
- (void)bindDatas {

}



@end
