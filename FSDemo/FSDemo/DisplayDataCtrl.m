
#import "DisplayDataCtrl.h"
#import <FSBleFramework/FSBleFramework.h>


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





@end

@implementation DisplayDataCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // 1 更新运动秀蓝牙返回的数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFitshowData:) name:kUpdateFitshoData object:nil];
    // 2 设备完全停止了
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
}

#pragma mark 通知方法
// 监听运动秀返回数据的方法
- (void)updateFitshowData:(NSNotification *)notify {
    FSBaseDevice *device = notify.object;
    FSLog(@"采集数据展示");
    self.imperial.text = device.deviceParam.imperial ? @"是" : @"否";
    self.oldState.text = [NSString stringWithFormat:@"%d", device.oldStatus];
    self.currentState.text = [NSString stringWithFormat:@"%d", device.currentStatus];
    self.speed.text = device.display_speed;
    self.incline.text = device.incline;
    self.level.text = device.resistance;
    self.time.text = device.exerciseTime;
    self.distance.text = device.displayDistance;
    self.calory.text = device.calory;
    self.steps.text = device.steps;
    self.counts.text = device.counts;
    self.hearRate.text = device.heartRate;
    self.freq.text = device.frequency;
    self.power.text = device.watt;
    self.errorcode.text = device.errorCode;
    self.minSpeed.text = device.deviceParam.minSpeed;
    self.maxIncline.text = device.deviceParam.maxIncline;
    self.minIncline.text = device.deviceParam.minIncline;
    self.maxLevel.text = device.deviceParam.maxLevel;
    self.minLevel.text = device.deviceParam.minLevel;
    self.supportSpeed.text = device.deviceParam.supportSpeed ? @"是" : @"否";
    self.supporLevel.text = device.deviceParam.supportLevel ? @"是" : @"否";
    self.supportIncline.text = device.deviceParam.supportIncline ?  @"是" : @"否";
    self.supportPause.text  = device.deviceParam.supportPause ?  @"是" : @"否";
    self.isRunning.text = device.isRunning ? @"是" : @"否";
    self.isPaused.text = device.isPausing ? @"是" : @"否";
    self.isStoped.text = device.hasStoped ? @"是" : @"否";
    self.supportControl.text = device.deviceParam.supportControl ? @"是" : @"否";
} 

// 设备停止
- (void)deviceStoped:(NSNotification *)notify {
}

#pragma mark 绑定数据
- (void)bindDatas {

}



@end
