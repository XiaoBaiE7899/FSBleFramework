
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,XBSysDeviceType) {
    Unknown = 0,
    Simulator,
    IPhone_1G,
    IPhone_3G,
    IPhone_3GS,
    IPhone_4,
    IPhone_4s,
    IPhone_5,
    IPhone_5C,
    IPhone_5S,
    IPhone_SE,
    IPhone_6,
    IPhone_6P,
    IPhone_6s,
    IPhone_6s_P,
    IPhone_7,
    IPhone_7P,
    IPhone_8,
    IPhone_8P,
    IPhone_X,
    IPhone_XS,
    IPhone_XS_Max,
    IPhone_XR,
    IPhone_11,
    Iphone_11_pro,
    IPhone_11_Pro_Max,
    iPhone_12_mini,
    iPhone_12,
    iPhone_12_Pro,
    iPhone_12_Pro_Max,
    iPhone_13_Pro,
    iPhone_13_Pro_Max,
    iPhone_13_mini,
    iPhone_13,
};

NS_ASSUME_NONNULL_BEGIN

@interface XBSysDevice : UIView

/// 系统设备类型
+ (XBSysDeviceType)deviceType;

/// 是否为刘海屏
+ (BOOL)isBangScreen;

/// 获取系统状态栏的高度
+ (CGFloat)statusBarHeight;



@end

NS_ASSUME_NONNULL_END
