
#import <Foundation/Foundation.h>

@class FSBaseDevice;

@class FSSport;

// 全局运动类
extern FSSport   * _Nonnull fs_sport;


NS_ASSUME_NONNULL_BEGIN

@interface FSSport : NSObject

// 图片地址
@property (nonatomic,   copy) NSString     *hostUrl;

// 设备连接成功以后，可以通过全局运动类fs_sport，获取当前连接的设备
@property (nonatomic, strong) FSBaseDevice *_Nullable fsDevice;

/*
 didFinishLaunchingWithOptions:
 集成SDK以后，必须在application: didFinishLaunchingWithOptions:方法中调动这个方法，初始化全局运动类
 */
/// 初始当前运动类
/// @param url 设备的图片地址 如果：@"http://192.168.0.236:8082/api/device/getDeviceInfo/"
+ (instancetype)currentWithHostURL:(NSString *)url;



@end

NS_ASSUME_NONNULL_END
