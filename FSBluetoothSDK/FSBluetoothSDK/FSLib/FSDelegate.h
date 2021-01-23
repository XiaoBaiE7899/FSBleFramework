
// 自定义蓝牙库的代理文件

#import <Foundation/Foundation.h>
#import "FSEnum.h"

@class FSCentralManager;


/// 自定义中心管理器代理
@protocol FSCentralDelegate <NSObject>

@required

/// 系统蓝牙中心管理器状态发生改变
/// @param manager 中心管理器
/// @param state 状态
- (void)manager:(FSCentralManager *_Nonnull)manager didUpdateState:(FSManagerState)state;

@optional

@end



