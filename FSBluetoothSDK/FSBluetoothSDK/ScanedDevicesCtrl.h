
// 已经扫描到的设备

#import <UIKit/UIKit.h>
#import "FSBleDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScanedDevicesCtrl : UIViewController

@property (nonatomic, copy) void (^selectDevice)(FSBleDevice *device);

@end

NS_ASSUME_NONNULL_END
