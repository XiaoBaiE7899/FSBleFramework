
#import <Foundation/Foundation.h>

@class FSBaseDevice;

@class FSSport;

extern FSSport   * _Nonnull fs_sport;       

NS_ASSUME_NONNULL_BEGIN

@interface FSSport : NSObject

@property (nonatomic, strong) FSBaseDevice *fsDevice;

// 初始化方法
+ (instancetype)current;



@end

NS_ASSUME_NONNULL_END
