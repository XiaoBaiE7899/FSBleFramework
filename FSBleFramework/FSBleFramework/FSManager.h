
#import "BleManager.h"

@class FSDevice;
@class FSBaseDevice;

NS_ASSUME_NONNULL_BEGIN

@interface FSManager : BleManager

/// 管理器 目标类型的设备 运动秀的app使用，
- (NSMutableArray *)findTargetDevices:(FSSportType)targetType;

/// 查找已绑定的设备  HQ项目添加的  绑定设备
- (FSBaseDevice *)didbindedDevice:(NSString *)localName;


@end

NS_ASSUME_NONNULL_END
