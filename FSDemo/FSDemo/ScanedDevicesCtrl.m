//
//  ScanedDevicesCtrl.m
//  FSBluetoothSDK
//
//  Created by zt on 2021/3/23.
//

#import "ScanedDevicesCtrl.h"


@interface DeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *deviceImage;

@property (weak, nonatomic) IBOutlet UILabel *moudleName;

@property (weak, nonatomic) IBOutlet UILabel *rssi;

@property (nonatomic, copy) FSBaseDevice *device;




@end

@implementation DeviceCell

- (void)setDevice:(FSBaseDevice *)device {
    _device = device;
    self.moudleName.text = device.module.name;
    self.rssi.text = [NSString stringWithFormat:@"%d", device.module.rssi];
//    self.rssi.text = @"信号量";
    self.deviceImage.image = [UIImage imageNamed:@""];
}



@end

@interface ScanedDevicesCtrl () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) BleManager *fsManager;

@end

@implementation ScanedDevicesCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [UIView new];
    self.tableView.estimatedRowHeight = 90;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.fsManager = [FSManager manager];
    FSLog(@"%lu", self.fsManager.devices.count);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark 表格代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fsManager.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceCell class])];
    cell.device = self.fsManager.devices[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:^{
        self.selectDevice(self.fsManager.devices[indexPath.row]);
    }];
}







@end
