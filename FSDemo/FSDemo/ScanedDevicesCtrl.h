
// 已经扫描到的设备

#import <UIKit/UIKit.h>
#import <FSBleFramework/FSBleFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScanedDevicesCtrl : UIViewController

@property (nonatomic, copy) void (^selectDevice)(FSBaseDevice *device);

@end

NS_ASSUME_NONNULL_END
