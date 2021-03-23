//
//  ScanedDevicesCtrl.m
//  FSBluetoothSDK
//
//  Created by zt on 2021/3/23.
//

#import "ScanedDevicesCtrl.h"

#import "FSLibHelp.h"
#import "FSCentralManager.h"

@interface DeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *deviceImage;

@property (weak, nonatomic) IBOutlet UILabel *moudleName;

@property (weak, nonatomic) IBOutlet UILabel *rssi;

@property (nonatomic, strong) FSBleDevice *device;

@end

@implementation DeviceCell

- (void)setDevice:(FSBleDevice *)device {
    _device = device;
    _deviceImage.image = device.fsDefaultImage;
    _moudleName.text = device.module.name;
    _rssi.text = FSSF(@"%d", device.module.rssi);
}

@end

@interface ScanedDevicesCtrl () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ScanedDevicesCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [UIView new];
    self.tableView.estimatedRowHeight = 90;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark 表格代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [FitshowManager manager].devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceCell class])];
    cell.device = [FitshowManager manager].devices[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSLog(@"选中设备了");
    if (self.selectDevice) {
        FSBleDevice *device = [FitshowManager manager].devices[indexPath.row];
        self.selectDevice(device);
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}







@end
