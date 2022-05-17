
#import <Foundation/Foundation.h>

@class FSBaseDevice;

@class FSSport;

extern FSSport   * _Nonnull fs_sport;


NS_ASSUME_NONNULL_BEGIN

@interface FSSport : NSObject

@property (nonatomic,   copy) NSString     *hostUrl;

@property (nonatomic, strong) FSBaseDevice *fsDevice;

// 初始化方法
+ (instancetype)currentWithHostURL:(NSString *)url;



@end

NS_ASSUME_NONNULL_END
